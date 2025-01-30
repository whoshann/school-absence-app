import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_absence/widgets/PresencePage/location_map_widget.dart';
import 'package:student_absence/widgets/PresencePage/presence_form.dart';
import 'package:student_absence/widgets/PresencePage/presence_header.dart';
import 'package:student_absence/widgets/PresencePage/welcome_card.dart';
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
    if (_presensi == 'Present') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak perlu upload gambar jika hadir'),
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

      // Validasi foto untuk status selain Present
      if (backendStatus != 'Present' && _imageFile == null) {
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

      // Gunakan tanggal hari ini
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await PresenceService().submitPresence(
        studentId: student.id,
        status: backendStatus,
        date: today,
        position: backendStatus == 'Present' ? _currentPosition : null,
        photo: _imageFile,
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
        _dateController.text = '';
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PresenceHeader(),
              SizedBox(height: 30),
              WelcomeCard(),
              SizedBox(height: 20),
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
                          if (_presensi == 'Present') _checkIfWithinSchool();
                        },
                      ),
                      SizedBox(height: 20),
                      PresenceForm(
                        presensi: _presensi,
                        onPresensiChanged: (value) {
                          setState(() {
                            _presensi = value;
                            if (value == 'Present' || value == 'Late') {
                              _imageFile = null;
                              _fileName = null;
                              _checkIfWithinSchool();
                            }
                          });
                        },
                        imageFile: _imageFile,
                        fileName: _fileName,
                        onChooseFile: _chooseFile,
                        dateController: _dateController,
                        onSelectDate: _selectDate,
                        onSubmit: _submitPresence,
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
