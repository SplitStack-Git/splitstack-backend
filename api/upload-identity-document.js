// api/upload-identity-document.js
//
// Receives a base64-encoded image from Flutter, uploads it to Stripe
// Files API, then attaches the file ID to the connected account's
// individual.verification.document.
//
// Vercel config at the bottom disables the default body parser so we
// can read the raw JSON payload ourselves (needed because Flutter sends
// base64, not multipart — we convert to a Buffer here server-side).
//
// Two-step Stripe flow:
//   1. stripe.files.create()  →  file.id
//   2. stripe.accounts.update()  →  attach file.id to account
//
// Supported document types:
//   identity_document       — passport, driver licence, national ID
//   additional_verification — utility bill, bank statement (address proof)

import Stripe from "stripe";
import { Readable } from "stream";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/* ── Accepted MIME types ────────────────────────────────────── */

const ALLOWED_MIME = ["image/jpeg", "image/png", "application/pdf"];

const MIME_TO_EXT = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "application/pdf": "pdf",
};

/* ── Convert base64 → Node Readable stream ──────────────────── */

function base64ToStream(base64, mimeType) {
    const buffer = Buffer.from(base64, "base64");
    const stream = new Readable();
    stream.push(buffer);
    stream.push(null);
    // Stripe SDK needs .name and .size on the stream object
    stream.name = `document.${MIME_TO_EXT[mimeType] ?? "jpg"}`;
    stream.size = buffer.length;
    return stream;
}

/* ── Upload one file to Stripe ──────────────────────────────── */

async function uploadToStripe(base64, mimeType, purpose) {
    const stream = base64ToStream(base64, mimeType);

    const file = await stripe.files.create({
        purpose,
        file: {
            data: stream,
            name: stream.name,
            type: mimeType,
        },
    });

    return file.id;
}

/* ── Handler ───────────────────────────────────────────────── */

export default async function handler(req, res) {
    if (req.method !== "POST") {
        return res.status(405).json({ error: "Method not allowed" });
    }

    const {
        stripeAccountId,

        // Base64-encoded image strings sent from Flutter
        // frontBase64 is always required
        // backBase64  is optional (passports don't have a back)
        frontBase64,
        backBase64,

        // "image/jpeg" | "image/png" | "application/pdf"
        mimeType = "image/jpeg",

        // "identity_document"       — passport / driver licence / national ID
        // "additional_verification" — utility bill / bank statement (address proof)
        documentType = "identity_document",
    } = req.body;

    // ── Validate ────────────────────────────────────────────────
    if (!stripeAccountId) {
        return res.status(400).json({ error: "Missing stripeAccountId" });
    }
    if (!frontBase64) {
        return res.status(400).json({ error: "Missing frontBase64" });
    }
    if (!ALLOWED_MIME.includes(mimeType)) {
        return res.status(400).json({
            error: `Unsupported mimeType. Allowed: ${ALLOWED_MIME.join(", ")}`,
        });
    }
    if (!["identity_document", "additional_verification"].includes(documentType)) {
        return res.status(400).json({ error: "Invalid documentType" });
    }

    // Rough size check — base64 is ~1.37× the raw size
    const estimatedBytes = Math.round(frontBase64.length * 0.75);
    const TEN_MB = 10 * 1024 * 1024;
    if (estimatedBytes > TEN_MB) {
        return res.status(400).json({ error: "File exceeds 10 MB limit" });
    }

    try {
        console.log("\n─────────────────────────────────────");
        console.log("🪪  Uploading identity document");
        console.log("Account:", stripeAccountId);
        console.log("Type:   ", documentType);
        console.log("MIME:   ", mimeType);

        // ── Step 1: Upload front to Stripe Files API ─────────────
        console.log("📤 Uploading front...");
        const frontFileId = await uploadToStripe(frontBase64, mimeType, documentType);
        console.log("✅ Front file ID:", frontFileId);

        // ── Step 2: Upload back (optional) ───────────────────────
        let backFileId = null;
        if (backBase64) {
            console.log("📤 Uploading back...");
            backFileId = await uploadToStripe(backBase64, mimeType, documentType);
            console.log("✅ Back file ID:", backFileId);
        }

        // ── Step 3: Attach file IDs to the connected account ─────
        //
        // individual.verification.document  →  identity_document
        // individual.verification.additional_document  →  additional_verification
        //
        const verificationPayload =
            documentType === "identity_document"
                ? {
                    document: {
                        front: frontFileId,
                        ...(backFileId && { back: backFileId }),
                    },
                }
                : {
                    additional_document: {
                        front: frontFileId,
                        ...(backFileId && { back: backFileId }),
                    },
                };

        console.log("🔗 Attaching to account...");

        const updated = await stripe.accounts.update(stripeAccountId, {
            individual: {
                verification: verificationPayload,
            },
        });

        console.log("✅ Account updated");

        // ── Step 4: Return fresh requirements state ───────────────
        const currentlyDue = updated.requirements?.currently_due ?? [];
        const eventuallyDue = updated.requirements?.eventually_due ?? [];
        const pendingVerification = updated.requirements?.pending_verification ?? [];
        const disabledReason = updated.requirements?.disabled_reason ?? null;

        const requiresDocument =
            currentlyDue.some(r => r.includes("verification.document")) ||
            eventuallyDue.some(r => r.includes("verification.document"));

        let onboardingStatus = "pending_verification";
        if (updated.charges_enabled && updated.payouts_enabled && currentlyDue.length === 0) {
            onboardingStatus = "complete";
        } else if (disabledReason) {
            onboardingStatus = "restricted";
        }

        console.log("💳 charges_enabled:", updated.charges_enabled);
        console.log("📋 currently_due:  ", currentlyDue);
        console.log("─────────────────────────────────────\n");

        return res.status(200).json({
            status: "success",
            front_file_id: frontFileId,
            back_file_id: backFileId,
            onboarding_status: onboardingStatus,
            charges_enabled: updated.charges_enabled,
            payouts_enabled: updated.payouts_enabled,
            details_submitted: updated.details_submitted,
            currently_due: currentlyDue,
            eventually_due: eventuallyDue,
            pending_verification: pendingVerification,
            disabled_reason: disabledReason,
            requires_document: requiresDocument,
        });

    } catch (err) {
        console.error("❌ Document upload error:", err.message);

        if (err.type === "StripeInvalidRequestError") {
            return res.status(400).json({
                error: "Stripe validation error",
                param: err.param,
                message: err.message,
            });
        }

        return res.status(500).json({ error: err.message });
    }
}

// ── Vercel: must disable body size limit for file uploads ──────
export const config = {
    api: {
        bodyParser: {
            sizeLimit: "12mb", // slightly above 10 MB to give breathing room
        },
    },
};