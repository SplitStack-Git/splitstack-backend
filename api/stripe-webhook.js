const admin = require("firebase-admin");
const Stripe = require("stripe");
const twilio = require("twilio");
const { parsePhoneNumberFromString } = require("libphonenumber-js");

/* ================================
   INIT FIREBASE
================================ */

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
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

/* ================================
   🌍 PHONE FORMATTER
================================ */

function formatPhone(phone, defaultCountry = "AU") {
  try {
    const parsed = parsePhoneNumberFromString(phone, defaultCountry);

    if (!parsed || !parsed.isValid()) return null;

    return parsed.number; // +614...
  } catch {
    return null;
  }
}

/* ================================
   WEBHOOK HANDLER
================================ */

module.exports = async (req, res) => {
  console.log("🔥 WEBHOOK HIT");

  if (req.method !== "POST") {
    return res.status(405).send("POST only");
  }

  let event;

  try {
    const sig = req.headers["stripe-signature"];

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

  } catch (err) {
    console.error("❌ Webhook signature error:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  /* ================================
     CHECKOUT COMPLETED
  ================================ */

  if (event.type === "checkout.session.completed") {

    const session = event.data.object;
    const participant_id = session.metadata?.participant_id;

    if (!participant_id) {
      console.log("❌ Missing participant_id");
      return res.json({ received: true });
    }

    const participantRef = db.collection("participants").doc(participant_id);
    const participantSnap = await participantRef.get();

    if (!participantSnap.exists) {
      console.log("❌ Participant not found");
      return res.json({ received: true });
    }

    const participant = participantSnap.data();
console.log("🔥 participant_id:", participant_id);
console.log("🔥 participant name:", participant.display_name || participant.name);
console.log("🔥 participant phone:", participant.phone);

    /* ================================
       🔒 DUPLICATE PROTECTION
    ================================ */

    if (participant.paid_status === true) {
      console.log("⚠️ Already paid — skipping duplicate webhook");
      return res.json({ received: true });
    }

    /* ================================
       MARK AS PAID
    ================================ */

    const paymentIntentId = session.payment_intent;

    await participantRef.update({
      paid_status: true,
      pendingPayment: false,
      payment_intent_id: paymentIntentId,
      paid_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("✅ Participant marked paid");

    /* ================================
       SEND SMS
    ================================ */

    try {
      console.log("📩 SMS START");

      const stackRef =
        typeof participant.stack_id === "string"
          ? db.collection("stacks").doc(participant.stack_id)
          : participant.stack_id;

      const stackSnap = await stackRef.get();

      if (!stackSnap.exists) {
        console.log("❌ Stack not found");
        return res.json({ received: true });
      }

      const stackData = stackSnap.data();

      const link =
  "https://app.splitstack.com.au/stackPaymentStatus?token=" +
  stackData.public_status_token;

      if (!participant.phone) {
        console.log("❌ Missing phone");
      } else {
        const formattedPhone = formatPhone(participant.phone, "AU");

        if (!formattedPhone) {
          console.log("❌ Invalid phone — skipping SMS:", participant.phone);
        } else {
          console.log("📞 Sending to:", formattedPhone);

          await twilioClient.messages.create({
            body: `✅ Payment received

Hey ${participant.display_name || participant.name || "there"},

You’ve successfully paid $${participant.amount} for ${stackData.title}.

View live status:
${link}`,
            from: process.env.TWILIO_PHONE_NUMBER,
            to: formattedPhone,
          });

          console.log("📩 SMS sent");
        }
      }

    } catch (err) {
      console.log("❌ SMS failed:", err.message);
    }

    console.log("🎉 DONE — Stripe handled transfer automatically");
  }

  return res.json({ received: true });
};
