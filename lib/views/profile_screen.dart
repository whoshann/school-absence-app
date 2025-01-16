import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1), // Warna background utama
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container biru untuk profil
            Container(
              height: 520, // Tinggi card biru
              decoration: BoxDecoration(
                color: Color.fromRGBO(31, 80, 154, 1), // Warna biru
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon profil
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: CircleAvatar(
                      radius: 50, // Ukuran ikon profil
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color.fromRGBO(31, 80, 154, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Nama pengguna
                  Text(
                    'Adji Ardiansyah Wahyu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Informasi tambahan
                  Text(
                    'Kelas: XI RPL C\nNIS: 24466377234\nNISN: 0074385837',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      color: Color.fromRGBO(157, 157, 157, 1),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Tombol Keluar Akun dengan panjang lebih pendek
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 200, // Panjang tombol disesuaikan
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Tambahkan logika untuk keluar akun
                        },
                        icon: Icon(Icons.logout, size: 20), // Ukuran ikon kecil
                        label: Text(
                          'Keluar Akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, // Font size lebih kecil
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromRGBO(104, 104, 104, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12), // Padding vertikal
                          elevation: 2, // Efek bayangan
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
    );
  }
}
