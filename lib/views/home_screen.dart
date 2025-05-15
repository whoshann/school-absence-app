import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/student_service.dart';
import 'package:student_absence/utils/token_helper.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart';
import 'package:student_absence/models/student.dart';
import '../services/absence_service.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentService _studentService = StudentService();
  final AbsenceService _absenceService = AbsenceService();
  final logger = Logger();
  String selectedMonth = 'Januari';
  Map<String, int> monthNumbers = {
    'Januari': 1,
    'Februari': 2,
    'Maret': 3,
    'April': 4,
    'Mei': 5,
    'Juni': 6,
    'Juli': 7,
    'Agustus': 8,
    'September': 9,
    'Oktober': 10,
    'November': 11,
    'Desember': 12,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    try {
      final student = await _studentService.getCurrentStudent();
      final currentYear = DateTime.now().year;
      final selectedMonthNumber = monthNumbers[selectedMonth] ?? 1;

      // Menggunakan method getStatistics yang baru
      final statistics = await _absenceService.getStatistics(
        student.id,
        year: currentYear,
        month: selectedMonthNumber,
      );

      return {
        'student': student,
        'statistics': statistics,
      };
    } catch (e) {
      logger.e('Error loading data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final statistics = snapshot.data!['statistics'] as Map<String, int>;

          return SingleChildScrollView(
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
                            left: 23.0, top: 40.0), 
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
                                snapshot.data!['student']?.name ?? 'Loading...',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(70, 66, 85, 1),
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                snapshot.data!['student']?.classInfo.name ??
                                    'Loading...',
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
                            color: Colors.grey[300]!,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedMonth,
                          dropdownColor: Colors.white,
                          items: monthNumbers.keys.map((String value) {
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
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedMonth = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Color.fromRGBO(31, 80, 154, 1),
                            value: statistics['present']?.toDouble() ?? 0,
                            title:
                                '${_calculatePercentage(statistics['present'] ?? 0, statistics)}%',
                            titleStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Color.fromRGBO(229, 127, 5, 1),
                            value: statistics['permission']?.toDouble() ?? 0,
                            title:
                                '${_calculatePercentage(statistics['permission'] ?? 0, statistics)}%',
                            titleStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Color.fromRGBO(10, 151, 176, 1),
                            value: statistics['sick']?.toDouble() ?? 0,
                            title:
                                '${_calculatePercentage(statistics['sick'] ?? 0, statistics)}%',
                            titleStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Color.fromRGBO(223, 5, 5, 1),
                            value: statistics['alpha']?.toDouble() ?? 0,
                            title:
                                '${_calculatePercentage(statistics['alpha'] ?? 0, statistics)}%',
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

                // 4 Card Statistik dengan data yang dinamis
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
                        statistics['present'].toString(),
                        Color.fromRGBO(31, 80, 154, 1),
                      ),
                      _buildStatCard(
                        'Anda izin sebanyak',
                        statistics['permission'].toString(),
                        Color.fromRGBO(229, 127, 5, 1),
                      ),
                      _buildStatCard(
                        'Anda sakit sebanyak',
                        statistics['sick'].toString(),
                        Color.fromRGBO(10, 151, 176, 1),
                      ),
                      _buildStatCard(
                        'Anda alpha sebanyak',
                        statistics['alpha'].toString(),
                        Color.fromRGBO(223, 5, 5, 1),
                      ),
                    ],
                  ),
                ),

                // Update Pie Chart dengan data yang dinamis
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }

  // Fungsi untuk menghitung persentase
  int _calculatePercentage(int value, Map<String, int> statistics) {
    final total = (statistics['present'] ?? 0) +
        (statistics['permission'] ?? 0) +
        (statistics['sick'] ?? 0) +
        (statistics['alpha'] ?? 0);

    if (total == 0) return 0;
    return ((value / total) * 100).round();
  }

  // Widget card statistik tetap sama
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
