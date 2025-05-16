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
    // Mendeteksi ukuran layar untuk responsivitas
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;
    final double contentPadding = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 80, 154, 1),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Konten yang bisa di-scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header dengan text "Profile" di tengah
                          Padding(
                            padding: EdgeInsets.only(
                              top: isSmallScreen ? 50.0 : 60.0,
                              bottom: isSmallScreen ? 25.0 : 35.0,
                            ),
                            child: Center(
                              child: Text(
                                'Profile',
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
                                topLeft:
                                    Radius.circular(isSmallScreen ? 30 : 40),
                                topRight:
                                    Radius.circular(isSmallScreen ? 30 : 40),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(contentPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: isSmallScreen ? 80 : 90),

                                  // Avatar/Profile Picture
                                  CircleAvatar(
                                    radius: isSmallScreen ? 45 : 50,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(
                                      Icons.person_outline,
                                      size: isSmallScreen ? 45 : 50,
                                      color: Colors.grey[400],
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 20 : 25),

                                  // Nama Siswa
                                  Text(
                                    student?.name ?? 'Loading...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: isSmallScreen ? 15 : 20),

                                  // Info Kelas
                                  Text(
                                    'Kelas: ${student?.classInfo.name ?? 'Loading...'}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: isSmallScreen ? 5 : 8),

                                  // NIS
                                  Text(
                                    'NIS: ${student?.nis ?? 'Loading...'}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: isSmallScreen ? 5 : 8),

                                  // NISN
                                  Text(
                                    'NISN: ${student?.nisn ?? 'Loading...'}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: isSmallScreen ? 30 : 40),

                                  // Tombol Keluar Akun
                                  SizedBox(
                                    width: isSmallScreen ? 180 : 200,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        // Implementasi logout
                                        await TokenHelper.removeToken();
                                        Get.off(() => LoginScreen());
                                      },
                                      icon: Icon(
                                        Icons.logout,
                                        size: isSmallScreen ? 18 : 20,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Keluar Akun',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(31, 80, 154, 1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),

                                  // Tambahkan padding di bawah untuk memberikan ruang saat scroll
                                  SizedBox(height: isSmallScreen ? 40 : 60),
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
                  child: CustomNavigationBar(currentIndex: 3),
                ),
              ],
            ),
    );
  }
}
