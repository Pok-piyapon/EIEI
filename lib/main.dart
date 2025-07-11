import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/complain.dart';
import './screens/list.dart';
import './screens/cctv.dart';
import './screens/news.dart';
import './screens/express_call.dart';
import './screens/pin.dart';
import './screens/profile.dart';
import './screens/security.dart';
import './screens/blog.dart';
import './screens/award.dart';
import './screens/form.dart';
import './screens/mailbox.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import './services/fcm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// GoRouter Setup
final GoRouter _router = GoRouter(
  initialLocation: "/pin",
  routes: [
    GoRoute(path: '/', builder: (context, state) => MunicipalHomePage()),
    GoRoute(path: '/login', builder: (context, state) => MunicipalLoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => MunicipalRegisterPage(),
    ),
    GoRoute(
      path: '/complain',
      builder: (context, state) => AppealFormPage(),
    ),
    GoRoute(path: '/list', builder: (context, state) => ComplaintsListPage()),
    GoRoute(path: '/cctv', builder: (context, state) => MunicipalCCTVPage()),
    GoRoute(path: '/news', builder: (context, state) => MunicipalNewsPage()),
    GoRoute(
      path: '/express_call',
      builder: (context, state) => ExpressCallPage(),
    ),
    GoRoute(path: '/pin', builder: (context, state) => MunicipalPinLockPage()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => MunicipalProfilePage(),
    ),
    GoRoute(path: '/security', builder: (context, state) => SecurityPage()),
    GoRoute(path: '/blog', builder: (context, state) => MunicipalBlogPage()),
    GoRoute(path: '/award', builder: (context, state) => AwardsShowcasePage()),
    GoRoute(path: '/mailbox', builder: (context, state)=> MailboxPage()),
  ],
);

void main() async {
  // Ensures that Flutter is fully initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    name: "wsh-cd933",
    options: const FirebaseOptions(
      apiKey: "AIzaSyCXwiylwbC0PCHAYqldNSBRn7lsaNtwCtk",
      projectId: "wsh-cd933",
      messagingSenderId: "411942764664",
      appId: "1:411942764664:android:1288e6cabd8d930dc6ed8d",
    ),
  );

  // Register background message handler BEFORE initializing FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize FCM for push notifications
  final fcm = Fcm();
  await fcm.initNotifications();
  
  // Sync notifications on app startup
  await fcm.syncNotificationsOnStartup();

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

String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(
    length,
    (index) => chars[rand.nextInt(chars.length)],
  ).join();
}
