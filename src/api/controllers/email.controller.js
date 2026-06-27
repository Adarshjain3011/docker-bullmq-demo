const { addSendEmailJob } = require("../../queues/producers/email.producer");

const sendMail = async (req, res) => {
    try {
        // const { to, subject, text } = req.body;

        const to = "test@example.com";
        const subject = "Test Email";
        const text = "This is a test email.";

        const job = await addSendEmailJob({
            to,
            subject,
            text,
        });

        return res.status(200).json({
            success: true,
            jobId: job.id,
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

module.exports = {
    sendMail,
};

