import 'package:flutter/material.dart';
import 'package:legocontroller/screens/home-screen.dart';
import 'package:legocontroller/style/app_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEGO Controller',
      theme: AppStyle.theme,
      home: const HomeScreen(),
    );
  }
}