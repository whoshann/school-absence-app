import 'package:flutter/material.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_absence/services/absence_service.dart';
import 'package:student_absence/services/student_service.dart';
import 'package:student_absence/models/student.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AbsenceService _absenceService = AbsenceService();
  final StudentService _studentService = StudentService();
  final logger = Logger();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Map<String, dynamic>> _presenceData = {};
  Student? student;
  bool isLoading = true;
  bool _isCalendarLoading = false;

  // Warna untuk setiap status
  final Map<String, Color> _statusColors = {
    'hadir': Color.fromRGBO(31, 80, 154, 1),
    'izin': Color.fromRGBO(229, 127, 5, 1),
    'sakit': Color.fromRGBO(10, 151, 176, 1),
    'alpha': Color.fromRGBO(223, 5, 5, 1),
    'terlambat': Color.fromRGBO(102, 102, 102, 1)
  };

  // Ikon untuk setiap status
  final Map<String, IconData> _statusIcons = {
    'hadir': Icons.check_circle_outline,
    'sakit': Icons.healing,
    'izin': Icons.event_note,
    'alpha': Icons.warning_amber_outlined,
    'terlambat': Icons.watch_later_outlined
  };

  // Teks untuk status
  final Map<String, String> _statusText = {
    'hadir': 'Hadir',
    'sakit': 'Sakit',
    'izin': 'Izin',
    'alpha': 'Alpha',
    'terlambat': 'Terlambat'
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedDay = _focusedDay;
    // Inisialisasi data locale untuk Bahasa Indonesia
    initializeDateFormatting('id_ID', null);
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final student = await _studentService.getCurrentStudent();
      final absences = await _absenceService.getMonthlyAbsences(
        student.id,
        _focusedDay,
      );

      setState(() {
        this.student = student;
        _presenceData = absences;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _onPageChanged(DateTime focusedDay) async {
    // Tidak perlu loading state untuk seluruh halaman, kita hanya akan mengganti data
    setState(() {
      _focusedDay = focusedDay;
      _isCalendarLoading = true;
    });

    try {
      // Reload absences when month changes
      final absences = await _absenceService.getMonthlyAbsences(
        student!.id,
        focusedDay,
      );

      if (mounted) {
        setState(() {
          _presenceData = absences;
          _isCalendarLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading absences: $e');
      if (mounted) {
        setState(() {
          _isCalendarLoading = false;
        });
      }
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
            child: isLoading && _presenceData.isEmpty
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(31, 80, 154, 1),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header dengan text "Riwayat Absensi" di tengah
                          Padding(
                            padding: EdgeInsets.only(
                              top: isSmallScreen ? 50.0 : 60.0,
                              bottom: isSmallScreen ? 25.0 : 35.0,
                            ),
                            child: Center(
                              child: Text(
                                'Riwayat Absensi',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Calendar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TableCalendar(
                                          firstDay: DateTime.now()
                                              .subtract(Duration(days: 365)),
                                          lastDay: DateTime.now()
                                              .add(Duration(days: 365)),
                                          focusedDay: _focusedDay,
                                          calendarFormat: _calendarFormat,
                                          selectedDayPredicate: (day) {
                                            return isSameDay(_selectedDay, day);
                                          },
                                          onDaySelected:
                                              (selectedDay, focusedDay) {
                                            setState(() {
                                              _selectedDay = selectedDay;
                                              _focusedDay = focusedDay;
                                            });
                                          },
                                          onFormatChanged: (format) {
                                            setState(() {
                                              _calendarFormat = format;
                                            });
                                          },
                                          onPageChanged: _onPageChanged,
                                          rowHeight: 60,
                                          availableGestures:
                                              AvailableGestures.horizontalSwipe,
                                          pageJumpingEnabled: false,
                                          calendarStyle: CalendarStyle(
                                            markersMaxCount: 1,
                                            defaultTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.black,
                                            ),
                                            weekendTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.red,
                                            ),
                                            selectedTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                            ),
                                            todayTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                            ),
                                            outsideTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.grey,
                                            ),
                                            todayDecoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                            ),
                                            selectedDecoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          calendarBuilders: CalendarBuilders(
                                            defaultBuilder:
                                                (context, day, focusedDay) {
                                              String dateKey =
                                                  '${day.year}-${day.month}-${day.day}';
                                              final presenceInfo =
                                                  _presenceData[dateKey];
                                              final status =
                                                  presenceInfo != null
                                                      ? presenceInfo['status']
                                                      : null;

                                              return Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: status != null
                                                      ? _statusColors[status]
                                                      : Colors.transparent,
                                                ),
                                                child: Text(
                                                  '${day.day}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    color: status != null
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                            todayBuilder:
                                                (context, day, focusedDay) {
                                              String dateKey =
                                                  '${day.year}-${day.month}-${day.day}';
                                              final presenceInfo =
                                                  _presenceData[dateKey];
                                              final status =
                                                  presenceInfo != null
                                                      ? presenceInfo['status']
                                                      : null;

                                              return Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: status != null
                                                      ? _statusColors[status]
                                                      : Colors.blue
                                                          .withOpacity(0.3),
                                                ),
                                                child: Text(
                                                  '${day.day}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                            outsideBuilder:
                                                (context, day, focusedDay) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${day.day}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                            selectedBuilder:
                                                (context, day, focusedDay) {
                                              String dateKey =
                                                  '${day.year}-${day.month}-${day.day}';
                                              final presenceInfo =
                                                  _presenceData[dateKey];
                                              final status =
                                                  presenceInfo != null
                                                      ? presenceInfo['status']
                                                      : null;

                                              return Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: status != null
                                                      ? _statusColors[status]
                                                      : Colors.blue
                                                          .withOpacity(0.3),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${day.day}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          headerStyle: HeaderStyle(
                                            formatButtonVisible: false,
                                            titleCentered: true,
                                            titleTextStyle:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromRGBO(70, 66, 85, 1),
                                            ),
                                            leftChevronIcon: Icon(
                                              Icons.chevron_left,
                                              color:
                                                  Color.fromRGBO(70, 66, 85, 1),
                                            ),
                                            rightChevronIcon: Icon(
                                              Icons.chevron_right,
                                              color:
                                                  Color.fromRGBO(70, 66, 85, 1),
                                            ),
                                          ),
                                          daysOfWeekStyle: DaysOfWeekStyle(
                                            weekdayStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color:
                                                  Color.fromRGBO(70, 66, 85, 1),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            weekendStyle:
                                                GoogleFonts.plusJakartaSans(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        // Tampilkan indikator loading di bawah kalender dengan SizedBox yang lebih rapi
                                        _isCalendarLoading
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Color.fromRGBO(
                                                        31, 80, 154, 1),
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Judul Keterangan
                                  Text(
                                    'Keterangan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(44, 44, 44, 1),
                                    ),
                                  ),
                                  SizedBox(height: 15),

                                  // Detail absensi siswa (untuk tanggal yang dipilih)
                                  if (_selectedDay != null)
                                    _buildAbsenceDetailCard(isSmallScreen),

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
            child: CustomNavigationBar(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan detail absensi pada tanggal yang dipilih
  Widget _buildAbsenceDetailCard(bool isSmallScreen) {
    // Format tanggal yang dipilih
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay!);

    // Mendapatkan status absensi untuk tanggal yang dipilih
    String dateKey =
        '${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}';
    final presenceInfo = _presenceData[dateKey];

    // Jika tidak ada data absensi untuk tanggal ini
    if (presenceInfo == null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'Tidak ada data absensi untuk tanggal ini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    final status = presenceInfo['status'];
    final time = presenceInfo['time'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tampilan detail absensi dalam format list
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal dengan ikon kalender
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color.fromRGBO(44, 44, 44, 1),
                      size: isSmallScreen ? 28 : 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      formattedDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(44, 44, 44, 1),
                      ),
                    ),
                  ],
                ),

                // Garis pembatas
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                ),

                // Status dengan ikon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _statusIcons[status]!,
                      color: _statusColors[status]!,
                      size: isSmallScreen ? 28 : 30,
                    ),
                    SizedBox(width: 10),
                    // Memisahkan label "Status:" dan nilai statusnya
                    Text(
                      'Status: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(44, 44, 44, 1),
                      ),
                    ),
                    Text(
                      _statusText[status] ?? status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: _statusColors[status]!,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Waktu absen (jika ada dan bukan alpha)
                if (time != null && time != '-' && status != 'alpha')
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Color.fromRGBO(44, 44, 44, 1),
                        size: isSmallScreen ? 28 : 30,
                      ),
                      SizedBox(width: 10),
                      // Memisahkan label "Waktu Absen:" dan nilai waktunyartt
                      Text(
                        'Waktu Absen: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
