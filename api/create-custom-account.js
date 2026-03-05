'use strict';

const admin = require('firebase-admin');
const Stripe = require('stripe');

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(
      process.env.FIREBASE_SERVICE_ACCOUNT_B64,
      'base64'
    ).toString('utf8')
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
});

module.exports = async (req, res) => {
  try {
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'POST only' });
    }

    const {
      userId,
      onbFirstName,
      onbLastName,
      onbEmail,
      onbPhone,
      onbDob,
      onbStreet1,
      onbStreet2,
      onbCity,
      onbState,
      onbPostcode,
      onbCountry,
      onbAccountHolderName,
      onbBsb,
      onbAccountNumber,
      onbUsage,
      onbConsentAccepted,
    } = req.body || {};

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    if (!onbConsentAccepted) {
      return res.status(400).json({ error: 'Consent not accepted' });
    }

    if (!onbFirstName || !onbLastName || !onbEmail) {
      return res.status(400).json({ error: 'Missing required personal details' });
    }

    // Convert DOB
    const dobDate = new Date(onbDob);

    // Create Stripe Custom account
    const account = await stripe.accounts.create({
      type: 'custom',
      country: 'AU',
      email: onbEmail,
      business_type: 'individual',
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      individual: {
        first_name: onbFirstName,
        last_name: onbLastName,
        email: onbEmail,
        phone: onbPhone || undefined,
        dob: {
          day: dobDate.getUTCDate(),
          month: dobDate.getUTCMonth() + 1,
          year: dobDate.getUTCFullYear(),
        },
        address: {
          line1: onbStreet1,
          line2: onbStreet2 || undefined,
          city: onbCity,
          state: onbState,
          postal_code: onbPostcode,
          country: onbCountry || 'AU',
        },
      },
      tos_acceptance: {
        date: Math.floor(Date.now() / 1000),
        ip: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
      },
      metadata: {
        userId,
        usage: onbUsage || '',
      },
    });

    // Attach external bank account (AU)
    await stripe.accounts.createExternalAccount(account.id, {
      external_account: {
        object: 'bank_account',
        country: 'AU',
        currency: 'aud',
        account_holder_name: onbAccountHolderName,
        account_holder_type: 'individual',
        routing_number: onbBsb,
        account_number: onbAccountNumber,
      },
    });

    // Save to Firestore
    await db.collection('users').doc(userId).set(
      {
        stripe_connect_account_id: account.id,
        stripe_connect_status: 'created',
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return res.status(200).json({
      accountId: account.id,
      chargesEnabled: account.charges_enabled,
      payoutsEnabled: account.payouts_enabled,
      requirements: account.requirements,
    });

  } catch (error) {
    console.error('create-custom-account error:', error);
    return res.status(500).json({
      error: 'Server error',
      detail: error.message,
    });
  }
};

