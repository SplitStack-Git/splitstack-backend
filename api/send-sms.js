import twilio from "twilio";

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

export default async function handler(req, res) {
  try {
    const message = await client.messages.create({
      body: "Test from SplitStack 🚀",
      from: "+14783128184",
      to: "+61409995509"
    });

    res.status(200).json({
      success: true,
      sid: message.sid
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: error.message
    });
  }
}
