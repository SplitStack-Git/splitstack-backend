const admin = require("firebase-admin");
const Stripe = require("stripe");

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

/* HELPER — SAFE TRANSFER ATTEMPT */

async function tryTransfer(stripe, participant, organiserStripeAccountId, stackRef) {
  try {
    console.log("🚀 Attempting transfer...");

    const transfer = await stripe.transfers.create({
      amount: Math.round(Number(participant.amount) * 100),
      currency: "aud",
      destination: organiserStripeAccountId,
      metadata: {
        participant_id: participant.id,
        stack_id: stackRef.id,
      }
    });

    console.log("✅ Transfer success:", transfer.id);

    return { success: true, transferId: transfer.id };

  } catch (err) {
    console.log("❌ Transfer failed (likely too early):", err.code);
    return { success: false };
  }
}

/* WEBHOOK HANDLER */

module.exports = async (req, res) => {
console.log("🔥 WEBHOOK HIT");

if (req.method !== "POST") {
return res.status(405).send("POST only");
}

let event;

try {
const sig = req.headers["stripe-signature"];

```
const chunks = [];
for await (const chunk of req) {
  chunks.push(chunk);
}

const buf = Buffer.concat(chunks);

event = stripe.webhooks.constructEvent(
  buf,
  sig,
  process.env.STRIPE_WEBHOOK_SECRET
);
```

} catch (err) {
console.error("❌ Webhook signature error:", err.message);
return res.status(400).send(`Webhook Error: ${err.message}`);
}

await db.collection("debug").add({
event_type: event.type,
created_at: admin.firestore.FieldValue.serverTimestamp(),
});

// ================================
// CHECKOUT SESSION COMPLETED
// ================================

if (event.type === "checkout.session.completed") {

```
const session = event.data.object;
const participant_id = session.metadata?.participant_id;

if (!participant_id) {
  console.log("❌ Missing participant_id");
  return res.json({ received: true });
}

const participantRef = db.collection("participants").doc(participant_id);
const participantSnap = await participantRef.get();

if (!participantSnap.exists) {
  console.log("❌ Participant not found:", participant_id);
  return res.json({ received: true });
}

const participant = participantSnap.data();

if (participant.paid_status === true) {
  console.log("⚠️ Already paid:", participant_id);
  return res.json({ received: true });
}

const paymentIntentId = session.payment_intent;

console.log("🔥 PAYMENT INTENT:", paymentIntentId);

const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
const chargeId = paymentIntent.latest_charge;

console.log("🔥 CHARGE ID:", chargeId);

await participantRef.update({
  paid_status: true,
  pendingPayment: false,
  payment_intent_id: paymentIntentId,
  charge_id: chargeId,
  transfer_pending: true,
  paid_at: admin.firestore.FieldValue.serverTimestamp(),
});

console.log("✅ Participant marked paid:", participant_id);

// ✅ FIXED ORDER STARTS HERE

let stackRef;

if (typeof participant.stack_id === "string") {
  stackRef = db.collection("stacks").doc(participant.stack_id);
} else {
  stackRef = participant.stack_id;
}

if (!stackRef) {
  console.log("❌ No stackRef");
  return res.json({ received: true });
}

const stackSnap = await stackRef.get();

if (!stackSnap.exists) {
  console.log("❌ Stack not found");
  return res.json({ received: true });
}

const stack = stackSnap.data();

const link = `https://splitstack.app/stackPaymentStatus?token=${stack.public_status_token}`;

// ================================
// FIND ORGANISER
// ================================

const organiserQuery = await db
  .collection("participants")
  .where("stack_id", "==", stackRef)
  .where("isOrganiser", "==", true)
  .limit(1)
  .get();

if (organiserQuery.empty) {
  console.log("❌ Organiser not found");
  return res.json({ received: true });
}

const organiserDoc = organiserQuery.docs[0];
const organiser = organiserDoc.data();

if (!organiser.userID) {
  console.log("❌ Organiser missing userID");
  return res.json({ received: true });
}

const userSnap = await db.collection("users").doc(organiser.userID).get();

if (!userSnap.exists) {
  console.log("❌ User not found for organiser");
  return res.json({ received: true });
}

const organiserStripeAccountId = userSnap.data().stripe_account_id;

if (!organiserStripeAccountId) {
  console.log("❌ Missing organiser Stripe account");
  return res.json({ received: true });
}

console.log("💰 Using Stripe account:", organiserStripeAccountId);

if (participant.transfer_id) return res.json({ received: true });
if (participant.transfer_processing) return res.json({ received: true });

await participantRef.update({ transfer_processing: true });

const result = await tryTransfer(
  stripe,
  { ...participant, id: participantRef.id },
  organiserStripeAccountId,
  stackRef
);

if (result.success) {
  await participantRef.update({
    transfer_id: result.transferId,
    transfer_pending: false,
    transfer_processing: false
  });
} else {
  await participantRef.update({
    transfer_pending: true,
    transfer_error: true,
    transfer_processing: false
  });

  console.log("❌ Transfer failed immediately");
}
```

}

// ================================
// CHARGE SUCCEEDED (RETRY)
// ================================

if (event.type === "charge.succeeded") {

```
const charge = event.data.object;
const paymentIntentId = charge.payment_intent;

if (!paymentIntentId) {
  return res.json({ received: true });
}

let snapshot = await db
  .collection("participants")
  .where("payment_intent_id", "==", paymentIntentId)
  .limit(1)
  .get();

if (snapshot.empty) {
  snapshot = await db
    .collection("participants")
    .where("charge_id", "==", charge.id)
    .limit(1)
    .get();
}

if (snapshot.empty) {
  await new Promise(resolve => setTimeout(resolve, 2000));

  snapshot = await db
    .collection("participants")
    .where("payment_intent_id", "==", paymentIntentId)
    .limit(1)
    .get();
}

if (snapshot.empty) {
  return res.json({ received: true });
}

const participantDoc = snapshot.docs[0];
const participant = participantDoc.data();

if (participant.transfer_id) return res.json({ received: true });
if (!participant.transfer_pending) return res.json({ received: true });
if (participant.transfer_processing) return res.json({ received: true });

await participantDoc.ref.update({ transfer_processing: true });

let stackRef;

if (typeof participant.stack_id === "string") {
  stackRef = db.collection("stacks").doc(participant.stack_id);
} else {
  stackRef = participant.stack_id;
}

const organiserQuery = await db
  .collection("participants")
  .where("stack_id", "==", stackRef)
  .where("isOrganiser", "==", true)
  .limit(1)
  .get();

if (organiserQuery.empty) {
  return res.json({ received: true });
}

const organiser = organiserQuery.docs[0].data();

const userSnap = await db.collection("users").doc(organiser.userID).get();

if (!userSnap.exists) {
  return res.json({ received: true });
}

const organiserStripeAccountId = userSnap.data().stripe_account_id;

const result = await tryTransfer(
  stripe,
  { ...participant, id: participantDoc.id },
  organiserStripeAccountId,
  stackRef
);

if (result.success) {
  await participantDoc.ref.update({
    transfer_id: result.transferId,
    transfer_pending: false,
    transfer_error: false,
    transfer_processing: false
  });
} else {
  await participantDoc.ref.update({
    transfer_processing: false
  });
}
```

}

return res.json({ received: true });
};

