const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
var db = admin.firestore();
var fcm =admin.messaging();

exports.notifyNewMessageV4 = functions.firestore
.document('Notifications/{NotificationId}')
.onCreate(async(snapshot)=>{
  const notificationMgs = snapshot.data();

  const querySnapshot = db.collection('users')
  .doc(notificationMgs.receiverId).collection('token').get();

  const token = (await querySnapshot).docs.map((snap)=>snap.id);

  const payload={
    notification:{
      title: notificationMgs.title,
      body: notificationMgs.body,
      icon: '@mipmap/launcher_icon'
      //clickAction: 'FLUTTER_NOTIFICATION_CLICK',
    },
    data: {
//       title: notificationMgs.title,
//       body: notificationMgs.body,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      sound: "default",
      status: "done",
      screen: notificationMgs.receiverId,
    }
  };

  return fcm.sendToDevice(token,payload);

});