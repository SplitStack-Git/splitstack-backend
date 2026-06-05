// ensure-connect-account.js
// Called on app launch / before onboarding screen.
// Guarantees the user has a Stripe Custom account shell in Firestore.
// Does NOT submit KYC — that is submit-onboarding.js's job.

import Stripe from "stripe";
import admin from "firebase-admin";

/* ── Firebase init ── */
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );
  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

const db    = admin.firestore();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { user_id, country = "AU" } = req.body;

  // ── 1. Validate ──────────────────────────────────────────────
  if (!user_id) {
    return res.status(400).json({ error: "Missing user_id" });
  }

  const SUPPORTED = ["AU", "NZ", "US", "CA", "GB"];
  if (!SUPPORTED.includes(country)) {
    return res.status(400).json({ error: `Unsupported country: ${country}` });
  }

  try {
    const userRef  = db.collection("users").doc(user_id);
    const userSnap = await userRef.get();
    const userData = userSnap.exists ? userSnap.data() : null;

    // ── 2. Return existing account if already provisioned ────────
    if (userData?.stripe_account_id) {
      // Re-fetch live status from Stripe to return fresh requirements
      const account = await stripe.accounts.retrieve(userData.stripe_account_id);

      return res.status(200).json({
        already_exists:    true,
        stripe_account_id: account.id,
        onboarding_status: deriveStatus(account),
        charges_enabled:   account.charges_enabled,
        payouts_enabled:   account.payouts_enabled,
        details_submitted: account.details_submitted,
        currently_due:     account.requirements?.currently_due     ?? [],
        eventually_due:    account.requirements?.eventually_due    ?? [],
        pending_verification: account.requirements?.pending_verification ?? [],
        requires_document: requiresDocument(account),
      });
    }

    // ── 3. Create new Stripe Custom account shell ────────────────
    //    No KYC data yet — that comes from submit-onboarding.js
    const account = await stripe.accounts.create({
      type:          "custom",
      country,
      capabilities: {
        card_payments: { requested: true },
        transfers:     { requested: true },
      },
    });

    console.log("✅ Stripe account created:", account.id);

    // ── 4. Write to Firestore user doc ───────────────────────────
    await userRef.set({
      uid:                   user_id,
      stripe_account_id:     account.id,
      connect_onboarded:     false,
      charges_enabled:       false,
      payouts_enabled:       false,
      details_submitted:     false,
      onboarding_status:     "not_started",
      onboarding_country:    country,
      requirements_currently_due:      [],
      requirements_eventually_due:     [],
      requirements_pending_verification: [],
      requirements_disabled_reason:    null,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // ── 5. Sync to any existing organiser participant docs ────────
    //    (handles race condition where participant was created first)
    const participantsSnap = await db
      .collection("participants")
      .where("userID",      "==", user_id)
      .where("isOrganiser", "==", true)
      .get();

    const batch = db.batch();
    for (const doc of participantsSnap.docs) {
      batch.set(doc.ref, { stripe_account_id: account.id }, { merge: true });
    }
    if (!participantsSnap.empty) await batch.commit();

    console.log(`✅ Synced stripe_account_id to ${participantsSnap.size} participant doc(s)`);

    return res.status(200).json({
      already_exists:    false,
      stripe_account_id: account.id,
      onboarding_status: "not_started",
      charges_enabled:   false,
      payouts_enabled:   false,
      details_submitted: false,
      currently_due:     [],
      eventually_due:    [],
      pending_verification: [],
      requires_document: false,
    });

  } catch (err) {
    console.error("❌ ensure-connect-account error:", err);
    return res.status(500).json({ error: err.message });
  }
}

/* ── Helpers ──────────────────────────────────────────────── */

function requiresDocument(account) {
  const due = [
    ...(account.requirements?.currently_due  ?? []),
    ...(account.requirements?.eventually_due ?? []),
  ];
  return due.some((r) => r.includes("verification.document"));
}

function deriveStatus(account) {
  const req = account.requirements;
  const currentlyDue = req?.currently_due ?? [];

  if (account.charges_enabled && account.payouts_enabled && currentlyDue.length === 0) {
    return "complete";
  }
  if ((req?.pending_verification ?? []).length > 0) return "pending_verification";
  if (req?.disabled_reason)                          return "restricted";
  if (account.details_submitted)                     return "pending";
  return "not_started";
}


// import Stripe from 'stripe';

// const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// export default async function handler(req, res) {
//   try {
//     if (req.method !== 'POST') {
//       return res.status(405).json({ error: 'Method not allowed' });
//     }

//     const { organiser_id } = req.body;

//     if (!organiser_id) {
//       return res.status(400).json({ error: 'Missing organiser_id' });
//     }

//     // TEMP: Always create account (we refine later)
//     const account = await stripe.accounts.create({
//       type: 'custom',
//       country: 'AU',
//       capabilities: {
//         transfers: { requested: true },
//         card_payments: { requested: true },
//       },
//     });

//     const accountLink = await stripe.accountLinks.create({
//       account: account.id,
//       refresh_url: 'https://splitstack.app/refresh',
//       return_url: 'https://splitstack.app/return',
//       type: 'account_onboarding',
//     });

//     return res.status(200).json({
//       status: 'needs_onboarding',
//       onboarding_url: accountLink.url,
//     });

//   } catch (err) {
//     console.error(err);
//     return res.status(500).json({
//       error: err.message,
//     });
//   }
// }
