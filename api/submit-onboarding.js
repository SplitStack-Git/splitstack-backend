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
    const {
      currentUserId,
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
      onbConsentAccepted
    } = req.body || {};

    if (!currentUserId) {
      return res.status(400).json({ error: 'Missing currentUserId' });
    }

    if (!onbConsentAccepted) {
      return res.status(400).json({ error: 'Verification consent not accepted' });
    }

    const userRef = db.collection('users').doc(currentUserId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userSnap.data();
    const stripeAccountId = userData.stripe_account_id;

    if (!stripeAccountId) {
      return res.status(400).json({ error: 'Stripe account missing' });
    }

    if (!onbDob) {
      return res.status(400).json({ error: 'Missing onbDob' });
    }

    const dob = new Date(onbDob);

    if (Number.isNaN(dob.getTime())) {
      return res.status(400).json({ error: 'Invalid onbDob' });
    }

    const dobDay = dob.getUTCDate();
    const dobMonth = dob.getUTCMonth() + 1;
    const dobYear = dob.getUTCFullYear();

    await stripe.accounts.update(stripeAccountId, {
      business_type: 'individual',

      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },

      email: onbEmail,

      individual: {
        first_name: onbFirstName,
        last_name: onbLastName,
        email: onbEmail,
        phone: onbPhone,
        dob: {
          day: dobDay,
          month: dobMonth,
          year: dobYear,
        },
        address: {
          line1: onbStreet1,
          line2: onbStreet2 || undefined,
          city: onbCity,
          state: onbState,
          postal_code: onbPostcode,
          country: 'AU',
        },
      },

      external_account: {
        object: 'bank_account',
        country: 'AU',
        currency: 'aud',
        account_holder_name: onbAccountHolderName,
        account_holder_type: 'individual',
        routing_number: (onbBsb || '').replace(/\D/g, ''),
        account_number: onbAccountNumber,
      },

      metadata: {
        usage: onbUsage || '',
      },

      tos_acceptance: {
        date: Math.floor(Date.now() / 1000),
        ip:
          req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
          req.socket?.remoteAddress ||
          undefined,
      },
    });

    const account = await stripe.accounts.retrieve(stripeAccountId);

    await userRef.update({
      name: [onbFirstName, onbLastName].filter(Boolean).join(' ').trim(),
      phone: onbPhone || null,
      email: onbEmail || null,
      country: onbCountry || 'AU',
      date_of_birth: admin.firestore.Timestamp.fromDate(dob),

      stripe_details_submitted: account.details_submitted || false,
      stripe_onboarding_complete: account.details_submitted || false,
      stripe_payouts_enabled: account.capabilities?.transfers === 'active',

      onb_usage: onbUsage || '',
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(200).json({
      success: true,
      stripe_account_id: stripeAccountId,
    });

} catch (err) {
  console.error('submit-onboarding error:', err);
  console.error('Stripe error (raw):', err?.raw);
  console.error('Stripe error (full):', JSON.stringify(err, null, 2));

  return res.status(500).json({
    error: err?.raw?.message || err.message || 'Failed to submit onboarding',
  });
}
