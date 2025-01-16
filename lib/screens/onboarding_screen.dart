import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Stack(
        children: [
          // Ilustrasi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/onboarding.png',
                    width: 300),
                SizedBox(height: 40),

                // Teks besar dengan batasan lebar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Memberikan jarak horizontal
                  child: Text(
                    'Mengelola Kehadiranmu Dengan Baik',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(31, 80, 154, 1),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Teks kecil dengan batasan lebar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50), // Memberikan jarak horizontal
                  child: Text(
                    'Pantau riwayat absensi dengan mudah dan cepat setiap hari',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      color: const Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol bulat panah di pojok kanan bawah
          Positioned(
            right: 30,
            bottom: 30,
            child: FloatingActionButton(
              onPressed: () {
                // Direct login page
                Get.off(() => LoginScreen());
              },
              child: Icon(Icons.arrow_forward, color: Colors.white),
              backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
            ),
          ),
        ],
      ),
    );
  }
}
