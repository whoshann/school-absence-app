import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_absence/screens/splash_screen.dart'; 

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // SplashScreen sebagai halaman pertama
    );
  }
}
