import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HouseLooApp());
}

class HouseLooApp extends StatelessWidget {
  const HouseLooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HouseLoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
