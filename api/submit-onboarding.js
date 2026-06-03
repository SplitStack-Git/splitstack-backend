import Stripe from "stripe";
import admin from "firebase-admin";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* ── Firebase init ─────────────────────────────────────────── */

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );
  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

const db = admin.firestore();

/* ── Phone → E.164 ─────────────────────────────────────────── */

function formatPhone(phone, country = "AU") {
  if (!phone) return null;
  let d = phone.replace(/\D/g, "");
  const prefixes = { AU: "61", US: "1", CA: "1", GB: "44", NZ: "64", IE: "353" };
  const cc = prefixes[country];
  if (cc && d.startsWith(cc)) return "+" + d;
  if (d.startsWith("0")) d = d.slice(1);
  return cc ? `+${cc}${d}` : `+${d}`;
}

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
      onbAccountHolderName,
      onbRoutingNumber,   // BSB (AU), ABA (US), transit-institution (CA), sort code (GB); omit for NZ/IE
      onbAccountNumber,   // Full account number; for IE send the full IBAN here
    } = req.body;

    if (!userId) {
      return res.status(400).json({ status: "error", message: "Missing userId" });
    }

    /* 1. Ensure user doc exists in Firestore */
    const userRef = db.collection("users").doc(userId);
    await userRef.set(
      { uid: userId, email: onbEmail || null, updated_at: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );

    /* 2. Get or create Stripe Custom account */
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
    }

    /* 3. Sync stripe_account_id to any organiser participant docs */
    const participantsSnap = await db
      .collection("participants")
      .where("userID", "==", userId)
      .where("isOrganiser", "==", true)
      .get();

    for (const doc of participantsSnap.docs) {
      await doc.ref.set({ stripe_account_id: stripeAccountId }, { merge: true });
    }

    /* 4. Build Stripe update payload */
    const dob = new Date(onbDob);
    const updatePayload = {
      business_type: "individual",
      individual: {
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
      },
      business_profile: {
        mcc: "5734",
        url: "https://splitstack.app",
        product_description:
          "SplitStack enables users to split bills and collect payments from friends",
      },
      tos_acceptance: {
        date: Math.floor(Date.now() / 1000),
        ip: req.headers["x-forwarded-for"] || req.socket?.remoteAddress || "0.0.0.0",
      },
    };

    /* 5. Bank account — per-country schema
     *
     *  AU  → routing_number = BSB (e.g. "110-000"),        account_number
     *  US  → routing_number = ABA routing (9 digits),      account_number
     *  CA  → routing_number = transit-institution          account_number
     *          (e.g. "11000-003": 5-digit transit + 3-digit institution)
     *  GB  → routing_number = sort code (e.g. "108800"),   account_number
     *  NZ  → no routing_number; full NZ bank account       account_number
     *          (16 digits incl. bank/branch prefix)
     *  IE  → account_number = full IBAN (e.g. "IE29AIBK93115212345678")
     *          no separate routing_number needed
     *
     *  Flutter fields expected:
     *    onbAccountHolderName  — all countries
     *    onbAccountNumber      — all countries
     *    onbRoutingNumber      — AU / US / CA / GB  (BSB, ABA, transit, sort code)
     *                            send null/empty for NZ and IE
     */

    const BANK_CONFIG = {
      AU: { currency: "aud", useRouting: true },
      US: { currency: "usd", useRouting: true },
      CA: { currency: "cad", useRouting: true },
      GB: { currency: "gbp", useRouting: true },
      NZ: { currency: "nzd", useRouting: false },
      IE: { currency: "eur", useRouting: false, ibanAsAccount: true },
    };

    const bankCfg = BANK_CONFIG[onbCountry];

    if (bankCfg && onbAccountNumber) {
      const externalAccount = {
        object: "bank_account",
        country: onbCountry,
        currency: bankCfg.currency,
        account_holder_name: onbAccountHolderName,
        account_holder_type: "individual",
        account_number: onbAccountNumber, // IBAN for IE, full acct for others
      };

      if (bankCfg.useRouting && onbRoutingNumber) {
        externalAccount.routing_number = onbRoutingNumber;
      }

      updatePayload.external_account = externalAccount;
    }

    await stripe.accounts.update(stripeAccountId, updatePayload);

    /* 6. Mark onboarding complete in Firestore */
    await userRef.set(
      {
        stripe_onboarding_complete: true,
        stripe_details_submitted: true,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return res.status(200).json({ status: "success", stripe_account_id: stripeAccountId });

  } catch (error) {
    console.error("Onboarding error:", error);
    return res.status(500).json({ status: "error", message: error.message });
  }
}