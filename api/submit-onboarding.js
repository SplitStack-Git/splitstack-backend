// api/submit-onboarding.js

import Stripe from "stripe";
import admin from "firebase-admin";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* ── Firebase init ─────────────────────────────────────────── */

if (!admin.apps.length) {
  if (!process.env.FIREBASE_SERVICE_ACCOUNT_B64) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_B64 is missing");
  }

  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );

  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
}

const db = admin.firestore();

/* ── Phone → E.164 ─────────────────────────────────────────── */

function formatPhone(phone, country = "AU") {
  if (!phone) return null;
  let d = phone.replace(/\D/g, "");
  const prefixes = { AU: "61", US: "1", CA: "1", GB: "44", NZ: "64" };
  const cc = prefixes[country];
  if (cc && d.startsWith(cc)) return "+" + d;
  if (d.startsWith("0")) d = d.slice(1);
  return cc ? `+${cc}${d}` : `+${d}`;
}

/* ── Country requirements reference ────────────────────────────
 *
 *  AU  → individual.id_number (TFN)
 *        Without it: charges_enabled=false, ID doc required
 *
 *  NZ  → individual.verification.document (passport / driver licence)
 *        No id_number — document upload via /api/upload-identity-document
 *
 *  US  → individual.ssn_last_4  (required to enable charges)
 *        individual.id_number   (full SSN — clears document requirement)
 *
 *  CA  → individual.id_number   (SIN — required)
 *        individual.job_title   (required by Stripe CA)
 *
 *  GB  → No extra fields needed
 *
 * ─────────────────────────────────────────────────────────────*/

/* ── Bank config ───────────────────────────────────────────── */

const BANK_CONFIG = {
  AU: { currency: "aud", useRouting: true },
  NZ: { currency: "nzd", useRouting: false },
  US: { currency: "usd", useRouting: true },
  CA: { currency: "cad", useRouting: true },
  GB: { currency: "gbp", useRouting: true },
};

/* ── Handler ───────────────────────────────────────────────── */

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ status: "error", message: "Method not allowed" });
  }

  try {
    const {
      userId,
      onbFirstName,
      onbLastName,
      onbEmail,
      onbPhone,
      onbDob,
      onbStreet1,
      onbStreet2,
      onbCity,
      onbState,
      onbPostcode,
      onbCountry = "AU",

      // Bank
      onbAccountHolderName,
      onbRoutingNumber,
      onbAccountNumber,

      // ── Country-specific identity fields ────────────────────
      // AU  → TFN         (id_number)
      // US  → full SSN    (id_number)
      // CA  → SIN         (id_number)
      // NZ  → not used — requires document upload
      // GB  → not needed
      onbIdNumber,

      // US only
      onbSsnLast4,

      // CA only
      onbJobTitle,
    } = req.body;

    if (!userId) {
      return res.status(400).json({ status: "error", message: "Missing userId" });
    }

    if (!BANK_CONFIG[onbCountry]) {
      return res.status(400).json({ status: "error", message: `Unsupported country: ${onbCountry}` });
    }

    // ── 1. Ensure user doc exists ────────────────────────────
    const userRef = db.collection("users").doc(userId);
    await userRef.set(
      { uid: userId, email: onbEmail || null, updated_at: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );

    // ── 2. Get or create Stripe Custom account ───────────────
    const userSnap = await userRef.get();
    let stripeAccountId = userSnap.data()?.stripe_account_id || null;

    if (!stripeAccountId) {
      const account = await stripe.accounts.create({
        type: "custom",
        country: onbCountry,
        email: onbEmail,
        business_type: "individual",
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
      });
      stripeAccountId = account.id;
      await userRef.set({ stripe_account_id: stripeAccountId }, { merge: true });
      console.log("✅ Stripe account created:", stripeAccountId);
    }

    // ── 3. Sync to organiser participant docs ────────────────
    const participantsSnap = await db
      .collection("participants")
      .where("userID", "==", userId)
      .where("isOrganiser", "==", true)
      .get();

    const batch = db.batch();
    for (const doc of participantsSnap.docs) {
      batch.set(doc.ref, { stripe_account_id: stripeAccountId }, { merge: true });
    }
    if (!participantsSnap.empty) await batch.commit();

    // ── 4. Build individual block ────────────────────────────
    const dob = new Date(onbDob);

    const individual = {
      first_name: onbFirstName,
      last_name: onbLastName,
      email: onbEmail,
      phone: formatPhone(onbPhone, onbCountry),
      dob: {
        day: dob.getUTCDate(),
        month: dob.getUTCMonth() + 1,
        year: dob.getUTCFullYear(),
      },
      address: {
        line1: onbStreet1,
        line2: onbStreet2 || "",
        city: onbCity,
        state: onbState,
        postal_code: onbPostcode,
        country: onbCountry,
      },
    };

    // AU — TFN. Without this Stripe will require an ID document upload.
    if (onbCountry === "AU" && onbIdNumber) {
      individual.id_number = onbIdNumber;
    }

    // US — ssn_last_4 required to enable charges; id_number clears document requirement.
    if (onbCountry === "US") {
      if (onbSsnLast4) individual.ssn_last_4 = onbSsnLast4;
      if (onbIdNumber) individual.id_number = onbIdNumber;
    }

    // CA — SIN (id_number) + job_title both required to clear past_due restrictions.
    if (onbCountry === "CA") {
      if (onbIdNumber) individual.id_number = onbIdNumber;
      if (onbJobTitle) individual.job_title = onbJobTitle;
    }

    // NZ — no id_number field. Document upload handled separately.

    // ── 5. Build full update payload ─────────────────────────
    const updatePayload = {
      business_type: "individual",
      individual,
      business_profile: {
        mcc: "5734",
        url: "https://splitstack.app",
        product_description: "SplitStack enables users to split bills and collect payments from friends",
      },
      tos_acceptance: {
        date: Math.floor(Date.now() / 1000),
        ip: req.headers["x-forwarded-for"] || req.socket?.remoteAddress || "0.0.0.0",
      },
    };

    // ── 6. Bank account ──────────────────────────────────────
    const bankCfg = BANK_CONFIG[onbCountry];

    if (onbAccountNumber) {
      const externalAccount = {
        object: "bank_account",
        country: onbCountry,
        currency: bankCfg.currency,
        account_holder_name: onbAccountHolderName,
        account_holder_type: "individual",
        account_number: onbAccountNumber,
      };
      if (bankCfg.useRouting && onbRoutingNumber) {
        externalAccount.routing_number = onbRoutingNumber;
      }
      updatePayload.external_account = externalAccount;
    }

    // ── 7. Push to Stripe ────────────────────────────────────
    const updated = await stripe.accounts.update(stripeAccountId, updatePayload);
    console.log("✅ Stripe account updated:", stripeAccountId);

    // ── 8. Derive onboarding status ──────────────────────────
    const currentlyDue = updated.requirements?.currently_due ?? [];
    const eventuallyDue = updated.requirements?.eventually_due ?? [];
    const pendingVerification = updated.requirements?.pending_verification ?? [];
    const disabledReason = updated.requirements?.disabled_reason ?? null;

    const requiresDocument =
      currentlyDue.some(r => r.includes("verification.document")) ||
      eventuallyDue.some(r => r.includes("verification.document"));

    let onboardingStatus = "pending";
    if (updated.charges_enabled && updated.payouts_enabled && currentlyDue.length === 0) {
      onboardingStatus = "complete";
    } else if (pendingVerification.length > 0) {
      onboardingStatus = "pending_verification";
    } else if (disabledReason) {
      onboardingStatus = "restricted";
    }

    // ── 9. Write final status to Firestore ───────────────────
    await userRef.set({
      stripe_onboarding_complete: onboardingStatus === "complete",
      stripe_details_submitted: updated.details_submitted,
      onboarding_status: onboardingStatus,
      charges_enabled: updated.charges_enabled,
      payouts_enabled: updated.payouts_enabled,
      details_submitted: updated.details_submitted,
      requirements_currently_due: currentlyDue,
      requirements_eventually_due: eventuallyDue,
      requirements_pending_verification: pendingVerification,
      requirements_disabled_reason: disabledReason,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return res.status(200).json({
      status: "success",
      stripe_account_id: stripeAccountId,
      onboarding_status: onboardingStatus,
      charges_enabled: updated.charges_enabled,
      payouts_enabled: updated.payouts_enabled,
      details_submitted: updated.details_submitted,
      currently_due: currentlyDue,
      eventually_due: eventuallyDue,
      pending_verification: pendingVerification,
      disabled_reason: disabledReason,
      requires_document: requiresDocument,
    });

  } catch (error) {
    console.error("❌ Onboarding error:", error);

    if (error.type === "StripeInvalidRequestError") {
      return res.status(400).json({
        status: "error",
        param: error.param,
        message: error.message,
      });
    }

    return res.status(500).json({ status: "error", message: error.message });
  }
}


// import Stripe from "stripe";
// import admin from "firebase-admin";

// const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// /* ── Firebase init ─────────────────────────────────────────── */

// let serviceAccount = null;

// if (!admin.apps.length) {
//   try {
//     if (!process.env.FIREBASE_SERVICE_ACCOUNT_B64) {
//       throw new Error("FIREBASE_SERVICE_ACCOUNT_B64 is missing");
//     }

//     serviceAccount = JSON.parse(
//       Buffer.from(
//         process.env.FIREBASE_SERVICE_ACCOUNT_B64,
//         "base64"
//       ).toString("utf8")
//     );

//     // Fix escaped newlines
//     serviceAccount.private_key =
//       serviceAccount.private_key.replace(/\\n/g, "\n");

//     console.log("Firebase env exists:", !!process.env.FIREBASE_SERVICE_ACCOUNT_B64);
//     console.log(
//       "Firebase env length:",
//       process.env.FIREBASE_SERVICE_ACCOUNT_B64.length
//     );

//     console.log("Project ID:", serviceAccount.project_id);
//     console.log("Client Email:", serviceAccount.client_email);
//     console.log(
//       "Private Key Starts:",
//       serviceAccount.private_key.substring(0, 30)
//     );

//     admin.initializeApp({
//       credential: admin.credential.cert(serviceAccount),
//       projectId: serviceAccount.project_id,
//     });
//     async function verifyCredential(serviceAccount) {
//       try {
//         const credential = admin.credential.cert(serviceAccount);

//         const token = await credential.getAccessToken();

//         console.log("✅ ACCESS TOKEN GENERATED");
//         console.log(token.access_token.substring(0, 30));
//       } catch (err) {
//         console.error("❌ ACCESS TOKEN FAILED");
//         console.error(err);
//       }
//     }
//     verifyCredential(serviceAccount);
//     console.log("✅ Firebase Admin initialized");
//   } catch (err) {
//     console.error("❌ Firebase initialization failed");
//     console.error(err);
//     throw err;
//   }
// }

// const db = admin.firestore();

// /* ── Debug helper ─────────────────────────────────────────── */

// async function verifyFirebaseConnection() {
//   try {
//     console.log("Admin Project:", admin.app().options.projectId);

//     const collections = await db.listCollections();

//     console.log(
//       "✅ Firestore connection successful"
//     );

//     console.log(
//       "Collections:",
//       collections.map((c) => c.id)
//     );

//     return true;
//   } catch (err) {
//     console.error("❌ Firestore connection failed");
//     console.error(err);
//     return false;
//   }
// }

// // const db = admin.firestore();

// /* ── Phone → E.164 ─────────────────────────────────────────── */

// function formatPhone(phone, country = "AU") {
//   if (!phone) return null;
//   let d = phone.replace(/\D/g, "");
//   const prefixes = { AU: "61", US: "1", CA: "1", GB: "44", NZ: "64", IE: "353" };
//   const cc = prefixes[country];
//   if (cc && d.startsWith(cc)) return "+" + d;
//   if (d.startsWith("0")) d = d.slice(1);
//   return cc ? `+${cc}${d}` : `+${d}`;
// }

// /* ── Handler ───────────────────────────────────────────────── */

// export default async function handler(req, res) {
//   if (req.method !== "POST") {
//     return res.status(405).json({ status: "error", message: "Method not allowed" });
//   }

//   try {
//     await verifyFirebaseConnection();

//     const {
//       userId,
//       onbFirstName,
//       onbLastName,
//       onbEmail,
//       onbPhone,
//       onbDob,
//       onbStreet1,
//       onbStreet2,
//       onbCity,
//       onbState,
//       onbPostcode,
//       onbCountry = "AU",
//       onbAccountHolderName,
//       onbRoutingNumber,   // BSB (AU), ABA (US), transit-institution (CA), sort code (GB); omit for NZ/IE
//       onbAccountNumber,   // Full account number; for IE send the full IBAN here
//     } = req.body;

//     if (!userId) {
//       return res.status(400).json({ status: "error", message: "Missing userId" });
//     }

//     /* 1. Ensure user doc exists in Firestore */
//     const userRef = db.collection("users").doc(userId);
//     await userRef.set(
//       { uid: userId, email: onbEmail || null, updated_at: admin.firestore.FieldValue.serverTimestamp() },
//       { merge: true }
//     );

//     /* 2. Get or create Stripe Custom account */
//     const userSnap = await userRef.get();
//     let stripeAccountId = userSnap.data()?.stripe_account_id || null;

//     if (!stripeAccountId) {
//       const account = await stripe.accounts.create({
//         type: "custom",
//         country: onbCountry,
//         email: onbEmail,
//         business_type: "individual",
//         capabilities: {
//           card_payments: { requested: true },
//           transfers: { requested: true },
//         },
//       });
//       stripeAccountId = account.id;
//       await userRef.set({ stripe_account_id: stripeAccountId }, { merge: true });
//     }

//     /* 3. Sync stripe_account_id to any organiser participant docs */
//     const participantsSnap = await db
//       .collection("participants")
//       .where("userID", "==", userId)
//       .where("isOrganiser", "==", true)
//       .get();

//     for (const doc of participantsSnap.docs) {
//       await doc.ref.set({ stripe_account_id: stripeAccountId }, { merge: true });
//     }

//     /* 4. Build Stripe update payload */
//     const dob = new Date(onbDob);
//     const updatePayload = {
//       business_type: "individual",
//       individual: {
//         first_name: onbFirstName,
//         last_name: onbLastName,
//         email: onbEmail,
//         phone: formatPhone(onbPhone, onbCountry),
//         dob: {
//           day: dob.getUTCDate(),
//           month: dob.getUTCMonth() + 1,
//           year: dob.getUTCFullYear(),
//         },
//         address: {
//           line1: onbStreet1,
//           line2: onbStreet2 || "",
//           city: onbCity,
//           state: onbState,
//           postal_code: onbPostcode,
//           country: onbCountry,
//         },
//       },
//       business_profile: {
//         mcc: "5734",
//         url: "https://splitstack.app",
//         product_description:
//           "SplitStack enables users to split bills and collect payments from friends",
//       },
//       tos_acceptance: {
//         date: Math.floor(Date.now() / 1000),
//         ip: req.headers["x-forwarded-for"] || req.socket?.remoteAddress || "0.0.0.0",
//       },
//     };

//     /* 5. Bank account — per-country schema
//      *
//      *  AU  → routing_number = BSB (e.g. "110-000"),        account_number
//      *  US  → routing_number = ABA routing (9 digits),      account_number
//      *  CA  → routing_number = transit-institution          account_number
//      *          (e.g. "11000-003": 5-digit transit + 3-digit institution)
//      *  GB  → routing_number = sort code (e.g. "108800"),   account_number
//      *  NZ  → no routing_number; full NZ bank account       account_number
//      *          (16 digits incl. bank/branch prefix)
//      *  IE  → account_number = full IBAN (e.g. "IE29AIBK93115212345678")
//      *          no separate routing_number needed
//      *
//      *  Flutter fields expected:
//      *    onbAccountHolderName  — all countries
//      *    onbAccountNumber      — all countries
//      *    onbRoutingNumber      — AU / US / CA / GB  (BSB, ABA, transit, sort code)
//      *                            send null/empty for NZ and IE
//      */

//     const BANK_CONFIG = {
//       AU: { currency: "aud", useRouting: true },
//       US: { currency: "usd", useRouting: true },
//       CA: { currency: "cad", useRouting: true },
//       GB: { currency: "gbp", useRouting: true },
//       NZ: { currency: "nzd", useRouting: false },
//       // IE: { currency: "eur", useRouting: false, ibanAsAccount: true },
//     };

//     const bankCfg = BANK_CONFIG[onbCountry];

//     if (bankCfg && onbAccountNumber) {
//       const externalAccount = {
//         object: "bank_account",
//         country: onbCountry,
//         currency: bankCfg.currency,
//         account_holder_name: onbAccountHolderName,
//         account_holder_type: "individual",
//         account_number: onbAccountNumber, // IBAN for IE, full acct for others
//       };

//       if (bankCfg.useRouting && onbRoutingNumber) {
//         externalAccount.routing_number = onbRoutingNumber;
//       }

//       updatePayload.external_account = externalAccount;
//     }

//     await stripe.accounts.update(stripeAccountId, updatePayload);

//     /* 6. Mark onboarding complete in Firestore */
//     await userRef.set(
//       {
//         stripe_onboarding_complete: true,
//         stripe_details_submitted: true,
//         updated_at: admin.firestore.FieldValue.serverTimestamp(),
//       },
//       { merge: true }
//     );

//     return res.status(200).json({ status: "success", stripe_account_id: stripeAccountId });

//   } catch (error) {
//     console.error("Onboarding error:", error);
//     return res.status(500).json({ status: "error", message: error.message });
//   }
// }