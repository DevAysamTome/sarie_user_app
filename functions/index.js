// const functions = require('firebase-functions');
// const express = require('express');
// const axios = require('axios');
// const cors = require('cors');

// const app = express();
// app.use(cors({ origin: true }));
// app.use(express.json());

// // Route for starting the payment
// app.post('/start-payment', async (req, res) => {
//   const { email, amount } = req.body;

//   try {
//     const response = await axios.post('https://api.lahza.io/transaction/initialize', {
//       email: email,
//       amount: amount
//     }, {
//       headers: {
//         'Authorization': 'Bearer sk_test_jOR94pilqqkyQKW6ADBCKIJMwj73zAYQ6',
//         'Content-Type': 'application/json'
//       }
//     });

//     // Check if the API response status is true
//     if (response.data.status) {
//       const { authorization_url, access_code, reference } = response.data.data;

//       // Log the response data for debugging
//       console.log('Payment initialization response:', response.data);

//       // Send the response to the client
//       res.json({
//         success: true,
//         authorizationUrl: authorization_url,
//         accessCode: access_code,
//         reference: reference
//       });
//     } else {
//       // Send error message if the API response status is false
//       res.json({ success: false, message: response.data.message });
//     }
//   } catch (error) {
//     console.error('Error in /start-payment route:', error.message);
//     res.status(500).json({ success: false, message: error.message });
//   }
// });

// // Route for verifying the payment
// app.get('/verify-payment', async (req, res) => {
//   const { reference } = req.params;

//   try {
//     const response = await axios.get(`https://api.lahza.io/transaction/verify/${reference}`, {
//       headers: {
//         'Authorization': 'Bearer sk_test_jOR94pilqqkyQKW6ADBCKIJMwj73zAYQ6'
//       }
//     });

//     // Check if the API response status is true
//     if (response.data.status) {
//       // Log the verification response data for debugging
//       console.log('Payment verification response:', response.data);

//       // Send the response to the client
//       res.json({
//         success: true,
//         data: response.data.data
//       });
//     } else {
//       // Send error message if the API response status is false
//       res.json({ success: false, message: response.data.message });
//     }
//   } catch (error) {
//     console.error('Error in /verify-payment route:', error.message);
//     res.status(500).json({ success: false, message: error.message });
//   }
// });

// exports.api = functions.https.onRequest(app);


// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// const geofire = require('geofire-common');
// const { PubSub } = require('@google-cloud/pubsub');
// admin.initializeApp();
// const pubsub = new PubSub();

// exports.updateOrderStatus = functions.firestore
//   .document('orders/{orderId}')
//   .onUpdate(async (change, context) => {
//     const after = change.after.data();
//     const before = change.before.data();
//     const orderId = context.params.orderId;

//     console.log('Order ID:', orderId);
//     console.log('Before Data:', before);
//     console.log('After Data:', after);

//     const orderItemsSnapshot = await admin.firestore().collection('orders').doc(orderId).collection('storeOrders').get();
//     const allItemsCompleted = orderItemsSnapshot.docs.every(doc => doc.data().orderStatus === 'مكتمل');

//     if (allItemsCompleted && before.orderStatus !== 'مكتمل' && after.orderStatus !== 'مكتمل') {
//       console.log('Updating order status to completed');
//       await admin.firestore().collection('orders').doc(orderId).update({ orderStatus: 'مكتمل' });

//       try {
//         // نشر رسالة إلى Cloud Pub/Sub
//         const message = JSON.stringify({ orderId });
//         await pubsub.topic('orderCompleted').publish(Buffer.from(message));
//         console.log('Message published to Cloud Pub/Sub');
//       } catch (error) {
//         console.error('Error publishing message:', error);
//       }
//     }
//   });

// exports.findNearestDeliveryWorker = functions.pubsub
//   .topic('orderCompleted')
//   .onPublish(async (message) => {
//     console.log('Received message:', message);
//     const { orderId } = JSON.parse(Buffer.from(message.data, 'base64').toString());
//     console.log('Order ID from message:', orderId);

//     try {
//       const orderSnapshot = await admin.firestore().collection('orders').doc(orderId).get();
//       const orderData = orderSnapshot.data();
//       const customerLocation = { latitude: orderData.latitude, longitude: orderData.longitude };

//       const deliveryWorkersSnapshot = await admin.firestore().collection('deliveryWorkers').get();
//       const deliveryWorkers = deliveryWorkersSnapshot.docs.map(doc => ({
//         ...doc.data(),
//         id: doc.id,
//         distance: geofire.distanceBetween(
//           [customerLocation.latitude, customerLocation.longitude],
//           [doc.data().latitude, doc.data().longitude]
//         )
//       }));

//       const nearestWorker = deliveryWorkers.reduce((prev, curr) => prev.distance < curr.distance ? prev : curr);

//       if (nearestWorker && nearestWorker.fcmToken) {
//         const payload = {
//           notification: {
//             title: 'SARIE APP',
//             body: `لديك طلب جديد بالقرب منك!`,
//           },
//         };

//         await admin.messaging().sendToDevice(nearestWorker.fcmToken, payload);
//         console.log('Notification sent to nearest worker');
//       } else {
//         console.log('No valid worker found');
//       }
//     } catch (error) {
//       console.error('Error processing message:', error);
//     }
//   });

// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendPharmacyRequestNotification = functions.firestore
//     .document('pharmacy_requests/{requestId}')
//     .onCreate((snap, context) => {
//         const newRequest = snap.data();

//         const payload = {
//             notification: {
//                 title: 'طلب جديد من الصيدلية',
//                 body: `تم طلب ${newRequest.medicineName} من ${newRequest.customerName}`,
//             },
//             data: {
//                 click_action: 'FLUTTER_NOTIFICATION_CLICK',
//                 request_id: context.params.requestId,
//             },
//         };

//         return admin.messaging().sendToTopic('pharmacy_notifications', payload);
//     });
// const functions = require('firebase-functions');
// const express = require('express');
// const bodyParser = require('body-parser');
// const twilio = require('twilio');
// const admin = require('firebase-admin');

// const app = express();
// const port = 3000;

// app.use(bodyParser.json());

// // إعداد Firebase
// admin.initializeApp({
//   credential: admin.credential.applicationDefault(),
// });

// // إعداد Twilio
// const accountSid = 'AC4e05272263e8fb5d38c89b584a9c9bb5';
// const authToken = '2113b80dc147a94db0c097b6434d5b69';
// const client = twilio(accountSid, authToken);

// // إرسال رمز التحقق
// app.post('/send-code', async (req, res) => {
//   const { phoneNumber } = req.body;
//   const verificationCode = Math.floor(100000 + Math.random() * 900000); // رمز تحقق مكون من 6 أرقام

//   try {
//     await client.messages.create({
//       body: `Your verification code is ${verificationCode}`,
//       from: '+16052779428',
//       to: phoneNumber,
//     });

//     // تخزين الرمز في Firebase
//     await admin.firestore().collection('verificationCodes').doc(phoneNumber).set({
//       code: verificationCode,
//       createdAt: admin.firestore.FieldValue.serverTimestamp(),
//     });

//     res.send({ success: true });
//   } catch (error) {
//     res.status(500).send({ success: false, error: error.message });
//   }
// });

// // التحقق من الرمز
// app.post('/verify-code', async (req, res) => {
//   const { phoneNumber, code } = req.body;

//   try {
//     const doc = await admin.firestore().collection('verificationCodes').doc(phoneNumber).get();

//     if (!doc.exists || doc.data().code !== code) {
//       return res.status(400).send({ success: false, error: 'Invalid code' });
//     }

//     // قم بإنشاء أو تسجيل المستخدم في Firebase
//     const userRecord = await admin.auth().getUserByPhoneNumber(phoneNumber);
//     if (!userRecord) {
//       // إذا لم يكن المستخدم موجودًا، قم بإنشائه
//       await admin.auth().createUser({ phoneNumber });
//     }

//     res.send({ success: true });
//   } catch (error) {
//     res.status(500).send({ success: false, error: error.message });
//   }
// });
// exports.otp = functions.https.onRequest(app);




