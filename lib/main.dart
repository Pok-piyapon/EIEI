import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';

void main() {
  runApp(MyApp());
}

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
