const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// 1. ഫ്ലട്ടറിൽ നിന്ന് വിളിക്കാവുന്ന ലളിതമായ ഒരു Cloud Function
exports.helloExpenseManager = onCall((request) => {
  const userName = request.data.name || "User";
  logger.info(`Hello message requested by ${userName}`);
  
  return {
    message: `Hello ${userName}! Firebase Cloud Function വിജയകരമായി പ്രവർത്തിച്ചു!`,
    timestamp: new Date().toISOString()
  };
});