const Redis = require("ioredis");

const connection = new Redis({
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    maxRetriesPerRequest: null,
});

connection.on("connect", () => {
    console.log("✅ Redis Connected");
});

connection.on("error", (err) => {
    console.log("❌ Redis Error:", err.message);
});

module.exports = connection;



    //             redisConfig.js
    //                   │
    //     ┌─────────────┼─────────────┐
    //     │             │             │
    //     ▼             ▼             ▼
    // API Server     BullMQ Queue   Worker

    