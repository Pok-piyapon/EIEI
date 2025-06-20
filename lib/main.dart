import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';

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
