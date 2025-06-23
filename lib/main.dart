import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';
import 'package:firebase_core/firebase_core.dart';

// Local Notification
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GoRouter _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => MunicipalHomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => MunicipalLoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => MunicipalRegisterPage(),
    ),
  ],
);

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // firebase
  var firebase = Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: "AIzaSyAjK-9_HF6hRhehoMeFpCz985TZFJ5K7P8",
      authDomain: "your_app.firebaseapp.com",
      projectId: "wsh-a2a8f",
      storageBucket: "your_app.appspot.com",
      messagingSenderId: "1054163847916",
      appId: "1:1054163847916:android:b1bc71522fbe4bbf7db3c9",
    ),
  );

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
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
