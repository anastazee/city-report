/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.moveOldIncidents = functions.pubsub.schedule('0 */3 * * *').timeZone('UTC').onRun(async (context) => {
  const thirtySixHoursAgo = new Date();
  thirtySixHoursAgo.setHours(thirtySixHoursAgo.getHours() - 36);
  const recentSnapshot = await admin.firestore().collection('recent').where('datetime', '<', thirtySixHoursAgo).get();

  const batch = admin.firestore().batch(
  );

  recentSnapshot.forEach((doc) => {
    const data = doc.data();
    batch.set(admin.firestore().collection('incidents').doc(doc.id), data);
    batch.delete(doc.ref);
  });

  await batch.commit();

  return null;
});

