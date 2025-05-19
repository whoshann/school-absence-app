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
    // Menampilkan semua opsi tanpa validasi waktu
    return [
      DropdownMenuItem(value: 'Present', child: Text('Hadir')),
      DropdownMenuItem(value: 'Late', child: Text('Terlambat')),
      DropdownMenuItem(value: 'Permission', child: Text('Izin')),
      DropdownMenuItem(value: 'Sick', child: Text('Sakit')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi ukuran layar untuk responsivitas
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown Pilih Presensi
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
            fillColor: Color.fromRGBO(240, 240, 240, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
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
        SizedBox(height: 24),

        // Label untuk file upload
        Row(
          children: [
            Text(
              'Masukkan Foto Surat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 4),
            Text(
              !enableImageUpload ? '' : '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // Input gambar
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: !enableImageUpload
                ? Colors.grey[200]
                : Color.fromRGBO(240, 240, 240, 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: !enableImageUpload
                    ? Colors.grey
                    : Color.fromRGBO(31, 80, 154, 1),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
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
                : 'Upload file surat izin/sakit wajib diisi',
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
          // Label untuk catatan
          Text(
            'Catatan (Opsional)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),

          TextFormField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan atau catatan tambahan',
              filled: true,
              fillColor: Color.fromRGBO(240, 240, 240, 1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:
                    BorderSide(color: Color.fromRGBO(31, 80, 154, 1), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.transparent, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],

        SizedBox(height: 15),

        // Button kirim
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
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
