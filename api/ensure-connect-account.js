import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default async function handler(req, res) {
  try {
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const { organiser_id } = req.body;

    if (!organiser_id) {
      return res.status(400).json({ error: 'Missing organiser_id' });
    }

    // TEMP: Always create account (we refine later)
    const account = await stripe.accounts.create({
      type: 'custom',
      country: 'AU',
      capabilities: {
        transfers: { requested: true },
        card_payments: { requested: true },
      },
    });

    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: 'https://splitstack.app/refresh',
      return_url: 'https://splitstack.app/return',
      type: 'account_onboarding',
    });

    return res.status(200).json({
      status: 'needs_onboarding',
      onboarding_url: accountLink.url,
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({
      error: err.message,
    });
  }
}
