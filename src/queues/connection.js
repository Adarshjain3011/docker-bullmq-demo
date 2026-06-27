const { Redis } = require("ioredis");
require("dotenv").config();

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

