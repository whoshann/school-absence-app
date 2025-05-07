import 'package:flutter/material.dart';
import 'package:student_absence/widgets/BottomNavbar/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_absence/services/absence_service.dart';
import 'package:student_absence/services/student_service.dart';
import 'package:student_absence/models/student.dart';
import 'package:logger/logger.dart';

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
  Map<String, String> _presenceStatus = {};
  Student? student;
  bool isLoading = true;

  // Warna untuk setiap status
  final Map<String, Color> _statusColors = {
    'hadir': Color.fromRGBO(31, 80, 154, 1),
    'sakit': Color.fromRGBO(229, 127, 5, 1),
    'izin': Color.fromRGBO(10, 151, 176, 1),
    'alpha': Color.fromRGBO(223, 5, 5, 1),
    'terlambat': Color.fromRGBO(12, 241, 39, 1)
  };

  @override
  void initState() {
    super.initState();
    _loadData();
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
        _presenceStatus = absences;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _onPageChanged(DateTime focusedDay) async {
    setState(() {
      _focusedDay = focusedDay;
      isLoading = true;
    });

    try {
      // Reload absences when month changes
      final absences = await _absenceService.getMonthlyAbsences(
        student!.id,
        focusedDay,
      );

      setState(() {
        _presenceStatus = absences;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading absences: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23, 40, 16, 8),
                      child: Text(
                        'Absensi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Color.fromRGBO(157, 157, 157, 1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23, 0, 16, 8),
                      child: Text(
                        '${student?.name ?? ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(70, 66, 85, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Calendar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(15),
                      child: TableCalendar(
                        firstDay: DateTime.now().subtract(Duration(days: 365)),
                        lastDay: DateTime.now().add(Duration(days: 365)),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
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
                        calendarStyle: CalendarStyle(
                          markersMaxCount: 1,
                          defaultTextStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.black,
                          ),
                          weekendTextStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.red,
                          ),
                          selectedTextStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                          ),
                          todayTextStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                          ),
                          outsideTextStyle: GoogleFonts.plusJakartaSans(
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
                          defaultBuilder: (context, day, focusedDay) {
                            String dateKey =
                                '${day.year}-${day.month}-${day.day}';
                            String? status = _presenceStatus[dateKey];

                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: status != null
                                    ? _statusColors[status]
                                    : Colors.transparent,
                              ),
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: status != null
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            String dateKey =
                                '${day.year}-${day.month}-${day.day}';
                            String? status = _presenceStatus[dateKey];

                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: status != null
                                    ? _statusColors[status]
                                    : Colors.blue.withOpacity(0.3),
                              ),
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            String dateKey =
                                '${day.year}-${day.month}-${day.day}';
                            String? status = _presenceStatus[dateKey];

                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: status != null
                                    ? _statusColors[status]
                                    : Colors.blue.withOpacity(0.3),
                              ),
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.plusJakartaSans(
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
                          titleTextStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(70, 66, 85, 1),
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Color.fromRGBO(70, 66, 85, 1),
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Color.fromRGBO(70, 66, 85, 1),
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.plusJakartaSans(
                            color: Color.fromRGBO(70, 66, 85, 1),
                            fontWeight: FontWeight.bold,
                          ),
                          weekendStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Status Legend
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keterangan Status',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(70, 66, 85, 1),
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatusLegend(
                                    'Hadir', Color.fromRGBO(31, 80, 154, 1)),
                                _buildStatusLegend(
                                    'Sakit', Color.fromRGBO(229, 127, 5, 1)),
                                _buildStatusLegend(
                                    'Izin', Color.fromRGBO(10, 151, 176, 1)),
                                _buildStatusLegend(
                                    'Alpha', Color.fromRGBO(223, 5, 5, 1)),
                                _buildStatusLegend(
                                    'Terlambat', Color.fromRGBO(102, 102, 102, 1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildStatusLegend(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Color.fromRGBO(70, 66, 85, 1),
          ),
        ),
      ],
    );
  }
}
