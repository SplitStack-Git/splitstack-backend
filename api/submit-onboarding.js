import Stripe from "stripe";
import admin from "firebase-admin";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* ================================
   FIREBASE INIT
================================ */

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

/* ================================
   🌍 GLOBAL PHONE FORMATTER (FIXED)
   Handles ANY format → E.164
================================ */

function formatPhone(phone, country = "AU") {
  if (!phone) return null;

  // Remove EVERYTHING except digits
  let cleaned = phone.replace(/\D/g, "");

  // If already includes country code (e.g. 614..., 1415...)
  if (cleaned.startsWith("61") || cleaned.startsWith("1")) {
    return "+" + cleaned;
  }

  switch (country) {
    case "AU":
      if (cleaned.startsWith("0")) cleaned = cleaned.slice(1);
      return "+61" + cleaned;

    case "US":
    case "CA":
      return "+1" + cleaned;

    case "GB":
      if (cleaned.startsWith("0")) cleaned = cleaned.slice(1);
      return "+44" + cleaned;

    case "NZ":
      if (cleaned.startsWith("0")) cleaned = cleaned.slice(1);
      return "+64" + cleaned;

    case "IE":
      if (cleaned.startsWith("0")) cleaned = cleaned.slice(1);
      return "+353" + cleaned;

    default:
      return "+" + cleaned;
  }
}

/* ================================
   HANDLER
================================ */

export default async function handler(req, res) {
  console.log("🔥 SUBMIT ONBOARDING HIT");
  console.log("BODY:", req.body);

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
      return res.status(400).json({
        status: "error",
        message: "Missing userId",
      });
    }

    const userRef = db.collection("users").doc(userId);

    /* ================================
       🔥 HARD GUARANTEE USER EXISTS
    ================================ */

    await userRef.set({
      uid: userId,
      email: onbEmail || null,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // 🔥 ALWAYS RELOAD AFTER WRITE (CRITICAL FIX)
    const freshUserSnap = await userRef.get();
    let stripeAccountId = freshUserSnap.data().stripe_account_id || null;

    /* ================================
       CREATE STRIPE ACCOUNT IF NEEDED
    ================================ */

    if (!stripeAccountId) {
      console.log("🔥 Creating Stripe account...");

      const account = await stripe.accounts.create({
        type: "custom",
        country: onbCountry || "AU",
        email: onbEmail,
        business_type: "individual",
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
      });

      stripeAccountId = account.id;

      console.log("✅ Stripe account created:", stripeAccountId);

      await userRef.set({
        stripe_account_id: stripeAccountId,
      }, { merge: true });
    }

    /* ================================
       🔥 SYNC ORGANISER PARTICIPANTS
    ================================ */

    const participantsSnap = await db
      .collection("participants")
      .where("userID", "==", userId)
      .where("isOrganiser", "==", true)
      .get();

    console.log("👀 Organiser docs found:", participantsSnap.size);

    for (const doc of participantsSnap.docs) {
      await doc.ref.set({
        stripe_account_id: stripeAccountId,
      }, { merge: true });
    }

    /* ================================
       FORMAT PHONE (FIXED)
    ================================ */

    const formattedPhone = formatPhone(onbPhone, onbCountry);

    console.log("📞 Formatted phone:", formattedPhone);

    /* ================================
       STRIPE UPDATE
    ================================ */

    const updatePayload = {
      business_type: "individual",

      individual: {
        first_name: onbFirstName,
        last_name: onbLastName,
        email: onbEmail,
        phone: formattedPhone,

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

      business_profile: {
        mcc: "5734",
        url: "https://splitstack.app",
        product_description:
          "SplitStack enables users to split bills and collect payments from friends",
      },

      tos_acceptance: {
        date: Math.floor(Date.now() / 1000),
        ip:
          req.headers["x-forwarded-for"] ||
          req.socket?.remoteAddress ||
          "0.0.0.0",
      },
    };

    /* ================================
       BANK DETAILS (AU ONLY)
    ================================ */

    if (onbCountry === "AU") {
      updatePayload.external_account = {
        object: "bank_account",
        country: "AU",
        currency: "aud",
        account_holder_name: onbAccountHolderName,
        account_holder_type: "individual",
        routing_number: onbBsb,
        account_number: onbAccountNumber,
      };
    }

    await stripe.accounts.update(stripeAccountId, updatePayload);

    /* ================================
       FINAL USER UPDATE
    ================================ */

    await userRef.set({
      stripe_onboarding_complete: true,
      stripe_details_submitted: true,
      onb_usage: onbUsage,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log("✅ Onboarding complete");

    return res.status(200).json({
      status: "success",
    });

  } catch (error) {
    console.error("❌ Onboarding error:", error);

    return res.status(500).json({
      status: "error",
      message: error.message,
    });
  }
}
