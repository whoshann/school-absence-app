import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teks kecil "Sis" di atas gambar
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: Text(
                  "Sis",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(44, 44, 44, 1),
                  ),
                ),
              ),

              Container(
                width: screenSize.width * 0.85,
                child: Image.asset(
                  'assets/images/onboarding.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40),

              // Teks besar dengan batasan lebar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), 
                child: Text(
                  'Kelola Kehadiranmu Dengan Mudah!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(44, 44, 44, 1),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Teks kecil dengan batasan lebar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50), 
                child: Text(
                  'Pantau riwayat absensi dan tetap produktif setiap hari',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    color: const Color.fromARGB(255, 101, 101, 101),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Tombol bulat
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(31, 80, 154, 1),
                ),
                child: IconButton(
                  onPressed: () {
                    // Direct login page
                    Get.off(() => LoginScreen());
                  },
                  icon:
                      Icon(Icons.arrow_forward, color: Colors.white, size: 40),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
