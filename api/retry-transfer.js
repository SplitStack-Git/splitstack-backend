import Stripe from "stripe";
import admin from "firebase-admin";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Firebase init
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );

  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

export default async function handler(req, res) {
  try {
    const { participantId } = req.body;

    if (!participantId) {
      return res.status(400).json({ error: "Missing participantId" });
    }

    const participantRef = db.collection("participants").doc(participantId);
    const participantSnap = await participantRef.get();

    if (!participantSnap.exists) {
      return res.status(404).json({ error: "Participant not found" });
    }

    const participant = participantSnap.data();

    // 🔥 GET ORGANISER USER
    const userRef = db.collection("users").doc(participant.userID);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const organiserStripeAccountId = userSnap.data().stripe_account_id;

    if (!organiserStripeAccountId) {
      return res.status(400).json({ error: "Missing organiser Stripe account" });
    }

    console.log("🚀 Retrying transfer...");

    const amount = Math.round(participant.amount * 100); // cents

    const transfer = await stripe.transfers.create({
      amount,
      currency: "aud",
      destination: organiserStripeAccountId,
    });

    await participantRef.update({
      transfer_id: transfer.id,
      transfer_pending: false,
      transfer_error: false,
    });

    console.log("✅ Transfer successful:", transfer.id);

    return res.json({ success: true });

  } catch (err) {
    console.error("❌ Retry failed:", err.message);

    return res.status(500).json({
      error: err.message,
    });
  }
}
