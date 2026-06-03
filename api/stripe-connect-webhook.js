const admin = require("firebase-admin");
const Stripe = require("stripe");

/* INIT FIREBASE */
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

const db = admin.firestore();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* WEBHOOK HANDLER */
module.exports = async (req, res) => {
  console.log("🔥 WEBHOOK HIT");

  if (req.method !== "POST") return res.status(405).send("POST only");

  let event;
                              
  try {
    const sig = req.headers["stripe-signature"];
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    const buf = Buffer.concat(chunks);
    event = stripe.webhooks.constructEvent(buf, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error("❌ Webhook signature error:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  /* ── CUSTOM CONNECT: ACCOUNT UPDATED ── */
  if (event.type === "account.updated") {
    const account = event.data.object;

    const snapshot = await db
      .collection("users")
      .where("stripe_account_id", "==", account.id)
      .get();

    if (snapshot.empty) {
      console.log("❌ No user found for account:", account.id);
      return res.json({ received: true });
    }

    const userDoc = snapshot.docs[0];

    // For Custom accounts, these are the fields that matter
    const hasRequirements =
      account.requirements?.currently_due?.length > 0 ||
      account.requirements?.past_due?.length > 0;

    await userDoc.ref.update({
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      details_submitted: account.details_submitted,
      // True only when fully onboarded with no outstanding requirements
      connect_onboarded:
        account.charges_enabled &&
        account.payouts_enabled &&
        account.details_submitted &&
        !hasRequirements,
      requirements_currently_due: account.requirements?.currently_due ?? [],
      requirements_past_due: account.requirements?.past_due ?? [],
      requirements_disabled_reason: account.requirements?.disabled_reason ?? null,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("✅ Account updated:", account.id);
    return res.json({ received: true });
  }


  return res.json({ received: true });
};