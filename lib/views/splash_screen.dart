import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Pastikan untuk import GetX
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/views/onboarding_screen.dart'; // Import OnboardingScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menggunakan GetX untuk navigasi setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => OnboardingScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
      body: Center(
        child: Image.asset(
          'assets/images/splash-screen-logo.png',
          width: 100,
        ),
      ),
    );
  }
}
