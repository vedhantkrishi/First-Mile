import 'package:distress_caller/screens/in_distress.dart';
import 'package:distress_caller/screens/landing_page.dart';
import 'package:distress_caller/screens/profile.dart';
import 'package:flutter/material.dart';

/// The Widget that configures your application.
class DistressApp extends StatelessWidget {
  const DistressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distress App',
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/profile': (context) => ProfilePage(),
        '/distress': (context) => DistressInProgressPage(),
      },
      // home: LandingPage(),
    );
  }
}