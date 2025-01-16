import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color.fromRGBO(31, 80, 154, 1),
      child: Container(
        height: 170,
        padding: const EdgeInsets.fromLTRB(40.0, 12.0, 20.0, 16.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/presence.png',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Selamat datang, harap isi absensi kehadiran anda dengan benar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}