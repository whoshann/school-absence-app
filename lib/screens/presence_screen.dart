import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class PresenceScreen extends StatefulWidget {
  @override
  _PresenceScreenState createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  String? _presensi; // Ubah menjadi nullable
  TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _fileName;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  final LatLng smkn4Location = LatLng(-8.05905443503718, 112.65058997997427);
  bool isWithinSchoolArea = false;
  final double radiusInMeters = 100;
  final double visualRadius = 50;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _checkIfWithinSchool() {
    if (_currentPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        smkn4Location.latitude,
        smkn4Location.longitude,
      );

      setState(() {
        isWithinSchoolArea = distanceInMeters <= radiusInMeters;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      if (_presensi == 'Hadir') {
        _checkIfWithinSchool();
      }
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _chooseFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        String extension = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Format file harus JPG, JPEG, atau PNG'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _imageFile = pickedFile;
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      print('Error memilih gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SafeArea(
          child: Column(
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
              SizedBox(height: 30),

//Card Welcome
              Card(
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
              ),
              SizedBox(height: 20),

//Card Input
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color.fromRGBO(255, 255, 255, 1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_presensi == 'Hadir' &&
                          !_isLoadingLocation &&
                          _currentPosition != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isWithinSchoolArea ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isWithinSchoolArea
                                ? 'Anda berada dalam area sekolah, silahkan mengisi data absensi dengan benar'
                                : 'Anda berada di luar area sekolah, harap menuju area sekolah untuk melakukan absensi',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Text(
                        'Lokasi Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _isLoadingLocation
                              ? Center(child: CircularProgressIndicator())
                              : _currentPosition == null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.location_off,
                                              size: 48, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tidak dapat mengakses lokasi',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _getCurrentLocation,
                                            child: Text('Coba Lagi'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        FlutterMap(
                                          options: MapOptions(
                                            initialCenter: LatLng(
                                              _currentPosition!.latitude,
                                              _currentPosition!.longitude,
                                            ),
                                            initialZoom: 15,
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName:
                                                  'com.example.app',
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: smkn4Location,
                                                  child: _presensi == 'Hadir'
                                                      ? Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  visualRadius *
                                                                      2,
                                                              height:
                                                                  visualRadius *
                                                                      2,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: isWithinSchoolArea
                                                                    ? Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.2)
                                                                    : Colors.red
                                                                        .withOpacity(
                                                                            0.2),
                                                                border:
                                                                    Border.all(
                                                                  color: isWithinSchoolArea
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                  width: 2,
                                                                ),
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.school,
                                                              color:
                                                                  Colors.blue,
                                                              size: 24,
                                                            ),
                                                          ],
                                                        )
                                                      : Icon(
                                                          Icons.school,
                                                          color: Colors.blue,
                                                          size: 40,
                                                        ),
                                                ),
                                                Marker(
                                                  point: LatLng(
                                                    _currentPosition!.latitude,
                                                    _currentPosition!.longitude,
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: FloatingActionButton.small(
                                            onPressed: () {
                                              _getCurrentLocation();
                                              if (_presensi == 'Hadir') {
                                                _checkIfWithinSchool();
                                              }
                                            },
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.my_location,
                                              color: Color.fromRGBO(
                                                  31, 80, 154, 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      SizedBox(height: 20),

//Input Presensi
                      DropdownButtonFormField<String>(
                        value: _presensi,
                        hint: Text(
                          'Pilih Presensi',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight:
                                FontWeight.w500, // Mengatur ketebalan text
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(241, 244, 255, 1),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(31, 80, 154, 1),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 2),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'Hadir', child: Text('Hadir')),
                          DropdownMenuItem(
                              value: 'Sakit', child: Text('Sakit')),
                          DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _presensi = value;
                            if (value == 'Hadir') {
                              _checkIfWithinSchool();
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih status presensi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

//Input Gambar
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Masukkan Foto Surat',
                          filled: true,
                          fillColor: Color.fromRGBO(241, 244, 255, 1),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(31, 80, 154, 1),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 2),
                          ),
                          suffixIcon: ElevatedButton(
                            onPressed: _chooseFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(31, 80, 154, 1),
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
                        ),
                      ),
                      if (_fileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _fileName!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      if (_imageFile != null) ...[
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imageFile!.path),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      SizedBox(height: 20),

//Input Tanggal
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Masukkan Tanggal',
                          filled: true,
                          fillColor: Color.fromRGBO(241, 244, 255, 1),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(31, 80, 154, 1),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 2),
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 35),

//Button Kirim
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Logika kirim
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor:
                                const Color.fromRGBO(31, 80, 154, 1),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }
}
