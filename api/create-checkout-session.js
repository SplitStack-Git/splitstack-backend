'use strict';

const admin = require('firebase-admin');
const Stripe = require('stripe');

function initFirebaseAdmin() {
  if (admin.apps.length) return;

  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_B64;
  if (!base64) throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_B64");

  const json = Buffer.from(base64, "base64").toString("utf8");
  const serviceAccount = JSON.parse(json);

  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

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

  console.log("🔥 VERSION: FINAL FIX DEPLOYED");

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

    console.log("👤 Participant:", participantDocId);

    if (participant.paid_status === true) {
      return res.status(400).json({ error: 'Participant already paid' });
    }

    // -------------------------
    // LOAD STACK (SAFE)
    // -------------------------

    let stackPath = participant.stack_id;

    if (!stackPath || typeof stackPath !== 'string') {
      return res.status(400).json({ error: 'Invalid stack_id on participant' });
    }

    // remove leading slash if exists
    if (stackPath.startsWith('/')) {
      stackPath = stackPath.slice(1);
    }

    console.log("📦 Stack path:", stackPath);

    const stackRef = db.doc(stackPath);
    const stackSnap = await stackRef.get();

    if (!stackSnap.exists) {
      return res.status(404).json({ error: 'Stack not found' });
    }

    const stack = stackSnap.data();

    // -------------------------
    // FIND ORGANISER (SAFE)
    // -------------------------

    const organiserQuery = await db
      .collection('participants')
      .where('stack_id', '==', participant.stack_id)
      .where('isOrganiser', '==', true)
      .limit(1)
      .get();

    if (organiserQuery.empty) {
      return res.status(400).json({ error: 'Organiser not found' });
    }

    const organiserDoc = organiserQuery.docs[0];
    const organiser = organiserDoc.data();

    console.log("👑 Organiser doc:", organiserDoc.id);

    if (!organiser.userID || organiser.userID.trim() === "") {
      return res.status(400).json({
        error: 'Organiser missing userID (CRITICAL)',
        debug: organiser
      });
    }

    // -------------------------
    // LOAD USER
    // -------------------------

    const userDocRef = db.collection('users').doc(String(organiser.userID));
    const userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      return res.status(400).json({
        error: 'User not found for organiser',
        userID: organiser.userID
      });
    }

    const organiserStripeAccountId = userDoc.data().stripe_account_id;

    if (!organiserStripeAccountId) {
      return res.status(400).json({
        error: 'Organiser missing stripe_account_id',
        user: userDoc.data()
      });
    }

    console.log("💰 Stripe account:", organiserStripeAccountId);

    // -------------------------
    // PAYMENT DETAILS
    // -------------------------

    const currency = (participant.currency || stack.currency || 'aud').toLowerCase();

    let unitAmount = participant.amount_to_pay_cents;

    if (!unitAmount) {
      if (!participant.amount) {
        return res.status(400).json({ error: 'Participant amount missing' });
      }
      unitAmount = Math.round(Number(participant.amount) * 100);
    }

    if (!unitAmount || isNaN(unitAmount) || unitAmount <= 0) {
      return res.status(400).json({ error: 'Invalid amount' });
    }

    // -------------------------
    // CREATE STRIPE SESSION
    // -------------------------

    const session = await stripe.checkout.sessions.create(
      {
        mode: 'payment',
        payment_method_types: ['card'],

        line_items: [
          {
            price_data: {
              currency,
              product_data: {
                name: `SplitStack - ${stack.title || 'Payment'}`
              },
              unit_amount: unitAmount
            },
            quantity: 1
          }
        ],

        payment_intent_data: {
          transfer_data: {
            destination: organiserStripeAccountId
          }
        },

        metadata: {
          participant_id: participantDocId,
          stack_id: stackRef.id,
          organiser_id: organiser.userID,
          amount_original_share_cents: String(unitAmount)
        },

        success_url: 'https://app.splitstack.com.au/paymentSuccess',
        cancel_url: 'https://app.splitstack.com.au/paymentCancel'
      },
      {
        idempotencyKey: `checkout_${participantDocId}_${Date.now()}`
      }
    );

    // -------------------------
    // SAVE SESSION
    // -------------------------

    await participantRef.update({
      checkout_session_id: session.id
    });

    return res.status(200).json({
      checkoutUrl: session.url,
      url: session.url
    });

  } catch (err) {

    console.error("❌ ERROR:", err);

    return res.status(500).json({
      error: 'Failed to create checkout session',
      detail: err.message,
    });

  }

};
