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
import '../services/absence_service.dart';

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
  final AbsenceService _absenceService = AbsenceService();
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasAbsenceToday = false;
  String _todayAbsenceStatus = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Set tanggal hari ini dengan format "dd/MM/yy"
    final now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString().substring(2, 4);
    _dateController.text = "$day/$month/$year";

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Coba mendapatkan data siswa untuk validasi
      final student = await _studentService.getCurrentStudent();

      // Periksa apakah siswa sudah absen hari ini
      await _checkTodayAbsence(student.id);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _checkTodayAbsence(int studentId) async {
    try {
      // Ambil tanggal hari ini
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Ambil data absensi untuk bulan ini
      final absences = await _absenceService.getMonthlyAbsences(
        studentId,
        now,
      );

      // Kunci untuk tanggal hari ini dalam format yang digunakan oleh absences
      final String todayKey = "${today.year}-${today.month}-${today.day}";

      // Cek apakah ada data absensi untuk hari ini
      if (absences.containsKey(todayKey)) {
        setState(() {
          _hasAbsenceToday = true;
          _todayAbsenceStatus = absences[todayKey]?['status'] ?? '';
        });
      } else {
        setState(() {
          _hasAbsenceToday = false;
          _todayAbsenceStatus = '';
        });
      }
    } catch (e) {
      logger.e('Error checking today\'s absence: $e');
      setState(() {
        _hasAbsenceToday = false;
      });
    }
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
        // Cek area sekolah untuk status Hadir dan Terlambat
        if (_presensi == 'Present' ||
            _presensi == 'Hadir' ||
            _presensi == 'Late' ||
            _presensi == 'Terlambat') {
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
      // Hitung jarak antara posisi pengguna dan sekolah
      final double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        PresenceConstants.SMKN4_LOCATION.latitude,
        PresenceConstants.SMKN4_LOCATION.longitude,
      );

      // Log detail perhitungan untuk debugging
      logger.d(
          '=================== PRESENCE SCREEN LOCATION CHECK ===================');
      logger.d('Jarak ke sekolah: $distanceInMeters meter');
      logger.d(
          'Radius yang diizinkan: ${PresenceConstants.RADIUS_IN_METERS} meter');
      logger.d(
          'Posisi Anda: [${_currentPosition!.latitude}, ${_currentPosition!.longitude}]');
      logger.d(
          'Posisi sekolah: [${PresenceConstants.SMKN4_LOCATION.latitude}, ${PresenceConstants.SMKN4_LOCATION.longitude}]');
      logger.d(
          'Berada di dalam area sekolah: ${distanceInMeters <= PresenceConstants.RADIUS_IN_METERS}');
      logger.d('=============================================================');

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
      // Log awal submit presence
      logger
          .d('=================== SUBMIT PRESENCE STARTED ===================');
      logger.d('Status: $_presensi');
      logger.d(
          'Current Position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      logger.d('Is Within School Area: $isWithinSchoolArea');
      logger.d('=============================================================');

      // Validasi input dasar
      if (_presensi == null || _dateController.text.isEmpty) {
        logger.d('Validasi gagal: presensi atau tanggal kosong');
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

      logger.d('Status setelah konversi: $backendStatus');

      // Validasi lokasi untuk status Present DAN Late (terlambat)
      if (backendStatus == 'Present' || backendStatus == 'Late') {
        if (_currentPosition == null) {
          logger.d('Lokasi belum tersedia, mencoba mendapatkan lokasi...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon tunggu, sedang mendapatkan lokasi...'),
              backgroundColor: Colors.orange,
            ),
          );
          await _getCurrentLocation(); // Mencoba mendapatkan lokasi lagi

          if (_currentPosition == null) {
            logger.d('Gagal mendapatkan lokasi setelah mencoba ulang');
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
          logger.d('Lokasi tidak valid: berada di luar area sekolah');
          // Tampilkan dialog error lokasi
          _showLocationErrorDialog(
              backendStatus == 'Present' ? 'hadir' : 'terlambat');
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
        position: (backendStatus == 'Present' || backendStatus == 'Late')
            ? _currentPosition
            : null,
        photo: _imageFile,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (!mounted) return;

      // Tutup loading indicator
      Navigator.of(context).pop();

      // Tampilkan dialog sukses yang responsif
      _showSuccessDialog();

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

  // Dialog notifikasi absensi berhasil
  void _showSuccessDialog() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog tidak dapat ditutup dengan klik di luar
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxWidth: 320,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon sukses
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: isSmallScreen ? 50 : 60,
                  ),
                ),
                SizedBox(height: 20),

                // Teks sukses
                Text(
                  'Absensi Berhasil!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                Text(
                  'Data absensi Anda berhasil disimpan ke sistem.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Tombol OK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Refresh data setelah dialog ditutup
                      _loadInitialData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(31, 80, 154, 1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog notifikasi error lokasi
  void _showLocationErrorDialog(String absenceType) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    // Hitung jarak untuk informasi debugging
    double distanceInMeters = 0;
    if (_currentPosition != null) {
      distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        PresenceConstants.SMKN4_LOCATION.latitude,
        PresenceConstants.SMKN4_LOCATION.longitude,
      );
    }

    // Ambil nilai radius langsung dari konstanta (untuk memastikan nilai terbaru)
    final double currentRadius = PresenceConstants.RADIUS_IN_METERS;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog tidak dapat ditutup dengan klik di luar
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxWidth: 320,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon error
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off,
                    color: Colors.red[700],
                    size: isSmallScreen ? 50 : 60,
                  ),
                ),
                SizedBox(height: 20),

                // Teks error
                Text(
                  'Lokasi Tidak Valid',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                Text(
                  'Anda harus berada di area sekolah untuk melakukan absensi $absenceType.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                // Info jarak (untuk debugging)
                Text(
                  'Jarak Anda dari sekolah: ${distanceInMeters.toStringAsFixed(1)} meter\nJarak maksimum: ${currentRadius.toStringAsFixed(1)} meter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                // Info tambahan koordinat untuk debugging
                Text(
                  'Koordinat Anda: [${_currentPosition?.latitude.toStringAsFixed(6) ?? 0}, ${_currentPosition?.longitude.toStringAsFixed(6) ?? 0}]\nKoordinat sekolah: [${PresenceConstants.SMKN4_LOCATION.latitude.toStringAsFixed(6)}, ${PresenceConstants.SMKN4_LOCATION.longitude.toStringAsFixed(6)}]',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                // Tombol OK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Mengerti',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendeteksi ukuran layar
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;
    final double contentPadding = isSmallScreen ? 20.0 : 24.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(31, 80, 154, 1),
          ),
        ),
      );
    }

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
                            110,
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
                            // Banner Error jika ada masalah loading data
                            if (_hasError) _buildErrorBanner(isSmallScreen),

                            // Card dengan ikon dan teks - warna hijau jika sudah absen, kuning jika belum
                            Center(
                              child: Card(
                                margin: EdgeInsets.only(
                                    bottom: isSmallScreen ? 20.0 : 24.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 12 : 16),
                                ),
                                color: _hasAbsenceToday
                                    ? Color.fromRGBO(
                                        232, 245, 233, 1) // Hijau light
                                    : Color.fromRGBO(
                                        255, 249, 230, 1), // Kuning light
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
                                              _hasAbsenceToday
                                                  ? 'Anda sudah absensi untuk hari ini'
                                                  : 'Kamu belum absen hari ini',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize:
                                                    isSmallScreen ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: _hasAbsenceToday
                                                    ? Color.fromRGBO(46, 125,
                                                        50, 1) // Hijau text
                                                    : Color.fromRGBO(44, 44, 44,
                                                        1), // Grey text
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _hasAbsenceToday
                                                  ? 'Status: ${_getStatusText(_todayAbsenceStatus)}'
                                                  : 'Yuk segera isi form di bawah ya!',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize:
                                                    isSmallScreen ? 11 : 13,
                                                color: _hasAbsenceToday
                                                    ? Color.fromRGBO(46, 125,
                                                        50, 1) // Hijau text
                                                    : Color.fromRGBO(44, 44, 44,
                                                        1), // Grey text
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

                            // Widget lokasi - nonaktifkan jika ada error
                            Opacity(
                              opacity: _hasError ? 0.6 : 1.0,
                              child: AbsorbPointer(
                                absorbing: _hasError,
                                child: LocationMapWidget(
                                  currentPosition: _currentPosition,
                                  isLoadingLocation: _isLoadingLocation,
                                  onRetryLocation: _getCurrentLocation,
                                  presensi: _presensi,
                                  isWithinSchoolArea: isWithinSchoolArea,
                                  smkn4Location:
                                      PresenceConstants.SMKN4_LOCATION,
                                  visualRadius: PresenceConstants.VISUAL_RADIUS,
                                  onLocationButtonPressed: () {
                                    _getCurrentLocation();
                                    if (_presensi == 'Present' ||
                                        _presensi == 'Hadir' ||
                                        _presensi == 'Late' ||
                                        _presensi == 'Terlambat') {
                                      _checkIfWithinSchool();
                                    }
                                  },
                                ),
                              ),
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

                            // Form presensi - nonaktifkan jika ada error atau siswa sudah absen
                            Opacity(
                              opacity:
                                  (_hasError || _hasAbsenceToday) ? 0.6 : 1.0,
                              child: AbsorbPointer(
                                absorbing: _hasError || _hasAbsenceToday,
                                child: PresenceForm(
                                  presensi: _presensi,
                                  onPresensiChanged: (value) {
                                    setState(() {
                                      _presensi = value;
                                      if (value == 'Present' ||
                                          value == 'Hadir' ||
                                          value == 'Late' ||
                                          value == 'Terlambat') {
                                        _imageFile = null;
                                        _fileName = null;
                                        // Selalu cek kembali lokasi ketika mengubah presensi menjadi Hadir atau Terlambat
                                        _checkIfWithinSchool();
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
                                  enableImageUpload: _presensi != 'Present' &&
                                      _presensi != 'Hadir' &&
                                      _presensi != 'Late' &&
                                      _presensi != 'Terlambat',
                                ),
                              ),
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

  // Widget untuk menampilkan banner error
  Widget _buildErrorBanner(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 235, 238, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Terjadi kesalahan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tidak dapat memuat data. Form absensi tidak dapat digunakan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Muat Ulang',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan teks status yang lebih baik dari kode status
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Hadir';
      case 'permission':
        return 'Izin';
      case 'sick':
        return 'Sakit';
      case 'alpha':
        return 'Alpha';
      case 'late':
        return 'Terlambat';
      default:
        return status;
    }
  }
}
