import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;
    // Tentukan apakah layar kecil (misalnya, smartphone)
    final bool isSmallScreen = screenSize.width < 380;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Teks kecil "Sis" di atas gambar
                Padding(
                  padding: EdgeInsets.only(
                    bottom: isSmallScreen ? 30 : 70,
                    top: isSmallScreen ? 10 : 20,
                  ),
                  child: Text(
                    "Sis",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(44, 44, 44, 1),
                    ),
                  ),
                ),

                Container(
                  width: screenSize.width * (isSmallScreen ? 0.7 : 0.85),
                  child: Image.asset(
                    'assets/images/onboarding.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 40),

                // Teks besar dengan batasan lebar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                  ),
                  child: Text(
                    'Kelola Kehadiranmu Dengan Mudah!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 26 : 35,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(44, 44, 44, 1),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),

                // Teks kecil dengan batasan lebar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 50,
                  ),
                  child: Text(
                    'Pantau riwayat absensi dan tetap produktif setiap hari',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 16 : 21,
                      color: const Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 30 : 40),

                // Tombol bulat
                Container(
                  width: isSmallScreen ? 70 : 85,
                  height: isSmallScreen ? 70 : 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(31, 80, 154, 1),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Direct login page
                      Get.off(() => LoginScreen());
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: isSmallScreen ? 30 : 40,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
