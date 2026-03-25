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


// ✅ GLOBAL PHONE FORMATTER (E.164)
function formatPhone(phone, country) {
  if (!phone) return phone;

  const cleaned = phone.replace(/\D/g, "");

  if (phone.startsWith("+")) return phone;

  switch (country) {
    case "AU":
      return cleaned.startsWith("0") ? "+61" + cleaned.slice(1) : "+61" + cleaned;

    case "US":
    case "CA":
      return "+1" + cleaned;

    case "GB":
      return cleaned.startsWith("0") ? "+44" + cleaned.slice(1) : "+44" + cleaned;

    case "NZ":
      return cleaned.startsWith("0") ? "+64" + cleaned.slice(1) : "+64" + cleaned;

    case "IE":
      return cleaned.startsWith("0") ? "+353" + cleaned.slice(1) : "+353" + cleaned;

    case "SG":
      return "+65" + cleaned;

    case "NL":
      return cleaned.startsWith("0") ? "+31" + cleaned.slice(1) : "+31" + cleaned;

    case "DE":
      return cleaned.startsWith("0") ? "+49" + cleaned.slice(1) : "+49" + cleaned;

    case "FR":
      return cleaned.startsWith("0") ? "+33" + cleaned.slice(1) : "+33" + cleaned;

    default:
      return "+" + cleaned;
  }
}


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

    // ✅ Validate
    if (!userId) {
      console.error("❌ Missing userId");
      return res.status(400).json({
        status: "error",
        message: "Missing userId",
      });
    }

    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({
        status: "error",
        message: "User not found",
      });
    }

    let stripeAccountId = userSnap.data().stripe_account_id || null;

    // ✅ CREATE STRIPE ACCOUNT (ONLY IF NONE EXISTS)
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

      await userRef.update({
        stripe_account_id: stripeAccountId,
      });
    }

    // ✅ ALWAYS UPDATE PARTICIPANTS (ORGANISER)
    const participantsSnap = await db
      .collection("participants")
      .where("userID", "==", userId)
      .where("isOrganiser", "==", true)
      .get();

    console.log("👀 Organiser docs found:", participantsSnap.size);

    for (const doc of participantsSnap.docs) {
      await doc.ref.update({
        stripe_account_id: stripeAccountId,
      });
    }

    // ✅ FORMAT PHONE
    const formattedPhone = formatPhone(onbPhone, onbCountry);

    // ✅ BUILD UPDATE OBJECT (KEEP YOUR STRUCTURE)
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

      // 🔥 THIS IS WHAT YOU WERE MISSING
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

    // ✅ ONLY ADD BANK FOR AU (KEEP YOUR LOGIC)
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

    // ✅ UPDATE STRIPE
    await stripe.accounts.update(stripeAccountId, updatePayload);

    // ✅ UPDATE USER RECORD
    await userRef.update({
      stripe_onboarding_complete: true,
      stripe_details_submitted: true,
      onb_usage: onbUsage,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

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
