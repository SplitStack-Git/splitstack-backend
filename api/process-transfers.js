import admin from "firebase-admin";
import Stripe from "stripe";

/* INIT FIREBASE */

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* HANDLER */

export default async function handler(req, res) {
  try {
    const snapshot = await db
      .collection("participants")
      .where("transfer_pending", "==", true)
      .get();

    console.log("🔥 Pending transfers found:", snapshot.size);

    for (const doc of snapshot.docs) {
      const participant = doc.data();

      console.log("👉 Processing participant:", doc.id);

      if (!participant.charge_id) {
        console.log("❌ Missing charge_id — skipping");
        continue;
      }

      const stackRef = participant.stack_id;

      const organiserSnap = await db
        .collection("participants")
        .where("stack_id", "==", stackRef)
        .where("isOrganiser", "==", true)
        .limit(1)
        .get();

      if (organiserSnap.empty) {
        console.log("❌ No organiser found");
        continue;
      }

      const organiserDoc = organiserSnap.docs[0];
      const organiser = organiserDoc.data();

      if (!organiser.stripe_account_id) {
        console.log("❌ Organiser missing Stripe account");
        continue;
      }

      console.log("✅ Organiser:", organiser.display_name);
      console.log("🔑 Using Stripe account:", organiser.stripe_account_id);

      // ===============================
      // 🔍 DEBUG — CHECK ACCOUNT ACCESS
      // ===============================
      try {
        const account = await stripe.accounts.retrieve(
          organiser.stripe_account_id
        );
        console.log("🔍 ACCOUNT FOUND:", account.id);
      } catch (err) {
        console.log("❌ ACCOUNT ACCESS FAILED:");
        console.log("   code:", err.code);
        console.log("   message:", err.message);
        continue; // stop here — no point trying transfer
      }

      // ===============================
      // 🚀 TRANSFER
      // ===============================

      try {
        console.log("🚀 Attempting transfer...");

        const transfer = await stripe.transfers.create({
          amount: Math.round(Number(participant.amount) * 100),
          currency: "aud",
          destination: organiser.stripe_account_id,
          source_transaction: participant.charge_id,
          metadata: {
            participant_id: doc.id,
            stack_id: stackRef.id,
          },
        });

        console.log("✅ Transfer success:", transfer.id);

        await doc.ref.update({
          transfer_pending: false,
          transfer_id: transfer.id,
        });

      } catch (err) {
        console.log("❌ Transfer failed:");
        console.log("   code:", err.code);
        console.log("   message:", err.message);
      }
    }

    return res.status(200).json({
      success: true,
      count: snapshot.size,
    });

  } catch (err) {
    console.error("❌ Fatal Error:", err.message);

    return res.status(500).json({
      error: err.message,
    });
  }
}
