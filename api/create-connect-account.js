const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      JSON.parse(
        Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString('utf8')
      )
    ),
  });
}

const db = admin.firestore();

module.exports = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    const userRef = db.collection('users').doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userSnap.data();
    const email = userData.email;

    if (!email) {
      return res.status(400).json({ error: 'User email missing in database' });
    }

    // 🔒 =========================
    // REUSE EXISTING ACCOUNT
    // =========================

    if (userData.stripe_account_id) {
      console.log("🔒 Reusing existing Stripe account:", userData.stripe_account_id);

      return res.status(200).json({
        message: 'Existing account reused',
        accountId: userData.stripe_account_id,
      });
    }

    // 🚀 =========================
    // CREATE NEW ACCOUNT (ONLY ONCE)
    // =========================

    const account = await stripe.accounts.create({
      type: 'custom',
      country: 'AU',
      email: email,
      capabilities: {
        transfers: { requested: true },
        card_payments: { requested: true },
      },
    });

    console.log("🆕 Created new Stripe account:", account.id);

    // 💾 Save to Firestore

    await userRef.update({
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
