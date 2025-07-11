import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'storage.dart';

// Top-level function to handle background messages
// This function MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  // await Firebase.initializeApp();
  
  log('Handling a background message: ${message.messageId}');
  print('Background Message Title: ${message.notification?.title}');
  print('Background Message Body: ${message.notification?.body}');
  print('Background Message Data: ${message.data}');
  
  // Save notification data to storage even when app is terminated
  await _saveNotificationToStorageBackground(message);
}

// Background storage function (static method)
Future<void> _saveNotificationToStorageBackground(RemoteMessage message) async {
  try {
    // Create unique ID using message ID if available, otherwise timestamp
    String uniqueId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create notification data map
    Map<String, dynamic> notificationData = {
      'id': uniqueId,
      'messageId': message.messageId ?? uniqueId,
      'title': message.notification?.title ?? 'Notification',
      'message': message.notification?.body ?? 'You have a new message',
      'type': message.data['type'] ?? 'info',
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
      'userId': 'fcm_user',
      'data': message.data,
      'receivedInBackground': true, // Flag to indicate this was received in background
    };
    
    // Get existing notifications from storage
    String? existingData = await AuthStorage.get('mailbox');
    List<dynamic> notifications = [];
    
    if (existingData != null && existingData.isNotEmpty) {
      try {
        notifications = jsonDecode(existingData);
      } catch (e) {
        log('Error parsing existing notifications in background: $e');
        notifications = [];
      }
    }
    
    // Check for duplicate notifications
    bool isDuplicate = notifications.any((notification) => 
      notification['messageId'] == uniqueId || 
      notification['id'] == uniqueId
    );
    
    if (isDuplicate) {
      log('Duplicate background notification detected, skipping save: $uniqueId');
      return;
    }
    
    // Add new notification to the beginning of the list
    notifications.insert(0, notificationData);
    
    // Keep only the latest 50 notifications to prevent storage bloat
    if (notifications.length > 50) {
      notifications = notifications.take(50).toList();
    }
    
    // Save back to storage as JSON string
    String jsonString = jsonEncode(notifications);
    await AuthStorage.set('mailbox', jsonString);
    
    log('Background notification saved to storage: ${notificationData['title']} (ID: $uniqueId)');
  } catch (e) {
    log('Error saving background notification to storage: $e');
    
    // Fallback: Try to save with minimal data if main save fails
    try {
      Map<String, dynamic> fallbackData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? 'Background Notification',
        'message': message.notification?.body ?? 'Message received while app was closed',
        'type': 'info',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': 'fcm_user',
        'data': {},
        'receivedInBackground': true,
        'error': 'Fallback save due to error',
      };
      
      await AuthStorage.set('mailbox', jsonEncode([fallbackData]));
      log('Fallback background notification save successful');
    } catch (fallbackError) {
      log('Fallback background notification save also failed: $fallbackError');
    }
  }
}

class Fcm {
  // Create instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  
  // Create instance of Flutter Local Notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Constants for token management
  static const String _tokenKey = 'fcm_token';
  static const String _lastTokenRequestKey = 'last_token_request';
  static const int _tokenRequestCooldownHours = 24;

  // Function to initialize notifications
  Future<void> initNotifications() async {
    try {
      // Initialize local notifications first
      await _initializeLocalNotifications();
      
      // Request permission from user (will prompt user)
      await _firebaseMessaging.requestPermission();

      // Get FCM token with error handling
      final fcmToken = await _getTokenSafely();
      
      if (fcmToken != null) {
        log("Token $fcmToken");
        
        // Subscribe to all_users topic automatically
        await subscribeToAllUsers();
        
        // Initialize further settings for push notifications
        initPushNotification();
      } else {
        log("FCM token not available, continuing without notifications");
        // Still initialize push notification handlers for when token becomes available
        initPushNotification();
      }
      
    } catch (e) {
      log('FCM initialization failed: $e');
      // Continue app execution even if FCM fails
      // Initialize basic push notification handlers
      initPushNotification();
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );
      
      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Request notification permissions for Android 13+
      await _requestNotificationPermissions();
      
      log('Local notifications initialized successfully');
    } catch (e) {
      log('Error initializing local notifications: $e');
    }
  }

  // Request notification permissions (for Android 13+)
  Future<void> _requestNotificationPermissions() async {
    try {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      if (granted == true) {
        log('Local notification permissions granted');
      } else {
        log('Local notification permissions denied');
      }
    } catch (e) {
      log('Error requesting notification permissions: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // Handle notification tap here
    // You can navigate to specific screens based on payload
  }

  // Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        channelDescription: 'Channel for FCM notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );
      
      // iOS notification details
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combined notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      
      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      log('Local notification shown: $title - $body');
    } catch (e) {
      log('Error showing local notification: $e');
    }
  }

  // Safe token retrieval with error handling
  Future<String?> _getTokenSafely() async {
    try {
      // Check if we're in cooldown period
      if (await _isInCooldownPeriod()) {
        log('FCM token request in cooldown period, using cached token');
        return await _getCachedToken();
      }

      // First, try to get cached token
      String? cachedToken = await _getCachedToken();
      if (cachedToken != null) {
        log('Using cached FCM token');
        return cachedToken;
      }

      // If no cached token, request new one
      log('Requesting new FCM token...');
      String? newToken = await _firebaseMessaging.getToken();
      
      if (newToken != null) {
        await _cacheToken(newToken);
        await _updateLastRequestTime();
        return newToken;
      }
      
      return null;
      
    } on PlatformException catch (e) {
      if (e.code == 'TOO_MANY_REGISTRATIONS') {
        log('TOO_MANY_REGISTRATIONS error. Attempting recovery...');
        return await _handleTooManyRegistrations();
      }
      log('Platform exception getting FCM token: ${e.message}');
      return null;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  // Handle TOO_MANY_REGISTRATIONS error
  Future<String?> _handleTooManyRegistrations() async {
    try {
      log('Attempting to clear existing token...');
      
      // Delete existing token
      await _firebaseMessaging.deleteToken();
      
      // Clear cached token
      await _clearCachedToken();
      
      // Wait before requesting new token
      await Future.delayed(Duration(seconds: 5));
      
      // Request new token
      String? newToken = await _firebaseMessaging.getToken();
      
      if (newToken != null) {
        await _cacheToken(newToken);
        await _updateLastRequestTime();
        log('Successfully recovered with new token');
        return newToken;
      }
      
      log('Failed to get new token after recovery attempt');
      return null;
      
    } catch (e) {
      log('Recovery attempt failed: $e');
      return null;
    }
  }

  // Cache token locally
  Future<void> _cacheToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      log('Error caching FCM token: $e');
    }
  }

  // Get cached token
  Future<String?> _getCachedToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      log('Error getting cached FCM token: $e');
      return null;
    }
  }

  // Clear cached token
  Future<void> _clearCachedToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      log('Error clearing cached FCM token: $e');
    }
  }

  // Update last request time
  Future<void> _updateLastRequestTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastTokenRequestKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      log('Error updating last request time: $e');
    }
  }

  // Check if in cooldown period
  Future<bool> _isInCooldownPeriod() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastRequest = prefs.getInt(_lastTokenRequestKey);
      
      if (lastRequest == null) return false;
      
      DateTime lastRequestTime = DateTime.fromMillisecondsSinceEpoch(lastRequest);
      DateTime cooldownEnd = lastRequestTime.add(Duration(hours: _tokenRequestCooldownHours));
      
      return DateTime.now().isBefore(cooldownEnd);
    } catch (e) {
      log('Error checking cooldown period: $e');
      return false;
    }
  }

  // Public method to refresh token (with cooldown)
  Future<String?> refreshToken() async {
    try {
      log('Manually refreshing FCM token...');
      
      // Delete existing token
      await _firebaseMessaging.deleteToken();
      await _clearCachedToken();
      
      // Wait before requesting new token
      await Future.delayed(Duration(seconds: 3));
      
      // Get new token
      return await _getTokenSafely();
      
    } catch (e) {
      log('Error refreshing FCM token: $e');
      return null;
    }
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

  // Method to save notification data to storage
  Future<void> _saveNotificationToStorage(RemoteMessage message) async {
    try {
      // Create unique ID using message ID if available, otherwise timestamp
      String uniqueId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create notification data map
      Map<String, dynamic> notificationData = {
        'id': uniqueId,
        'messageId': message.messageId ?? uniqueId,
        'title': message.notification?.title ?? 'Notification',
        'message': message.notification?.body ?? 'You have a new message',
        'type': message.data['type'] ?? 'info',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': 'fcm_user',
        'data': message.data,
        'receivedInBackground': false,
      };
      
      // Get existing notifications from storage
      String? existingData = await AuthStorage.get('mailbox');
      List<dynamic> notifications = [];
      
      if (existingData != null && existingData.isNotEmpty) {
        try {
          notifications = jsonDecode(existingData);
        } catch (e) {
          log('Error parsing existing notifications: $e');
          notifications = [];
        }
      }
      
      // Check for duplicate notifications (prevent same message from being saved twice)
      bool isDuplicate = notifications.any((notification) => 
        notification['messageId'] == uniqueId || 
        notification['id'] == uniqueId
      );
      
      if (isDuplicate) {
        log('Duplicate notification detected, skipping save: $uniqueId');
        return;
      }
      
      // Add new notification to the beginning of the list
      notifications.insert(0, notificationData);
      
      // Keep only the latest 50 notifications to prevent storage bloat
      if (notifications.length > 50) {
        notifications = notifications.take(50).toList();
      }
      
      // Save back to storage as JSON string
      String jsonString = jsonEncode(notifications);
      await AuthStorage.set('mailbox', jsonString);
      
      log('Notification saved to storage: ${notificationData['title']} (ID: $uniqueId)');
    } catch (e) {
      log('Error saving notification to storage: $e');
      
      // Fallback: Try to save with minimal data if main save fails
      try {
        Map<String, dynamic> fallbackData = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': message.notification?.title ?? 'Notification',
          'message': message.notification?.body ?? 'Message received',
          'type': 'info',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
          'userId': 'fcm_user',
          'data': {},
          'error': 'Fallback save due to error',
        };
        
        await AuthStorage.set('mailbox', jsonEncode([fallbackData]));
        log('Fallback notification save successful');
      } catch (fallbackError) {
        log('Fallback notification save also failed: $fallbackError');
      }
    }
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // check if null; if so, do nothing
    if (message == null) return;

    print('Message Title: ${message.notification?.title}');
    print('Message Body: ${message.notification?.body}');
    print('Message Data: ${message.data}');
    
    // Save notification data to storage
    _saveNotificationToStorage(message);
    
    // Show local notification if notification data is available
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? 'You have a new message',
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    }
    
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
      
      // Save notification data to storage
      _saveNotificationToStorage(message);
      
      // Show local notification when app is in foreground
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? 'You have a new message',
          payload: message.data.isNotEmpty ? message.data.toString() : null,
        );
      }
    });
  }

  // Function to initialize background settings
  Future initPushNotification() async {
    // Note: Background message handler is registered in main.dart
    // This is required to ensure it's registered before the app starts
    
    // handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // handle foreground messages
    handleForegroundMessage();
    
    log('Push notification handlers initialized');
  }

  // Utility method to check if FCM is working
  Future<bool> isTokenAvailable() async {
    String? token = await _getCachedToken();
    return token != null;
  }

  // Method to manually clear all FCM data (for debugging)
  Future<void> clearAllFcmData() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _clearCachedToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastTokenRequestKey);
      log('All FCM data cleared');
    } catch (e) {
      log('Error clearing FCM data: $e');
    }
  }

  // Method to get all stored notifications
  Future<List<Map<String, dynamic>>> getStoredNotifications() async {
    try {
      String? storedData = await AuthStorage.get('mailbox');
      if (storedData != null && storedData.isNotEmpty) {
        List<dynamic> notifications = jsonDecode(storedData);
        return notifications.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error retrieving stored notifications: $e');
      return [];
    }
  }

  // Method to mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      List<Map<String, dynamic>> notifications = await getStoredNotifications();
      
      // Find and update the notification
      for (var notification in notifications) {
        if (notification['id'] == notificationId) {
          notification['isRead'] = true;
          notification['readAt'] = DateTime.now().toIso8601String();
          break;
        }
      }
      
      // Save back to storage
      String jsonString = jsonEncode(notifications);
      await AuthStorage.set('mailbox', jsonString);
      
      log('Notification marked as read: $notificationId');
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  // Method to clear all stored notifications
  Future<void> clearAllStoredNotifications() async {
    try {
      await AuthStorage.set('mailbox', '[]');
      log('All stored notifications cleared');
    } catch (e) {
      log('Error clearing stored notifications: $e');
    }
  }

  // Method to get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      List<Map<String, dynamic>> notifications = await getStoredNotifications();
      return notifications.where((notification) => notification['isRead'] == false).length;
    } catch (e) {
      log('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Method to check and handle notifications on app startup
  Future<void> syncNotificationsOnStartup() async {
    try {
      log('Syncing notifications on app startup...');
      
      // Get any pending notifications that might have been missed
      List<Map<String, dynamic>> storedNotifications = await getStoredNotifications();
      
      // Log the number of stored notifications
      log('Found ${storedNotifications.length} stored notifications');
      
      // Count unread notifications
      int unreadCount = await getUnreadNotificationCount();
      log('Unread notifications: $unreadCount');
      
      // You can add additional logic here to handle missed notifications
      // For example, show a summary notification if there are many unread ones
      
    } catch (e) {
      log('Error syncing notifications on startup: $e');
    }
  }
}
