require("dotenv").config();

const express = require("express");

const connectDB = require("../config/dbConfig");
// const { connectRedis } = require("../config/redisConfig");
const redisConnection = require("../config/redisConfig");

const emailRoutes = require("./routes/email.routes.js");

const app = express();

app.use(express.json());

app.use("/api/email", emailRoutes);

app.get("/", (req, res) => {
    res.send("Hello, World!");
});

const PORT = process.env.PORT || 3000;

const startServer = async () => {
    try {
        // await connectDB();
        // await connectRedis();

        app.listen(PORT, () => {
            console.log(`🚀 Server running on port ${PORT}`);
        });

    } catch (error) {
        console.error("Server startup failed:", error);
        process.exit(1);
    }
};

startServer();

