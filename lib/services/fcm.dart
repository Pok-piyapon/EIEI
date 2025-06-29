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

    // Subscribe to all_users topic automatically
    await subscribeToAllUsers();

    // initialize further settings for push noti
    initPushNotification();
  }

  // Function to subscribe to all_users topic
  Future<void> subscribeToAllUsers() async {
    try {
      await _firebaseMessaging.subscribeToTopic('all_users');
      log('Successfully subscribed to all_users topic');
    } catch (e) {
      log('Error subscribing to all_users topic: $e');
    }
  }

  // Function to subscribe to custom topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Successfully subscribed to $topic topic');
    } catch (e) {
      log('Error subscribing to $topic topic: $e');
    }
  }

  // Function to unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Successfully unsubscribed from $topic topic');
    } catch (e) {
      log('Error unsubscribing from $topic topic: $e');
    }
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // check if null; if so, do nothing
    if (message == null) return;

    print('Message Title: ${message.notification?.title}');
    print('Message Body: ${message.notification?.body}');
    print('Message Data: ${message.data}');
    
    // Handle custom data if needed
    if (message.data.isNotEmpty) {
      print('Custom data received: ${message.data}');
      // Add your custom logic here based on message data
      // For example:
      // if (message.data['action'] == 'navigate') {
      //   // Navigate to specific screen
      // }
    }
  }

  // Function to handle foreground messages
  void handleForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      print('Message Title: ${message.notification?.title}');
      print('Message Body: ${message.notification?.body}');
      print('Message Data: ${message.data}');
      
      // You can show a local notification here if needed
      // or update your UI directly
    });
  }

  // Function to initialize background settings
  Future initPushNotification() async {
    // handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // handle foreground messages
    handleForegroundMessage();
  }
}