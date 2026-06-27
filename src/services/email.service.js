const sendEmail = async (data) => {
    console.log("\n==============================");
    console.log("📨 Sending Email...");
    console.log(data);
    console.log("==============================\n");

    // Simulate long-running task
    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log("✅ Email Sent Successfully");
};

module.exports = {
    sendEmail,
};

