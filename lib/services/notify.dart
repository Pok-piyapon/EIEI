import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotification {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  AppNotification() {
    _initialize();
  }

  Future<void> _initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This channel is for basic notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0, // Notification ID
      'Hello 👋',
      'This is a local notification.',
      platformDetails,
    );
  }
}
