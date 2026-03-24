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
      return res.status(400).json({ error: 'Consent not accepted' });
    }

    if (!onbDob) {
      return res.status(400).json({ error: 'Missing DOB' });
    }

    // -------------------------
    // FIND ORGANISER (PARTICIPANTS)
    // -------------------------

    const organiserSnap = await db
      .collection('participants')
      .where('userID', '==', currentUserId)
      .where('isOrganiser', '==', true)
      .limit(1)
      .get();

    if (organiserSnap.empty) {
      return res.status(404).json({ error: 'Organiser not found in participants' });
    }

    const organiserDoc = organiserSnap.docs[0];
    const organiserRef = organiserDoc.ref;
    const organiserData = organiserDoc.data();

    const stripeAccountId = organiserData.stripe_account_id;

    if (!stripeAccountId) {
      return res.status(400).json({ error: 'Missing stripe_account_id on participant' });
    }

    // -------------------------
    // FORMAT DOB
    // -------------------------

    const dob = new Date(onbDob);

    if (Number.isNaN(dob.getTime())) {
      return res.status(400).json({ error: 'Invalid DOB format' });
    }

    const dobDay = dob.getUTCDate();
    const dobMonth = dob.getUTCMonth() + 1;
    const dobYear = dob.getUTCFullYear();

    // -------------------------
    // UPDATE STRIPE ACCOUNT
    // -------------------------

     let accountId = stripeAccountId;

if (!accountId) {
  const account = await stripe.accounts.create({
    type: 'custom',
    country: 'AU',
    email: onbEmail,
    capabilities: {
      card_payments: { requested: true },
      transfers: { requested: true },
    },
  });

  accountId = account.id;

  // SAVE THIS TO FIRESTORE (IMPORTANT)
  await organiserRef.update({
    stripe_account_id: accountId,
  });
}   
      await stripe.accounts.update(accountId, {
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

    // -------------------------
    // UPDATE PARTICIPANT (NOT USERS)
    // -------------------------

    await organiserRef.update({
      stripe_onboarding_complete: true,
      stripe_payouts_enabled: true,
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
};
