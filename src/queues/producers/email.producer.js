const emailQueue = require("../email.queue");

const addSendEmailJob = async (payload) => {
    return await emailQueue.add("send-email", payload);
};

const addWelcomeEmailJob = async (payload) => {
    return await emailQueue.add("welcome-email", payload);
};

const addResetPasswordEmailJob = async (payload) => {
    return await emailQueue.add("reset-password", payload);
};

module.exports = {
    addSendEmailJob,
    addWelcomeEmailJob,
    addResetPasswordEmailJob,
};

