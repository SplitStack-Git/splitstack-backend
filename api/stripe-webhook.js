const admin = require("firebase-admin");
const Stripe = require("stripe");

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(
      process.env.FIREBASE_SERVICE_ACCOUNT_B64,
      "base64"
    ).toString("utf8")
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// read raw body (required for Stripe signature verification)
async function getRawBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", chunk => (data += chunk));
    req.on("end", () => resolve(data));
    req.on("error", reject);
  });
}

module.exports = async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("POST only");
  }

  const sig = req.headers["stripe-signature"];

  let event;
  try {
    const rawBody = await getRawBody(req);
    event = stripe.webhooks.constructEvent(
      rawBody,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

if (event.type === "account.updated") {
  const account = event.data.object;

  const snapshot = await db
    .collection("users")
    .where("stripe_connect_account_id", "==", account.id)
    .get();

  if (!snapshot.empty) {
    const userDoc = snapshot.docs[0];

    await userDoc.ref.update({
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      connect_onboarded:
        account.charges_enabled && account.payouts_enabled,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("Account updated:", account.id);
  }
}

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;

    const stack_id = session.metadata?.stack_id;
    const participant_id = session.metadata?.participant_id;

    console.log("PAID:", { stack_id, participant_id });
  }

  res.json({ received: true });
};
