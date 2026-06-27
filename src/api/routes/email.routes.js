
const {sendMail} = require("../controllers/email.controller.js");

const express = require("express");

const router = express.Router();


router.get("/send-email",sendMail);

module.exports = router;


