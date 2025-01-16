import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_absence/screens/home_screen.dart'; 
import 'package:google_fonts/google_fonts.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false; // Status untuk menyembunyikan/menampilkan password

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0), // Padding lebih besar
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Menjaga elemen berada di atas
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text Logo
            Text(
              'Logo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(31, 80, 154, 1),
              ),
            ),
            SizedBox(height: 10), // Jarak antar elemen

            // Selamat Datang Kembali
            Text(
              'Selamat Datang Kembali',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: const Color.fromARGB(255, 101, 101, 101),
              ),
            ),
            SizedBox(height: 50), // Menambah jarak lebih besar antar elemen

            // Input Username
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Color.fromRGBO(241, 244, 255, 1), // Warna background input biru
                border: InputBorder.none, // Menghilangkan border default
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding dalam input
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
                  borderSide: BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2), // Warna border saat fokus
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
                  borderSide: BorderSide(color: Colors.transparent, width: 2), // Tidak ada border saat tidak fokus
                ),
              ),
            ),
            SizedBox(height: 35), // Jarak antar elemen

            // Input Password
            TextField(
              obscureText: !_isPasswordVisible, // Tampilkan atau sembunyikan password
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Color.fromRGBO(241, 244, 255, 1), // Warna background input biru
                border: InputBorder.none, // Menghilangkan border default
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding dalam input
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
                  borderSide: BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2), // Warna border saat fokus
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
                  borderSide: BorderSide(color: Colors.transparent, width: 2), // Tidak ada border saat tidak fokus
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 35), // Jarak antar elemen

            // Button Masuk
            SizedBox(
              width: double.infinity, // Lebar tombol sama dengan input
              child: ElevatedButton(
                onPressed: () {
                  // Arahkan ke halaman HomeScreen setelah tombol ditekan menggunakan GetX
                  Get.to(HomeScreen()); // Menavigasi ke HomeScreen
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
                ),
                child: Text(
                  'Masuk',
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
