import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PresenceForm extends StatelessWidget {
  final String? presensi;
  final Function(String?) onPresensiChanged;
  final XFile? imageFile;
  final String? fileName;
  final VoidCallback onChooseFile;
  final TextEditingController dateController;
  final Function(BuildContext) onSelectDate;

  const PresenceForm({
    Key? key,
    required this.presensi,
    required this.onPresensiChanged,
    required this.imageFile,
    required this.fileName,
    required this.onChooseFile,
    required this.dateController,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: presensi,
          hint: Text(
            'Pilih Presensi',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          decoration: InputDecoration(
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            filled: true,
            fillColor: Color.fromRGBO(241, 244, 255, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.transparent, width: 2),
            ),
          ),
          items: [
            DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
            DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
            DropdownMenuItem(value: 'Izin', child: Text('Izin')),
          ],
          onChanged: onPresensiChanged,
          validator: (value) {
            if (value == null) return 'Pilih status presensi';
            return null;
          },
        ),
        SizedBox(height: 20),

//input gambar
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Masukkan Foto Surat',
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            filled: true,
            fillColor: presensi == 'Hadir'
                ? Colors.grey[200]
                : Color.fromRGBO(241, 244, 255, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: presensi == 'Hadir'
                    ? Colors.grey
                    : Color.fromRGBO(31, 80, 154, 1),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.transparent, width: 2),
            ),
            suffixIcon: ElevatedButton(
              onPressed: presensi == 'Hadir' ? null : onChooseFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: presensi == 'Hadir'
                    ? Colors.grey
                    : Color.fromRGBO(31, 80, 154, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pilih File',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                ),
              ),
            ),
            helperText: presensi == 'Hadir'
                ? 'Tidak perlu upload gambar jika hadir'
                : 'Upload file surat izin/sakit',
            helperStyle: GoogleFonts.plusJakartaSans(
              color: presensi == 'Hadir' ? Colors.grey : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              fileName!,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
              ),
            ),
          ),
        if (imageFile != null) ...[
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imageFile!.path),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        SizedBox(height: 20),

//Input tanggal
        TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Masukkan Tanggal',
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            filled: true,
            fillColor: Color.fromRGBO(241, 244, 255, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.transparent, width: 2),
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => onSelectDate(context),
        ),
        SizedBox(height: 35),

//Button kirim
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Implementasi logika pengiriman
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: const Color.fromRGBO(31, 80, 154, 1),
            ),
            child: Text(
              'Kirim',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}