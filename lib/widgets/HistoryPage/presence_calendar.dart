// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../controllers/history_controller.dart';

// class AttendanceCalendar extends GetView<HistoryController> {
//   final DateTime _focusedDay = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: Obx(() => TableCalendar(
//           firstDay: DateTime.utc(2024, 1, 1),
//           lastDay: DateTime.utc(2024, 12, 31),
//           focusedDay: _focusedDay,
//           calendarFormat: CalendarFormat.month,
//           startingDayOfWeek: StartingDayOfWeek.monday,
//           headerStyle: HeaderStyle(
//             titleCentered: true,
//             formatButtonVisible: false,
//             titleTextStyle: GoogleFonts.plusJakartaSans(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           calendarStyle: CalendarStyle(
//             outsideDaysVisible: false,
//             weekendTextStyle: GoogleFonts.plusJakartaSans(),
//             holidayTextStyle: GoogleFonts.plusJakartaSans(),
//             todayDecoration: BoxDecoration(
//               color: Colors.transparent,
//               shape: BoxShape.circle,
//             ),
//           ),
//           calendarBuilders: CalendarBuilders(
//             defaultBuilder: (context, date, events) {
//               return _buildCalendarDay(date);
//             },
//           ),
//         )),
//       ),
//     );
//   }

//   Widget _buildCalendarDay(DateTime date) {
//     final status = controller.getStatus(date);
    
//     if (status == null) {
//       return Container(
//         margin: EdgeInsets.all(4),
//         child: Center(
//           child: Text(
//             '${date.day}',
//             style: GoogleFonts.plusJakartaSans(),
//           ),
//         ),
//       );
//     }

//     return Container(
//       margin: EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: controller.getStatusColor(status),
//       ),
//       child: Center(
//         child: Text(
//           '${date.day}',
//           style: GoogleFonts.plusJakartaSans(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }