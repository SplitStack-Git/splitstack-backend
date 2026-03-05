const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      JSON.parse(
  Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_KEY, 'base64').toString('utf8')
)
    ),
  });
}

const db = admin.firestore();

module.exports = async (req, res) => {
  try {
    const { userId, email } = req.body;

    if (!userId || !email) {
      return res.status(400).json({ error: 'Missing userId or email' });
    }

    // 1️⃣ Create Stripe Connect Custom account
    const account = await stripe.accounts.create({
      type: 'custom',
      country: 'AU',
      email: email,
      capabilities: {
        transfers: { requested: true },
        card_payments: { requested: true },
      },
    });

    // 2️⃣ Store stripe_account_id on user document
    await db.collection('users').doc(userId).update({
      stripe_account_id: account.id,
      stripe_onboarding_complete: false,
      stripe_details_submitted: false,
      stripe_charges_enabled: false,
      stripe_payouts_enabled: false,
    });

    return res.status(200).json({
      message: 'Connect account created',
      accountId: account.id,
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
};
