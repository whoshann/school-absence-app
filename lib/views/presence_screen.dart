import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_absence/widgets/PresencePage/location_map_widget.dart';
import 'package:student_absence/widgets/PresencePage/presence_form.dart';
import 'package:student_absence/widgets/PresencePage/presence_header.dart';
import 'package:student_absence/widgets/PresencePage/welcome_card.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/location_services.dart';
import 'package:student_absence/constans/presence_constant.dart';


class PresenceScreen extends StatefulWidget {
  @override
  _PresenceScreenState createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  String? _presensi;
  TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _fileName;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool isWithinSchoolArea = false;

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
    if (_presensi == 'Hadir') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload file tidak diperlukan untuk status Hadir'),
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
                          if (_presensi == 'Hadir') _checkIfWithinSchool();
                        },
                      ),
                      SizedBox(height: 20),
                      
                      PresenceForm(
                        presensi: _presensi,
                        onPresensiChanged: (value) {
                          setState(() {
                            _presensi = value;
                            if (value == 'Hadir') {
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