import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/widgets/PresencePage/location_map_widget.dart';
import 'package:student_absence/widgets/PresencePage/presence_form.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/location_services.dart';
import 'package:student_absence/constans/presence_coordinat_constant.dart';
import 'package:student_absence/services/presence_service.dart';
import 'package:logger/logger.dart';
import '../services/student_service.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final logger = Logger();
  String? _presensi;
  XFile? _imageFile;
  String? _fileName;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool isWithinSchoolArea = false;
  final StudentService _studentService = StudentService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Set tanggal hari ini dengan format "dd/MM/yy"
    final now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year =
        now.year.toString().substring(2, 4); // Ambil 2 digit terakhir
    _dateController.text = "$day/$month/$year";
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position? position = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
        if (_presensi == 'Present') {
          _checkIfWithinSchool();
        }
      }
    } catch (e) {
      logger.e("Error getting location: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _checkIfWithinSchool() {
    if (_currentPosition != null) {
      setState(() {
        isWithinSchoolArea = LocationService.isWithinSchoolArea(
          _currentPosition!,
          PresenceConstants.SMKN4_LOCATION,
          PresenceConstants.RADIUS_IN_METERS,
        );
      });
    }
  }

  Future<void> _chooseFile() async {
    if (_presensi == 'Present' || _presensi == 'Late') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak perlu upload gambar jika hadir atau terlambat'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

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

  Future<void> _submitPresence() async {
    if (!mounted) return;

    try {
      // Validasi input dasar
      if (_presensi == null || _dateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua data'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Konversi status ke format backend
      String backendStatus = _presensi!;
      switch (_presensi) {
        case 'Hadir':
          backendStatus = 'Present';
          break;
        case 'Izin':
          backendStatus = 'Permission';
          break;
        case 'Sakit':
          backendStatus = 'Sick';
          break;
        case 'Terlambat':
          backendStatus = 'Late';
          break;
      }

      // Validasi lokasi untuk status Present
      if (backendStatus == 'Present') {
        if (_currentPosition == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon tunggu, sedang mendapatkan lokasi...'),
              backgroundColor: Colors.orange,
            ),
          );
          await _getCurrentLocation(); // Mencoba mendapatkan lokasi lagi

          if (_currentPosition == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Tidak dapat mendapatkan lokasi. Mohon aktifkan GPS dan coba lagi.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        if (!isWithinSchoolArea) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Anda harus berada di area sekolah untuk melakukan absensi hadir'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Validasi foto untuk status selain Present dan Late
      if ((backendStatus == 'Permission' || backendStatus == 'Sick') &&
          _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon upload foto surat izin/sakit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Dapatkan current student
      final student = await _studentService.getCurrentStudent();

      // Gunakan DateTime.now() yang menyertakan waktu aktual, bukan hanya tanggal
      final now = DateTime.now();

      await PresenceService().submitPresence(
        studentId: student.id,
        status: backendStatus,
        date: now, // Menggunakan waktu saat ini
        position: backendStatus == 'Present' ? _currentPosition : null,
        photo: _imageFile,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (!mounted) return;

      // Tutup loading indicator
      Navigator.of(context).pop();

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _presensi = null;
        _imageFile = null;
        _fileName = null;
        _noteController.text = '';
      });
    } catch (e) {
      if (!mounted) return;

      // Tutup loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      logger.e('Error submitting presence: $e');

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendeteksi ukuran layar
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;
    final double contentPadding = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 80, 154, 1),
      body: Column(
        children: [
          // Konten yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    // Header dengan text "Absensi" di tengah
                    Padding(
                      padding: EdgeInsets.only(
                        top: isSmallScreen ? 50.0 : 60.0,
                        bottom: isSmallScreen ? 25.0 : 35.0,
                      ),
                      child: Center(
                        child: Text(
                          'Absensi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Konten utama (card putih)
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            110, // Untuk memastikan card menutupi seluruh screen
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isSmallScreen ? 30 : 40),
                          topRight: Radius.circular(isSmallScreen ? 30 : 40),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(contentPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card kuning dengan ikon dan teks (di dalam card putih)
                            Center(
                              child: Card(
                                margin: EdgeInsets.only(
                                    bottom: isSmallScreen ? 20.0 : 24.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 12 : 16),
                                ),
                                color: Color.fromRGBO(255, 249, 230, 1),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      isSmallScreen ? 16.0 : 20.0),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'assets/images/presence.png',
                                          height: isSmallScreen ? 60 : 70,
                                          width: isSmallScreen ? 60 : 70,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 16 : 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kamu belum absen hari ini',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize:
                                                    isSmallScreen ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    44, 44, 44, 1),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Yuk segera isi form di bawah ya!',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize:
                                                    isSmallScreen ? 11 : 13,
                                                color: Color.fromRGBO(
                                                    44, 44, 44, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Form Absensi text
                            Text(
                              'Form Absensi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(44, 44, 44, 1),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 24),

                            // Tanggal (Hari Ini)
                            Text(
                              'Tanggal (Hari Ini)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),

                            // Input tanggal (dengan sudut rounded)
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 2),
                                ),
                                suffixIcon: Icon(Icons.calendar_today,
                                    color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Widget lokasi
                            LocationMapWidget(
                              currentPosition: _currentPosition,
                              isLoadingLocation: _isLoadingLocation,
                              onRetryLocation: _getCurrentLocation,
                              presensi: _presensi,
                              isWithinSchoolArea: isWithinSchoolArea,
                              smkn4Location: PresenceConstants.SMKN4_LOCATION,
                              visualRadius: PresenceConstants.VISUAL_RADIUS,
                              onLocationButtonPressed: () {
                                _getCurrentLocation();
                                if (_presensi == 'Present')
                                  _checkIfWithinSchool();
                              },
                            ),
                            SizedBox(height: 20),

                            // Label untuk Pilih Presensi
                            Row(
                              children: [
                                Text(
                                  'Pilih Presensi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Form presensi
                            PresenceForm(
                              presensi: _presensi,
                              onPresensiChanged: (value) {
                                setState(() {
                                  _presensi = value;
                                  if (value == 'Present') {
                                    _imageFile = null;
                                    _fileName = null;
                                    _checkIfWithinSchool();
                                  } else if (value == 'Late') {
                                    _imageFile = null;
                                    _fileName = null;
                                  }
                                });
                              },
                              imageFile: _imageFile,
                              fileName: _fileName,
                              onChooseFile: _chooseFile,
                              dateController: _dateController,
                              noteController: _noteController,
                              onSubmit: _submitPresence,
                              showNote: _presensi == 'Sick' ||
                                  _presensi == 'Permission',
                              enableImageUpload:
                                  _presensi != 'Present' && _presensi != 'Late',
                            ),

                            // Tambahkan padding di bawah untuk memberikan ruang saat scroll
                            SizedBox(height: isSmallScreen ? 20 : 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar dalam Container warna putih
          Container(
            color: Colors.white,
            child: CustomNavigationBar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
