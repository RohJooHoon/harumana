/**
 * Firebase Cloud Functions for Push Notifications
 *
 * 설치 방법:
 * 1. Firebase CLI 설치: npm install -g firebase-tools
 * 2. Firebase 로그인: firebase login
 * 3. 프로젝트 디렉토리에서: firebase init functions
 * 4. 이 파일을 functions/index.js에 복사
 * 5. 배포: firebase deploy --only functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Use custom database 'harumanna'
const db = admin.firestore();
db.settings({ databaseId: "harumanna" });

/**
 * Trigger: When a new notification document is created
 * Sends push notification to the appropriate user(s)
 */
exports.sendPushNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data();

    if (notification.processed) {
      console.log("Notification already processed");
      return null;
    }

    try {
      let tokens = [];
      let title = "";
      let body = "";

      if (notification.type === "PENDING_APPROVAL") {
        // Send to group admin
        title = "새로운 가입 신청";
        body = `${notification.userName}님이 가입을 신청했습니다.`;

        // Get group admin's FCM token
        const groupDoc = await db
          .collection("groups")
          .doc(notification.groupId)
          .get();

        if (groupDoc.exists) {
          const adminId = groupDoc.data().adminId;
          const adminDoc = await db.collection("users").doc(adminId).get();

          if (adminDoc.exists && adminDoc.data().fcmToken) {
            tokens.push(adminDoc.data().fcmToken);
          }
        }
      } else if (notification.type === "APPROVAL_GRANTED") {
        // Send to user who was approved
        title = "가입 승인 완료";
        body = `${notification.groupName} 모임 가입이 승인되었습니다.`;

        const userDoc = await db
          .collection("users")
          .doc(notification.userId)
          .get();

        if (userDoc.exists && userDoc.data().fcmToken) {
          tokens.push(userDoc.data().fcmToken);
        }
      }

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        await snap.ref.update({ processed: true, error: "No tokens found" });
        return null;
      }

      // Send push notification
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: notification.type,
          groupId: notification.groupId || "",
          userId: notification.userId || "",
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Sent ${response.successCount} notifications successfully`);

      // Mark as processed
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      return null;
    } catch (error) {
      console.error("Error sending notification:", error);
      await snap.ref.update({ processed: true, error: error.message });
      return null;
    }
  });

/**
 * Optional: Clean up old notifications (run daily)
 */
exports.cleanupOldNotifications = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - 7); // Delete notifications older than 7 days

    const oldNotifications = await db
      .collection("notifications")
      .where("createdAt", "<", cutoff)
      .get();

    const batch = db.batch();
    oldNotifications.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${oldNotifications.size} old notifications`);
    return null;
  });
