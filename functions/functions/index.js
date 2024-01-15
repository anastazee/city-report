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

exports.moveOldIncidents = functions.pubsub.schedule('every 2 minutes').timeZone('UTC').onRun(async (context) => {
  try {
    const thirtySixHoursAgo = new Date();
    thirtySixHoursAgo.setHours(thirtySixHoursAgo.getHours() - 36);
    const recentSnapshot = await admin.firestore().collection('recent').where('datetime', '<', thirtySixHoursAgo).get();

    const batch = admin.firestore().batch();
    let userPointsToUpdate = {}; // To accumulate points for each user

    recentSnapshot.forEach((doc) => {
      const data = doc.data();

      const userId = data.uid;
      const likes = data.likes || 0;
      const dislikes = data.dislikes || 0;
      if (!userPointsToUpdate[userId]) {
        userPointsToUpdate[userId] = 0;
      }

      userPointsToUpdate[userId] += (likes - dislikes);

      batch.set(admin.firestore().collection('incidents').doc(doc.id), data);
      batch.delete(doc.ref);
    });

    await batch.commit();

    const usersCollection = admin.firestore().collection('users');
    const updatePromises = Object.entries(userPointsToUpdate).map(async ([userId, points2]) => {
      const userDocRef = usersCollection.doc(userId);
      await userDocRef.update({ points: admin.firestore.FieldValue.increment(points2) });
      console.log(`User ${userId} points updated by ${points2}`);
    });

    // Wait for all user updates to complete before returning
    await Promise.all(updatePromises);

    return null;
  } catch (error) {
    console.error('Error in moveOldIncidents function:', error);
    return null;
  }
});
