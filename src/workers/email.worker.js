// The worker's responsibility is simple:

// Listen to the queue.
// Receive a job.
// Pass the data to the service.
// Mark the job as completed.

require("dotenv").config();

const { Worker } = require("bullmq");

const connection = require("../config/redisConfig.js");
const { EMAIL_QUEUE } = require("../queues/queueNames");

const { sendEmail } = require("../services/email.service");

const worker = new Worker(
    EMAIL_QUEUE,

    async (job) => {
        console.log("\n📥 New Job Received");
        console.log("Job ID :", job.id);
        console.log("Job Name :", job.name);
        console.log("Job Data :", job.data);

        await sendEmail(job.data);
    },

    {
        connection,
    }
);

worker.on("completed", (job) => {
    console.log(`✅ Job ${job.id} Completed`);
});

worker.on("failed", (job, err) => {
    console.log(`❌ Job ${job.id} Failed`);
    console.log(err.message);
});

console.log("🚀 Email Worker Started...");

