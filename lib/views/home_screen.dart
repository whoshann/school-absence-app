import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/student_service.dart';
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
  Map<String, dynamic>? _cachedData;
  bool _isLoading = true;

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

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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

      if (mounted) {
        setState(() {
          _cachedData = {
            'student': student,
            'statistics': statistics,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateMonth(String newMonth) {
    if (selectedMonth != newMonth) {
      setState(() {
        selectedMonth = newMonth;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 80, 154, 1),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cachedData == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    // Jika ada error tapi tidak ada data yang di-cache
    if (!_isLoading && _cachedData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gagal memuat data',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(31, 80, 154, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Gunakan data cache saat loading, atau data baru saat sudah selesai
    final data = _cachedData!;
    final statistics = data['statistics'] as Map<String, int>;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan nama dan kelas
          Padding(
            padding: const EdgeInsets.only(
                left: 24.0, top: 70.0, right: 24.0, bottom: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['student']?.name ?? 'Loading...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  data['student']?.classInfo.name ?? 'Loading...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Konten utama (card putih) termasuk bottom navbar
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Konten scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          // Konten utama
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rekap Kehadiran Anda
                                Text(
                                  'Rekap Kehadiran Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(44, 44, 44, 1),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Filter Bulan
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Filter Bulan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showMonthSelectionDialog(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              selectedMonth,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.keyboard_arrow_down,
                                                size: 18)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),

                                // Indikator loading di tengah saat refresh
                                if (_isLoading)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(31, 80, 154, 1),
                                      ),
                                    ),
                                  ),

                                // Tempat untuk chart
                                Center(
                                  child: SizedBox(
                                    height: 300,
                                    width: 300,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            color:
                                                Color.fromRGBO(31, 80, 154, 1),
                                            value: statistics['present']
                                                    ?.toDouble() ??
                                                0,
                                            title:
                                                '${_calculatePercentage(statistics['present'] ?? 0, statistics)}%',
                                            titleStyle:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            color:
                                                Color.fromRGBO(229, 127, 5, 1),
                                            value: statistics['permission']
                                                    ?.toDouble() ??
                                                0,
                                            title:
                                                '${_calculatePercentage(statistics['permission'] ?? 0, statistics)}%',
                                            titleStyle:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            color:
                                                Color.fromRGBO(10, 151, 176, 1),
                                            value: statistics['sick']
                                                    ?.toDouble() ??
                                                0,
                                            title:
                                                '${_calculatePercentage(statistics['sick'] ?? 0, statistics)}%',
                                            titleStyle:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            color: Color.fromRGBO(223, 5, 5, 1),
                                            value: statistics['alpha']
                                                    ?.toDouble() ??
                                                0,
                                            title:
                                                '${_calculatePercentage(statistics['alpha'] ?? 0, statistics)}%',
                                            titleStyle:
                                                GoogleFonts.plusJakartaSans(
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
                                SizedBox(height: 24),

                                // 4 Card Statistik
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 16.0,
                                  crossAxisSpacing: 16.0,
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
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Navigation Bar sebagai bagian dari Container putih
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: CustomNavigationBar(currentIndex: 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Bulan'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: monthNumbers.length,
              itemBuilder: (context, index) {
                final month = monthNumbers.keys.elementAt(index);
                return ListTile(
                  title: Text(month),
                  onTap: () {
                    Navigator.pop(context);
                    _updateMonth(month);
                  },
                  trailing: month == selectedMonth
                      ? Icon(Icons.check, color: Color.fromRGBO(31, 80, 154, 1))
                      : null,
                );
              },
            ),
          ),
        );
      },
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
