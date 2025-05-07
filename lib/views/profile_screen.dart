import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/student_service.dart';
import 'package:student_absence/models/student.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:student_absence/utils/token_helper.dart';
import 'package:get/get.dart';
import 'package:student_absence/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StudentService _studentService = StudentService();
  Student? student;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final token = await TokenHelper.getToken();
      final decodedToken = JwtDecoder.decode(token!);
      final studentId = decodedToken['sub'];

      print('Loading student data for ID: $studentId');

      final studentData = await _studentService.getCurrentStudent();

      setState(() {
        student = studentData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading student data: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat data siswa',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 520,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(31, 80, 154, 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 70),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color.fromRGBO(31, 80, 154, 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          student?.name ?? 'Loading...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Kelas: ${student?.classInfo.name ?? 'Loading...'}\n'
                          'NIS: ${student?.nis ?? 'Loading...'}\n'
                          'NISN: ${student?.nisn ?? 'Loading...'}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            color: Color.fromRGBO(157, 157, 157, 1),
                          ),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Implementasi logout
                                await TokenHelper.removeToken();
                                Get.off(() => LoginScreen());// Navigasi ke halaman login
                              },
                              icon: Icon(Icons.logout, size: 20),
                              label: Text(
                                'Keluar Akun',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    Color.fromRGBO(104, 104, 104, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
    );
  }
}
