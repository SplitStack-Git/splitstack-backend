'use strict';

const admin = require('firebase-admin');
const Stripe = require('stripe');

// -------- Firebase Admin init --------
function initFirebaseAdmin() {
  if (admin.apps.length) return;

  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_B64;
  if (!base64) throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_B64");

  const json = Buffer.from(base64, "base64").toString("utf8");
  const serviceAccount = JSON.parse(json);

console.log("🔥 SERVICE ACCOUNT PROJECT:", serviceAccount.project_id);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id, // 🔥 force correct project binding
  });
}

// -------- Helpers --------
async function readJsonBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;

  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString('utf8').trim();
  if (!raw) return {};
  return JSON.parse(raw);
}

function toStripeAmountCents(amount) {
  const n = typeof amount === 'string' ? Number(amount) : amount;
  if (!Number.isFinite(n)) throw new Error('Invalid participant amount');
  const cents = Math.round(n * 100);
  if (cents <= 0) throw new Error('Amount must be > 0');
  return cents;
}

function pickParticipant(participants, index) {
  if (!Array.isArray(participants)) return null;
  if (index === undefined) return null;
  const i = Number(index);
  if (!Number.isInteger(i) || i < 0 || i >= participants.length) return null;
  return participants[i];
}

// -------- Main --------
module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(204).send('');
  if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });

  try {
    initFirebaseAdmin();

    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
      apiVersion: '2024-06-20',
    });

    const body = await readJsonBody(req);
    const { stack_id, participant_index } = body;

    if (!stack_id) {
      return res.status(400).json({ error: 'stack_id required' });
    }

    const db = admin.firestore();

    const stackRef = db.collection('Stack').doc(String(stack_id));
    const stackSnap = await stackRef.get();

    if (!stackSnap.exists) {
      return res.status(404).json({ error: 'Stack not found' });
    }

    const stack = stackSnap.data();

    // 🔎 Get organiser UID from Stack
    const organiserId = stack.userID || stack.organiser_id || stack.organiserId;

    if (!organiserId) {
      return res.status(400).json({ error: 'Missing organiser_id on Stack' });
    }

    // 🔎 Load organiser document (source of truth)
    const organiserSnap = await db.collection('organisers')
      .doc(String(organiserId))
      .get();

    if (!organiserSnap.exists) {
      return res.status(400).json({ error: 'Organiser record not found' });
    }

    const organiserData = organiserSnap.data();
    const destinationAccount = (organiserData.stripe_connect_account_id || '').trim();

    if (!destinationAccount) {
      return res.status(400).json({ error: 'Missing stripe_connect_account_id' });
    }

    // 🔐 Validate Stripe account
    let account;
    try {
      account = await stripe.accounts.retrieve(destinationAccount);
    } catch (err) {
      return res.status(400).json({
        error: 'Stripe account does not exist or cannot be retrieved',
        detail: err.message,
      });
    }

    if (!account?.charges_enabled) {
      return res.status(400).json({
        error: 'Stripe account not ready for charges',
      });
    }

    const participant = pickParticipant(stack.participants, participant_index);
    if (!participant) {
      return res.status(404).json({ error: 'Participant not found' });
    }

    const unitAmount = toStripeAmountCents(participant.amount);
    const currency = (stack.currency || 'aud').toLowerCase();

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      payment_intent_data: {
        transfer_data: {
          destination: destinationAccount,
        },
        metadata: {
          stack_id: String(stack_id),
          participant_index: String(participant_index),
        },
      },
      line_items: [
        {
          price_data: {
            currency,
            product_data: {
              name: `SplitStack — ${stack.stackFor || 'Payment'}`,
            },
            unit_amount: unitAmount,
          },
          quantity: 1,
        },
      ],
      success_url: 'https://splitstack.com/success?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: 'https://splitstack.com/cancel',
    });

    return res.status(200).json({ checkout_url: session.url });

  } catch (err) {
    return res.status(500).json({
      error: 'Failed to create checkout session',
      detail: err.message,
    });
  }
};

