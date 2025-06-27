import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class Fcm {
  // Create instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notifications
  Future<void> initNotifications() async {
    // request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // fetch the FCM token for this device
    final fcmToken = await _firebaseMessaging.getToken();

    // print the token (normally you would send this to your server)
    log("Token $fcmToken");

    // initialize further settings for push noti
    initPushNotification();
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // check if null; if so, do nothing
    if (message == null) return;

    print(message);
  }

  // Function to initialize background settings
  Future initPushNotification() async {
    // handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}