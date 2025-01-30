import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/student_service.dart';
import 'package:student_absence/utils/token_helper.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart';
import 'package:student_absence/models/student.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      // Decode JWT token untuk mendapatkan ID
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Background Biru dengan Card Putih
                  Stack(
                    children: [
                      // Background Biru
                      Container(
                        height: 200, // Menurunkan tinggi container biru
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(31, 80, 154, 1),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 23.0,
                              top: 40.0), // Mengurangi jarak padding
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Rekap Absen Anda',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Card Putih
                      Positioned(
                        top:
                            80, // Menurunkan posisi card putih agar lebih dekat dengan teks
                        left: 16.0,
                        right: 16.0,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  student?.name ?? 'Loading...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(70, 66, 85, 1),
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  student?.classInfo.name ?? 'Loading...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Dropdown untuk Filter Bulan
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Berdasarkan Bulan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors
                                  .grey[300]!, // Border warna abu-abu muda
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: 'Januari',
                            dropdownColor: Colors.white,
                            items: [
                              'Januari',
                              'Februari',
                              'Maret',
                              'April',
                              'Mei',
                              'Juni',
                              'Juli',
                              'Agustus',
                              'September',
                              'Oktober',
                              'November',
                              'Desember'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pie Chart
                  Center(
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Color.fromRGBO(31, 80, 154, 1),
                              value: 50,
                              title: '50%',
                              titleStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Color.fromRGBO(229, 127, 5, 1),
                              value: 20,
                              title: '20%',
                              titleStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Color.fromRGBO(10, 151, 176, 1),
                              value: 15,
                              title: '15%',
                              titleStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Color.fromRGBO(223, 5, 5, 1),
                              value: 15,
                              title: '15%',
                              titleStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 50,
                        ),
                      ),
                    ),
                  ),

                  // 4 Card Statistik
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 2,
                      children: [
                        _buildStatCard(
                          'Anda hadir sebanyak',
                          '100',
                          Color.fromRGBO(31, 80, 154, 1),
                        ),
                        _buildStatCard('Anda izin sebanyak', '20',
                            Color.fromRGBO(229, 127, 5, 1)),
                        _buildStatCard('Anda sakit sebanyak', '12',
                            Color.fromRGBO(10, 151, 176, 1)),
                        _buildStatCard('Anda alpha sebanyak', '2',
                            Color.fromRGBO(223, 5, 5, 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
