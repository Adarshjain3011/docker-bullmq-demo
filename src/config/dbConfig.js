
const mongoose = require("mongoose");

const connectDB = async () => {
    // try {
    //     await mongoose.connect("mongodb://mongo:27017/mydatabase",);
    //     console.log("MongoDB connected");
    // } catch (error) {
    //     console.error("Error connecting to MongoDB:", error);
    //     process.exit(1);
    // }

    await mongoose.connect("mongodb://mongodb:27017/mydb").then((data) => [

        console.log(`MongoDB connected with server: ${data.connection.host}`)

    ]).catch((err) => {
        console.log(err);
    })

};

module.exports = connectDB;

