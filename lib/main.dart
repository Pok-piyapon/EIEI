import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/complain.dart';
import './screens/list.dart';


import 'package:firebase_core/firebase_core.dart';
import './services/fcm.dart';

// Local Notification
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Local Notification Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// GoRouter Setup
final GoRouter _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: '/', builder: (context, state) => MunicipalHomePage()),
    GoRoute(path: '/login', builder: (context, state) => MunicipalLoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => MunicipalRegisterPage(),
    ),
    GoRoute(
      path: '/complain',
      builder: (context, state) => MunicipalWebViewPage(),
    ),
    GoRoute(
      path: '/list',
      builder: (context, state) => ComplaintsListPage(),
    ),
  ],
);

void main() async {
  // Ensures that Flutter is fully initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    name: 'wsh-cd933',
    options: const FirebaseOptions(
      apiKey: "AIzaSyCXwiylwbC0PCHAYqldNSBRn7lsaNtwCtk",
      projectId: "wsh-cd933",
      messagingSenderId: "411942764664",
      appId: "1:411942764664:android:1288e6cabd8d930dc6ed8d",
    ),
  );

  // Initialize FCM for push notifications
  await Fcm().initNotifications(); // Uncomment if FCM service is implemented

  // Local Notification Initialization
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Run the app after everything is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MunicipalReport_App',
      routerConfig: _router,
    );
  }
}