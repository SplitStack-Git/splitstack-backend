'use strict';

const admin = require('firebase-admin');
const Stripe = require('stripe');
const twilio = require('twilio');

function initFirebaseAdmin() {
if (admin.apps.length) return;

const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_B64;
if (!base64) throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_B64");

const json = Buffer.from(base64, "base64").toString("utf8");
const serviceAccount = JSON.parse(json);

serviceAccount.private_key = serviceAccount.private_key.replace(/\n/g, "\n");

admin.initializeApp({
credential: admin.credential.cert(serviceAccount)
});
}

async function readJsonBody(req) {
if (req.body && typeof req.body === 'object') return req.body;

const chunks = [];
for await (const chunk of req) chunks.push(chunk);
const raw = Buffer.concat(chunks).toString('utf8').trim();
if (!raw) return {};
return JSON.parse(raw);
}

module.exports = async (req, res) => {

console.log("🔥 CREATE CHECKOUT SESSION HIT");

res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

if (req.method === 'OPTIONS') return res.status(204).send('');
if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });

try {

```
initFirebaseAdmin();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
});

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

const body = await readJsonBody(req);
const { participant_id } = body;

if (!participant_id) {
  return res.status(400).json({ error: 'participant_id required' });
}

const db = admin.firestore();

// -------------------------
// LOAD PARTICIPANT
// -------------------------

const participantRef = db.collection('participants').doc(String(participant_id));
const participantSnap = await participantRef.get();

if (!participantSnap.exists) {
  return res.status(404).json({ error: 'Participant not found' });
}

const participant = participantSnap.data();
const participantDocId = participantRef.id;

console.log("✅ USING PARTICIPANT:", participantDocId);

if (participant.paid_status === true) {
  return res.status(400).json({ error: 'Participant already paid' });
}

// -------------------------
// LOAD STACK (SAFE)
// -------------------------

let stackRef;

if (typeof participant.stack_id === "string") {
  stackRef = db.collection('stacks').doc(participant.stack_id);
} else {
  stackRef = participant.stack_id;
}

if (!stackRef) {
  return res.status(400).json({ error: 'Missing stack reference' });
}

const stackSnap = await stackRef.get();

if (!stackSnap.exists) {
  return res.status(404).json({ error: 'Stack not found' });
}

const stack = stackSnap.data();

// -------------------------
// PAYMENT CALCULATION
// -------------------------

const currency = (participant.currency || stack.currency || 'aud').toLowerCase();

let unitAmount = participant.amount_to_pay_cents;

if (!unitAmount) {
  if (!participant.amount) {
    return res.status(400).json({ error: 'Participant amount missing' });
  }
  unitAmount = Math.round(Number(participant.amount) * 100);
}

if (!unitAmount || unitAmount <= 0) {
  return res.status(400).json({ error: 'Invalid amount' });
}

console.log("💰 Amount (cents):", unitAmount);

// -------------------------
// CREATE STRIPE SESSION
// -------------------------

const session = await stripe.checkout.sessions.create({
  mode: 'payment',
  line_items: [
    {
      price_data: {
        currency,
        product_data: {
          name: `SplitStack — ${stack.title || 'Payment'}`
        },
        unit_amount: unitAmount
      },
      quantity: 1
    }
  ],
  metadata: {
    participant_id: participantDocId,
    stack_id: stackRef.id,
    organiser_id: stack.organiser_id || '',
    amount_original_share_cents: String(unitAmount)
  },
  success_url: 'https://splitstack.com/success?session_id={CHECKOUT_SESSION_ID}',
  cancel_url: 'https://splitstack.com/cancel'
});

console.log("✅ Stripe session created:", session.id);

// -------------------------
// SAVE CHECKOUT SESSION
// -------------------------

await participantRef.update({
  checkout_session_id: session.id
});

console.log("✅ Saved checkout session");

// -------------------------
// SEND SMS (TWILIO)
// -------------------------

const paymentLink = session.url;

console.log("📲 SMS TARGET:", participant.phone);
console.log("🔗 PAYMENT LINK:", paymentLink);

if (!paymentLink) {
  console.log("❌ ERROR: session.url is NULL");
}

if (!participant.phone) {
  console.log("⚠️ No phone number — SMS skipped");
}

if (participant.phone && paymentLink) {
  try {
    await client.messages.create({
      body: `💸 SplitStack Payment Request
```

Hi ${participant.name || ''},

Pay your share here:
${paymentLink}`,
from: process.env.TWILIO_PHONE_NUMBER,
to: participant.phone
});

```
    console.log("✅ SMS SENT SUCCESSFULLY");

  } catch (smsError) {
    console.error("❌ SMS FAILED:", smsError.message);
  }
}

// -------------------------
// RETURN
// -------------------------

return res.status(200).json({
  checkoutUrl: session.url,
  checkout_url: session.url,
  url: session.url
});
```

} catch (err) {

```
console.error("❌ ERROR:", err);

return res.status(500).json({
  error: 'Failed to create checkout session',
  detail: err.message,
});
```

}

};

