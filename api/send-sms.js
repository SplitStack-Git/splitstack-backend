const twilio = require("twilio");

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

module.exports = async (req, res) => {
  console.log("🔥 SEND SMS ENDPOINT HIT");

  try {
    const message = await client.messages.create({
      body: "Test from SplitStack 🚀",
      from: process.env.TWILIO_PHONE_NUMBER,
      to: "+61409995509"
    });

    console.log("✅ SMS SENT:", message.sid);

    res.status(200).json({
      success: true,
      sid: message.sid
    });

  } catch (error) {
    console.error("❌ SMS ERROR:", error);

    res.status(500).json({
      error: error.message
    });
  }
};
