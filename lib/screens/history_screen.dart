import 'package:flutter/material.dart';
import 'package:student_absence/widgets/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromRGBO(242, 242, 242, 1), // Background utama aplikasi
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 40, 16, 8),
              child: Text(
                'Absensi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Color.fromRGBO(157, 157, 157, 1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 16, 8),
              child: Text(
                'Halo Adji Ardiansyah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(70, 66, 85, 1),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Konten Card (Full Width)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(31, 80, 154, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                child: ListView.builder(
                  itemCount: 10, // Jumlah item dalam daftar
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.teal,
                          ),
                          title: Text(
                            'Hadir',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            '24/01/2024',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }
}
