import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:student_absence/services/student_service.dart';
import '../services/absence_service.dart';
import 'package:logger/logger.dart';

// Class Badge untuk menampilkan ikon pada chart
class _Badge extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final double size;

  const _Badge(this.iconData, this.color, {required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(
        iconData,
        color: color,
        size: size,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentService _studentService = StudentService();
  final AbsenceService _absenceService = AbsenceService();
  final logger = Logger();
  late String selectedMonth;
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

  // Fungsi helper untuk mendapatkan nama bulan dari nomor bulan
  String getMonthName(int month) {
    return monthNumbers.entries
        .firstWhere(
          (entry) => entry.value == month,
          orElse: () => const MapEntry('Januari', 1),
        )
        .key;
  }

  @override
  void initState() {
    super.initState();
    // Set bulan default menjadi bulan saat ini
    final currentMonth = DateTime.now().month;
    selectedMonth = getMonthName(currentMonth);
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Mendapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;
    // Tentukan apakah layar kecil
    final bool isSmallScreen = screenSize.width < 380;

    if (_isLoading && _cachedData == null) {
      return Container(
          color: Colors.white,
          child: Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(31, 80, 154, 1))));
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
        children: [
          // Konten halaman yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan nama dan kelas
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSmallScreen ? 20.0 : 30.0,
                      top: isSmallScreen ? 40.0 : 70.0,
                      right: isSmallScreen ? 20.0 : 30.0,
                      bottom: isSmallScreen ? 25.0 : 35.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['student']?.name ?? 'Loading...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4.0 : 6.0),
                        Text(
                          data['student']?.classInfo.name ?? 'Loading...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Konten utama (card putih)
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          120,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isSmallScreen ? 30 : 40),
                        topRight: Radius.circular(isSmallScreen ? 30 : 40),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rekap Kehadiran Anda
                          Text(
                            'Rekap Kehadiran Anda',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(44, 44, 44, 1),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 5),

                          // Filter Bulan
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter Bulan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showMonthSelectionDialog(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 10 : 12,
                                    vertical: isSmallScreen ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedMonth,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: isSmallScreen ? 16 : 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 40 : 50),

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
                              height: isSmallScreen ? 220 : 240,
                              width: isSmallScreen ? 220 : 240,
                              child: _buildRoundedPieChart(
                                  statistics, isSmallScreen),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 45 : 55),

                          // 4 Card Statistik
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 2.0 : 4.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildAbsenceCard(
                                        context: context,
                                        title: 'Hadir',
                                        value: (statistics['present'] ?? 0) +
                                            (statistics['late'] ?? 0),
                                        color: Color.fromRGBO(31, 80, 154, 1),
                                        icon: Icons.check_circle_outline,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 10 : 16),
                                    Expanded(
                                      child: _buildAbsenceCard(
                                        context: context,
                                        title: 'Izin',
                                        value: statistics['permission'] ?? 0,
                                        color: Color.fromRGBO(229, 127, 5, 1),
                                        icon: Icons.event_note,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 10 : 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildAbsenceCard(
                                        context: context,
                                        title: 'Sakit',
                                        value: statistics['sick'] ?? 0,
                                        color: Color.fromRGBO(10, 151, 176, 1),
                                        icon: Icons.healing,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 10 : 16),
                                    Expanded(
                                      child: _buildAbsenceCard(
                                        context: context,
                                        title: 'Alpha',
                                        value: statistics['alpha'] ?? 0,
                                        color: Color.fromRGBO(223, 5, 5, 1),
                                        icon: Icons.warning_amber_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

          // Bottom Navigation Bar
          Container(
            color: Colors.white,
            child: CustomNavigationBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  void _showMonthSelectionDialog(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Pilih Bulan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: monthNumbers.length,
              itemBuilder: (context, index) {
                final month = monthNumbers.keys.elementAt(index);
                return ListTile(
                  title: Text(
                    month,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
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
    // Total semua jenis kehadiran
    final total = (statistics['present'] ?? 0) +
        (statistics['late'] ?? 0) +
        (statistics['permission'] ?? 0) +
        (statistics['sick'] ?? 0) +
        (statistics['alpha'] ?? 0);

    // Jika total 0, return 0 untuk menghindari pembagian dengan 0
    if (total == 0) return 0;

    // Hitung persentase langsung berdasarkan total
    return ((value / total) * 100).round();
  }

  // Card absensi dengan design baru
  Widget _buildAbsenceCard({
    required BuildContext context,
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris pertama: Icon dan Status sejajar horizontal
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),

          // Meningkatkan jarak vertikal
          SizedBox(height: isSmallScreen ? 10 : 12),

          // Baris kedua: Jumlah Hari dan text "Hari" sejajar horizontal
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 26 : 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Hari',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedPieChart(
      Map<String, int> statistics, bool isSmallScreen) {
    final List<PieChartSectionData> sections = [];

    // Nilai Hadir (present + late)
    final presentValue =
        (statistics['present'] ?? 0) + (statistics['late'] ?? 0);
    if (presentValue > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color.fromRGBO(31, 80, 154, 1),
          value: presentValue.toDouble(),
          title: '${_calculatePercentage(presentValue, statistics)}%',
          radius: isSmallScreen ? 80 : 95,
          titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          borderSide: BorderSide.none,
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
    }

    // Nilai Izin (permission)
    final permissionValue = statistics['permission'] ?? 0;
    if (permissionValue > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color.fromRGBO(229, 127, 5, 1),
          value: permissionValue.toDouble(),
          title: '${_calculatePercentage(permissionValue, statistics)}%',
          radius: isSmallScreen ? 80 : 95,
          titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          borderSide: BorderSide.none,
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
    }

    // Nilai Sakit (sick)
    final sickValue = statistics['sick'] ?? 0;
    if (sickValue > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color.fromRGBO(10, 151, 176, 1),
          value: sickValue.toDouble(),
          title: '${_calculatePercentage(sickValue, statistics)}%',
          radius: isSmallScreen ? 80 : 95,
          titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          borderSide: BorderSide.none,
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
    }

    // Nilai Alpha (alpha)
    final alphaValue = statistics['alpha'] ?? 0;
    if (alphaValue > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color.fromRGBO(223, 5, 5, 1),
          value: alphaValue.toDouble(),
          title: '${_calculatePercentage(alphaValue, statistics)}%',
          radius: isSmallScreen ? 80 : 95,
          titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          borderSide: BorderSide.none,
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 10,
            centerSpaceRadius: isSmallScreen ? 50 : 60,
            pieTouchData: PieTouchData(enabled: true),
            borderData: FlBorderData(show: false),
            startDegreeOffset: 180,
          ),
        ),
        // Menampilkan persentase data terbanyak di tengah chart
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_getLargestPercentage(statistics)}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(31, 80, 154, 1),
              ),
            ),
            Text(
              _getLargestCategoryName(statistics),
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Fungsi untuk mendapatkan persentase terbesar
  String _getLargestPercentage(Map<String, int> statistics) {
    final Map<String, int> values = {
      'present': (statistics['present'] ?? 0) + (statistics['late'] ?? 0),
      'permission': statistics['permission'] ?? 0,
      'sick': statistics['sick'] ?? 0,
      'alpha': statistics['alpha'] ?? 0,
    };

    final total = values.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return '0';

    String largestCategory = 'present';
    values.forEach((category, value) {
      if (value > (values[largestCategory] ?? 0)) {
        largestCategory = category;
      }
    });

    return _calculatePercentage(values[largestCategory] ?? 0, statistics)
        .toString();
  }

  // Fungsi untuk mendapatkan nama kategori dengan persentase terbesar
  String _getLargestCategoryName(Map<String, int> statistics) {
    final Map<String, int> values = {
      'present': (statistics['present'] ?? 0) + (statistics['late'] ?? 0),
      'permission': statistics['permission'] ?? 0,
      'sick': statistics['sick'] ?? 0,
      'alpha': statistics['alpha'] ?? 0,
    };

    final Map<String, String> categoryNames = {
      'present': 'Hadir',
      'permission': 'Izin',
      'sick': 'Sakit',
      'alpha': 'Alpha',
    };

    String largestCategory = 'present';
    values.forEach((category, value) {
      if (value > (values[largestCategory] ?? 0)) {
        largestCategory = category;
      }
    });

    return categoryNames[largestCategory] ?? '';
  }
}
