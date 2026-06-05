// api/test-onboarding.js
// ⚠️  TEST ONLY — no Firebase, uses in-memory store

import Stripe from "stripe";
import { Readable } from "stream";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const memStore = {};

/* ── Phone → E.164 ─────────────────────────────────────────── */

function formatPhone(phone, country = "AU") {
    if (!phone) return null;
    let d = phone.replace(/\D/g, "");
    const prefixes = { AU: "61", US: "1", CA: "1", GB: "44", NZ: "64" };
    const cc = prefixes[country];
    if (cc && d.startsWith(cc)) return "+" + d;
    if (d.startsWith("0")) d = d.slice(1);
    return cc ? `+${cc}${d}` : `+${d}`;
}

/* ── Bank config ───────────────────────────────────────────── */

const BANK_CONFIG = {
    AU: { currency: "aud", useRouting: true },
    NZ: { currency: "nzd", useRouting: false },
    US: { currency: "usd", useRouting: true },
    CA: { currency: "cad", useRouting: true },
    GB: { currency: "gbp", useRouting: true },
};

/* ── Upload a base64 image to Stripe Files API ─────────────── */

async function uploadDocumentToStripe(base64, mimeType, purpose) {
    const buffer = Buffer.from(base64, "base64");
    const stream = new Readable();
    stream.push(buffer);
    stream.push(null);

    const ext = { "image/jpeg": "jpg", "image/png": "png", "application/pdf": "pdf" };
    stream.name = `document.${ext[mimeType] ?? "jpg"}`;
    stream.size = buffer.length;

    const file = await stripe.files.create({
        purpose,
        file: { data: stream, name: stream.name, type: mimeType },
    });

    return file.id;
}

/* ── Derive onboarding status ──────────────────────────────── */

function deriveStatus(account) {
    const currentlyDue = account.requirements?.currently_due ?? [];
    const disabledReason = account.requirements?.disabled_reason ?? null;
    const pendingVerification = account.requirements?.pending_verification ?? [];

    if (account.charges_enabled && account.payouts_enabled && currentlyDue.length === 0) {
        return "complete";
    }
    if (pendingVerification.length > 0) return "pending_verification";
    if (disabledReason) return "restricted";
    if (account.details_submitted) return "pending";
    return "not_started";
}

/* ── Handler ───────────────────────────────────────────────── */

export default async function handler(req, res) {
    if (req.method !== "POST") {
        return res.status(405).json({ error: "Method not allowed" });
    }

    if (req.body?.action === "dump") {
        return res.status(200).json({ store: memStore });
    }
    if (req.body?.action === "reset" && req.body?.userId) {
        delete memStore[req.body.userId];
        return res.status(200).json({ reset: true, userId: req.body.userId });
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
        onbCountry = "AU",

        // Bank
        onbAccountHolderName,
        onbRoutingNumber,
        onbAccountNumber,

        // Identity
        onbIdNumber,
        onbSsnLast4,
        onbJobTitle,

        // Document upload
        onbDocFrontBase64,
        onbDocBackBase64,
        onbDocMimeType = "image/jpeg",
        onbDocType = "identity_document",
    } = req.body;

    if (!userId) return res.status(400).json({ error: "Missing userId" });
    if (!BANK_CONFIG[onbCountry]) {
        return res.status(400).json({ error: `Unsupported country: ${onbCountry}` });
    }

    try {
        if (!memStore[userId]) memStore[userId] = { userId, stripeAccountId: null };
        const user = memStore[userId];

        console.log("\n─────────────────────────────────────");
        console.log("👤 User:", userId, "| 🌍 Country:", onbCountry);
        console.log("💾 Existing account:", user.stripeAccountId || "none");

        // ── Create Stripe account if needed ───────────────────────
        if (!user.stripeAccountId) {
            const account = await stripe.accounts.create({
                type: "custom", country: onbCountry, email: onbEmail,
                business_type: "individual",
                capabilities: { card_payments: { requested: true }, transfers: { requested: true } },
            });
            user.stripeAccountId = account.id;
            console.log("✅ Stripe account created:", account.id);
        } else {
            console.log("♻️  Reusing:", user.stripeAccountId);
        }

        // ── Build individual block ─────────────────────────────────
        const dob = new Date(onbDob);
        const individual = {
            first_name: onbFirstName,
            last_name: onbLastName,
            email: onbEmail,
            phone: formatPhone(onbPhone, onbCountry),
            dob: {
                day: dob.getUTCDate(),
                month: dob.getUTCMonth() + 1,
                year: dob.getUTCFullYear(),
            },
            address: {
                line1: onbStreet1, line2: onbStreet2 || "",
                city: onbCity, state: onbState,
                postal_code: onbPostcode, country: onbCountry,
            },
        };

        if (onbCountry === "AU" && onbIdNumber) individual.id_number = onbIdNumber;
        if (onbCountry === "US") {
            if (onbSsnLast4) individual.ssn_last_4 = onbSsnLast4;
            if (onbIdNumber) individual.id_number = onbIdNumber;
        }
        if (onbCountry === "CA") {
            if (onbIdNumber) individual.id_number = onbIdNumber;
            if (onbJobTitle) individual.job_title = onbJobTitle;
        }

        // ── Build update payload ───────────────────────────────────
        const updatePayload = {
            business_type: "individual",
            individual,
            business_profile: {
                mcc: "5734",
                url: "https://splitstack.app",
                product_description: "SplitStack enables users to split bills and collect payments from friends",
            },
            tos_acceptance: {
                date: Math.floor(Date.now() / 1000),
                ip: req.headers["x-forwarded-for"] || req.socket?.remoteAddress || "0.0.0.0",
            },
        };

        // ── Bank account ───────────────────────────────────────────
        const bankCfg = BANK_CONFIG[onbCountry];
        if (onbAccountNumber) {
            const ext = {
                object: "bank_account", country: onbCountry,
                currency: bankCfg.currency,
                account_holder_name: onbAccountHolderName,
                account_holder_type: "individual",
                account_number: onbAccountNumber,
            };
            if (bankCfg.useRouting && onbRoutingNumber) ext.routing_number = onbRoutingNumber;
            updatePayload.external_account = ext;
        }

        // ── Push KYC to Stripe ─────────────────────────────────────
        console.log("📤 Updating Stripe account...");
        let updated = await stripe.accounts.update(user.stripeAccountId, updatePayload);
        console.log("✅ Account updated");

        // ── Document upload (if provided) ──────────────────────────
        let frontFileId = null;
        let backFileId = null;

        if (onbDocFrontBase64) {
            const ALLOWED_MIME = ["image/jpeg", "image/png", "application/pdf"];
            if (!ALLOWED_MIME.includes(onbDocMimeType)) {
                return res.status(400).json({ error: `Invalid onbDocMimeType: ${onbDocMimeType}` });
            }

            console.log("🪪  Uploading document front...");
            frontFileId = await uploadDocumentToStripe(onbDocFrontBase64, onbDocMimeType, onbDocType);
            console.log("✅ Front file ID:", frontFileId);

            if (onbDocBackBase64) {
                console.log("🪪  Uploading document back...");
                backFileId = await uploadDocumentToStripe(onbDocBackBase64, onbDocMimeType, onbDocType);
                console.log("✅ Back file ID:", backFileId);
            }

            const verificationPayload =
                onbDocType === "identity_document"
                    ? { document: { front: frontFileId, ...(backFileId && { back: backFileId }) } }
                    : { additional_document: { front: frontFileId, ...(backFileId && { back: backFileId }) } };

            console.log("🔗 Attaching document to account...");
            updated = await stripe.accounts.update(user.stripeAccountId, {
                individual: { verification: verificationPayload },
            });
            console.log("✅ Document attached");
        }

        // ── Persist to memStore ────────────────────────────────────
        user.chargesEnabled = updated.charges_enabled;
        user.payoutsEnabled = updated.payouts_enabled;
        user.detailsSubmitted = updated.details_submitted;
        user.currentlyDue = updated.requirements?.currently_due ?? [];
        user.eventuallyDue = updated.requirements?.eventually_due ?? [];
        user.pendingVerification = updated.requirements?.pending_verification ?? [];
        user.disabledReason = updated.requirements?.disabled_reason ?? null;

        const onboardingStatus = deriveStatus(updated);

        const requiresDocument =
            user.currentlyDue.some(r => r.includes("verification.document")) ||
            user.eventuallyDue.some(r => r.includes("verification.document"));

        // ── Hints for missing fields ───────────────────────────────
        const hints = [];
        if (onbCountry === "AU" && !onbIdNumber && !onbDocFrontBase64) {
            hints.push("AU: pass onbIdNumber (TFN, '000000000' in test) OR onbDocFrontBase64 to clear document requirement");
        }
        if (onbCountry === "US" && !onbSsnLast4) {
            hints.push("US: pass onbSsnLast4 ('0000' in test) — required to enable charges");
        }
        if (onbCountry === "US" && !onbIdNumber && !onbDocFrontBase64) {
            hints.push("US: pass onbIdNumber (full SSN '000000000') OR onbDocFrontBase64 to clear document requirement");
        }
        if (onbCountry === "CA" && !onbIdNumber) {
            hints.push("CA: pass onbIdNumber (SIN, '000000000' in test)");
        }
        if (onbCountry === "CA" && !onbJobTitle) {
            hints.push("CA: pass onbJobTitle (e.g. 'Software Engineer')");
        }
        if (onbCountry === "NZ" && requiresDocument && !onbDocFrontBase64) {
            hints.push("NZ: pass onbDocFrontBase64 to satisfy document requirement in the same request");
        }

        console.log("💳 charges_enabled:   ", user.chargesEnabled);
        console.log("🔖 onboarding_status: ", onboardingStatus);
        console.log("📋 currently_due:     ", user.currentlyDue);
        console.log("─────────────────────────────────────\n");

        return res.status(200).json({
            status: "success",
            stripe_account_id: user.stripeAccountId,
            onboarding_status: onboardingStatus,
            charges_enabled: user.chargesEnabled,
            payouts_enabled: user.payoutsEnabled,
            details_submitted: user.detailsSubmitted,
            currently_due: user.currentlyDue,
            eventually_due: user.eventuallyDue,
            pending_verification: user.pendingVerification,
            disabled_reason: user.disabledReason,
            requires_document: requiresDocument,
            ...(frontFileId && {
                document_upload: {
                    front_file_id: frontFileId,
                    back_file_id: backFileId,
                    document_type: onbDocType,
                },
            }),
            ...(hints.length > 0 && { _hints: hints }),
            _debug: { store: memStore },
        });

    } catch (err) {
        console.error("❌ Test onboarding error:", err.message);
        if (err.type === "StripeInvalidRequestError") {
            return res.status(400).json({
                error: "Stripe validation error", param: err.param, message: err.message,
            });
        }
        return res.status(500).json({ error: err.message });
    }
}

export const config = {
    api: { bodyParser: { sizeLimit: "12mb" } },
};


// // api/test-onboarding.js
// // ⚠️  TEST ONLY — no Firebase, uses in-memory store
// // Remove or gate behind NODE_ENV check before deploying

// import Stripe from "stripe";

// const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// // In-memory store — persists only while vercel dev is running
// const memStore = {};

// /* ── Phone → E.164 ─────────────────────────────────────────── */

// function formatPhone(phone, country = "AU") {
//     if (!phone) return null;
//     let d = phone.replace(/\D/g, "");
//     const prefixes = { AU: "61", US: "1", CA: "1", GB: "44", NZ: "64" };
//     const cc = prefixes[country];
//     if (cc && d.startsWith(cc)) return "+" + d;
//     if (d.startsWith("0")) d = d.slice(1);
//     return cc ? `+${cc}${d}` : `+${d}`;
// }

// /* ── Handler ───────────────────────────────────────────────── */

// export default async function handler(req, res) {
//     if (req.method !== "POST") {
//         return res.status(405).json({ error: "Method not allowed" });
//     }

//     // ── Special: dump store state ──────────────────────────────
//     // POST { "action": "dump" }  → see all in-memory users
//     if (req.body?.action === "dump") {
//         return res.status(200).json({ store: memStore });
//     }

//     // ── Special: reset a user ──────────────────────────────────
//     // POST { "action": "reset", "userId": "..." }
//     if (req.body?.action === "reset" && req.body?.userId) {
//         delete memStore[req.body.userId];
//         return res.status(200).json({ reset: true, userId: req.body.userId });
//     }

//     const {
//         userId,
//         onbFirstName,
//         onbLastName,
//         onbEmail,
//         onbPhone,
//         onbDob,
//         onbStreet1,
//         onbStreet2,
//         onbCity,
//         onbState,
//         onbPostcode,
//         onbIdNumber,
//         onbCountry = "AU",
//         onbSsnLast4,
//         onbAccountHolderName,
//         onbRoutingNumber,
//         onbAccountNumber,
//     } = req.body;

//     if (!userId) {
//         return res.status(400).json({ error: "Missing userId" });
//     }

//     try {
//         // ── 1. Get or create in-memory user ───────────────────────
//         if (!memStore[userId]) {
//             memStore[userId] = { userId, stripeAccountId: null };
//         }

//         const user = memStore[userId];

//         console.log("\n─────────────────────────────────────");
//         console.log("👤 User:", userId);
//         console.log("💾 Existing stripeAccountId:", user.stripeAccountId || "none");

//         // ── 2. Get or create Stripe Custom account ─────────────────
//         if (!user.stripeAccountId) {
//             console.log("🔧 Creating Stripe account...");

//             const account = await stripe.accounts.create({
//                 type: "custom",
//                 country: onbCountry,
//                 email: onbEmail,
//                 business_type: "individual",
//                 capabilities: {
//                     card_payments: { requested: true },
//                     transfers: { requested: true },
//                 },
//             });

//             user.stripeAccountId = account.id;
//             console.log("✅ Stripe account created:", account.id);
//         } else {
//             console.log("♻️  Reusing existing Stripe account:", user.stripeAccountId);
//         }

//         // ── 3. Build update payload ────────────────────────────────
//         const dob = new Date(onbDob);

//         const updatePayload = {
//             business_type: "individual",
//             individual: {
//                 first_name: onbFirstName,
//                 last_name: onbLastName,
//                 email: onbEmail,
//                 phone: formatPhone(onbPhone, onbCountry),
//                 ...(onbIdNumber && { id_number: onbIdNumber }),
//                 ...(onbCountry === "US" && onbSsnLast4 && { ssn_last_4: onbSsnLast4 }),
//                 dob: {
//                     day: dob.getUTCDate(),
//                     month: dob.getUTCMonth() + 1,
//                     year: dob.getUTCFullYear(),
//                 },
//                 address: {
//                     line1: onbStreet1,
//                     line2: onbStreet2 || "",
//                     city: onbCity,
//                     state: onbState,
//                     postal_code: onbPostcode,
//                     country: onbCountry,
//                 },
//             },
//             business_profile: {
//                 mcc: "5734",
//                 url: "https://splitstack.app",
//                 product_description:
//                     "SplitStack enables users to split bills and collect payments from friends",
//             },
//             tos_acceptance: {
//                 date: Math.floor(Date.now() / 1000),
//                 ip:
//                     req.headers["x-forwarded-for"] ||
//                     req.socket?.remoteAddress ||
//                     "0.0.0.0",
//             },
//         };

//         // ── 4. Bank account ────────────────────────────────────────
//         const BANK_CONFIG = {
//             AU: { currency: "aud", useRouting: true },
//             NZ: { currency: "nzd", useRouting: false },
//             US: { currency: "usd", useRouting: true },
//             CA: { currency: "cad", useRouting: true },
//             GB: { currency: "gbp", useRouting: true },
//         };

//         const bankCfg = BANK_CONFIG[onbCountry];

//         if (bankCfg && onbAccountNumber) {
//             const externalAccount = {
//                 object: "bank_account",
//                 country: onbCountry,
//                 currency: bankCfg.currency,
//                 account_holder_name: onbAccountHolderName,
//                 account_holder_type: "individual",
//                 account_number: onbAccountNumber,
//             };

//             if (bankCfg.useRouting && onbRoutingNumber) {
//                 externalAccount.routing_number = onbRoutingNumber;
//             }

//             updatePayload.external_account = externalAccount;
//         }

//         // ── 5. Push to Stripe ──────────────────────────────────────
//         console.log("📤 Updating Stripe account...");
//         const updated = await stripe.accounts.update(user.stripeAccountId, updatePayload);
//         console.log("✅ Stripe account updated");

//         // ── 6. Persist result to in-memory store ───────────────────
//         user.chargesEnabled = updated.charges_enabled;
//         user.payoutsEnabled = updated.payouts_enabled;
//         user.detailsSubmitted = updated.details_submitted;
//         user.currentlyDue = updated.requirements?.currently_due ?? [];
//         user.eventuallyDue = updated.requirements?.eventually_due ?? [];
//         user.pendingVerification = updated.requirements?.pending_verification ?? [];
//         user.disabledReason = updated.requirements?.disabled_reason ?? null;

//         console.log("📋 Requirements currently_due:", user.currentlyDue);
//         console.log("─────────────────────────────────────\n");

//         // ── 7. Return full status (mirrors what Flutter will consume) 
//         return res.status(200).json({
//             status: "success",
//             stripe_account_id: user.stripeAccountId,
//             charges_enabled: user.chargesEnabled,
//             payouts_enabled: user.payoutsEnabled,
//             details_submitted: user.detailsSubmitted,
//             currently_due: user.currentlyDue,
//             eventually_due: user.eventuallyDue,
//             pending_verification: user.pendingVerification,
//             disabled_reason: user.disabledReason,
//             requires_document: user.currentlyDue.some(r => r.includes("verification.document")),
//             // Debug info — remove once Firebase is working
//             _debug: {
//                 store: memStore,
//             },
//         });

//     } catch (err) {
//         console.error("❌ Test onboarding error:", err.message);

//         // Surface Stripe validation errors clearly
//         if (err.type === "StripeInvalidRequestError") {
//             return res.status(400).json({
//                 error: "Stripe validation error",
//                 param: err.param,
//                 message: err.message,
//             });
//         }

//         return res.status(500).json({ error: err.message });
//     }
// }