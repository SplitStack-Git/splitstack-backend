'use strict';

const admin = require('firebase-admin');
const Stripe = require('stripe');

function initFirebaseAdmin() {
  if (admin.apps.length) return;

  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_B64;
  if (!base64) throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_B64");

  const json = Buffer.from(base64, "base64").toString("utf8");
  const serviceAccount = JSON.parse(json);

serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');

console.log("PROJECT:", serviceAccount.project_id);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
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
    const { participant_id } = body;

    if (!participant_id) {
      return res.status(400).json({ error: 'participant_id required' });
    }

    const db = admin.firestore();

    // Load participant
    const participantRef = db.collection('participants').doc(String(participant_id));
    const participantSnap = await participantRef.get();

    if (!participantSnap.exists) {
      return res.status(404).json({ error: 'Participant not found' });
    }

    const participant = participantSnap.data();

    // Load stack
    const stackRef = db.collection('stacks').doc(String(participant.stack_id));
    const stackSnap = await stackRef.get();

    if (!stackSnap.exists) {
      return res.status(404).json({ error: 'Stack not found' });
    }

    const stack = stackSnap.data();

    // Load organiser
    const organiserRef = db.collection('users').doc(String(stack.organiser_user_id));
    const organiserSnap = await organiserRef.get();

    if (!organiserSnap.exists) {
      return res.status(404).json({ error: 'Organiser not found' });
    }

    const organiser = organiserSnap.data();
    const stripeAccountId = organiser.stripe_account_id;

    if (!stripeAccountId) {
      return res.status(400).json({ error: 'Organiser has no Stripe account' });
    }

    const currency = (participant.currency || stack.currency || 'aud').toLowerCase();
    const unitAmount = participant.amount_to_pay_cents;

    if (!unitAmount) {
      return res.status(400).json({ error: 'Participant amount missing' });
    }

    const session = await stripe.checkout.sessions.create({

      mode: 'payment',

      line_items: [
        {
          price_data: {
            currency,
            product_data: {
              name: `SplitStack — ${stack.title || 'Payment'}`,
            },
            unit_amount: unitAmount,
          },
          quantity: 1,
        },
      ],

      metadata: {
        participant_id: String(participant_id),
        stack_id: String(participant.stack_id),
        organiser_user_id: String(stack.organiser_user_id),
        amount_original_share_cents: String(participant.amount_original_share_cents)
      },

      success_url: 'https://splitstack.com/success?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: 'https://splitstack.com/cancel',
    });

    // Save checkout session ID
    await participantRef.update({
      checkout_session_id: session.id
    });

    return res.status(200).json({
      checkout_url: session.url
    });

  } catch (err) {

    return res.status(500).json({
      error: 'Failed to create checkout session',
      detail: err.message,
    });

  }
};
