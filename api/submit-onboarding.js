import Stripe from "stripe";
import admin from "firebase-admin";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Firebase init
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, "base64").toString("utf8")
  );

  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

export default async function handler(req, res) {
  try {
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
    } = req.body;

    if (!userId) {
      return res.status(400).json({ status: "error", message: "Missing userId" });
    }

    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ status: "error", message: "User not found" });
    }

    let stripeAccountId = userSnap.data().stripe_account_id;

    // Create Stripe account if not exists
    if (!stripeAccountId) {
      const account = await stripe.accounts.create({
        type: "custom",
        country: "AU",
        email: onbEmail,
      });

      stripeAccountId = account.id;

      await userRef.update({
        stripe_account_id: stripeAccountId,
      });
    }

    // Update Stripe account
    await stripe.accounts.update(stripeAccountId, {
      business_type: "individual",
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      individual: {
        first_name: onbFirstName,
        last_name: onbLastName,
        email: onbEmail,
        phone: onbPhone,
        dob: {
          day: new Date(onbDob).getDate(),
          month: new Date(onbDob).getMonth() + 1,
          year: new Date(onbDob).getFullYear(),
        },
        address: {
          line1: onbStreet1,
          line2: onbStreet2 || "",
          city: onbCity,
          state: onbState,
          postal_code: onbPostcode,
          country: onbCountry || "AU",
        },
      },
      external_account: {
        object: "bank_account",
        country: "AU",
        currency: "aud",
        account_holder_name: onbAccountHolderName,
        account_holder_type: "individual",
        routing_number: onbBsb,
        account_number: onbAccountNumber,
      },
    });

    // Update Firestore
    await userRef.update({
      stripe_onboarding_complete: true,
      stripe_details_submitted: true,
      onb_usage: onbUsage,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(200).json({
      status: "success",
    });

  } catch (error) {
    console.error("Onboarding error:", error);

    return res.status(500).json({
      status: "error",
      message: error.message,
    });
  }
}
