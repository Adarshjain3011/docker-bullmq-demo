const { Queue } = require("bullmq");

const connection = require("../config/redisConfig.js");

const { EMAIL_QUEUE } = require("./queueNames");

const emailQueue = new Queue(EMAIL_QUEUE, {
    connection,
});

module.exports = emailQueue;

