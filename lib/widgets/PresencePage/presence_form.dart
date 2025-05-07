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
  final TextEditingController noteController;
  final VoidCallback onSubmit;
  final bool showNote;
  final bool enableImageUpload;

  const PresenceForm({
    Key? key,
    required this.presensi,
    required this.onPresensiChanged,
    required this.imageFile,
    required this.fileName,
    required this.onChooseFile,
    required this.dateController,
    required this.noteController,
    required this.onSubmit,
    this.showNote = false,
    this.enableImageUpload = true,
  }) : super(key: key);

  List<DropdownMenuItem<String>> _buildStatusItems() {
    // Uncomment time validation
    final now = DateTime.now();
    final cutoffTime = DateTime(
      now.year,
      now.month,
      now.day,
      07,
      15,
    ); // 07:15

    if (now.isAfter(cutoffTime)) {
      return [
        DropdownMenuItem(value: 'Late', child: Text('Terlambat')),
        DropdownMenuItem(value: 'Permission', child: Text('Izin')),
        DropdownMenuItem(value: 'Sick', child: Text('Sakit')),
      ];
    }

    return [
      DropdownMenuItem(value: 'Present', child: Text('Hadir')),
      DropdownMenuItem(value: 'Permission', child: Text('Izin')),
      DropdownMenuItem(value: 'Sick', child: Text('Sakit')),
    ];
  }

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
              borderSide:
                  BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.transparent, width: 2),
            ),
          ),
          items: _buildStatusItems(),
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
            fillColor: !enableImageUpload
                ? Colors.grey[200]
                : Color.fromRGBO(241, 244, 255, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: !enableImageUpload
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
              onPressed: !enableImageUpload ? null : onChooseFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: !enableImageUpload
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
            helperText: !enableImageUpload
                ? 'Tidak perlu upload gambar untuk status ini'
                : 'Upload file surat izin/sakit',
            helperStyle: GoogleFonts.plusJakartaSans(
              color: !enableImageUpload ? Colors.grey : Colors.grey[600],
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

        // Input catatan (hanya muncul untuk status Sakit dan Izin)
        if (showNote) ...[
          TextFormField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Catatan (Opsional)',
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              hintText: 'Masukkan alasan atau catatan tambahan',
              filled: true,
              fillColor: Color.fromRGBO(241, 244, 255, 1),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.transparent, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],

        //Input tanggal (dinonaktifkan, menampilkan tanggal hari ini)
        TextFormField(
          controller: dateController,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Tanggal (Hari Ini)',
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            filled: true,
            fillColor: Colors.grey[200],
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.transparent, width: 2),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
            helperText: 'Absensi hanya dapat dilakukan untuk hari ini',
            helperStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: 35),

        //Button kirim
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
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
