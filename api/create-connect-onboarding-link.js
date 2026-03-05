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

    const userSnap = await db.collection('users').doc(userId).get();

    if (!userSnap.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userSnap.data();
    const stripeAccountId = userData.stripe_account_id;

    if (!stripeAccountId) {
      return res.status(400).json({ error: 'User has no Stripe account yet' });
    }

    const accountLink = await stripe.accountLinks.create({
      account: stripeAccountId,
      refresh_url: process.env.CONNECT_REFRESH_URL,
      return_url: process.env.CONNECT_RETURN_URL,
      type: 'account_onboarding',
    });

    return res.status(200).json({
      onboarding_url: accountLink.url,
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
};
