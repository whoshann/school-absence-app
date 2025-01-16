import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PresenceHeader extends StatelessWidget {
  const PresenceHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Absensi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Color.fromRGBO(157, 157, 157, 1),
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Halo Adji Ardiansyah',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(70, 66, 85, 1),
            ),
          ),
        ),
      ],
    );
  }
}