// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:table_calendar/table_calendar.dart';

// class HistoryController extends GetxController {
//   final Rx<Map<DateTime, String>> attendanceStatus = Rx<Map<DateTime, String>>({});

//   @override
//   void onInit() {
//     super.onInit();
//     // Inisialisasi data contoh
//     final Map<DateTime, String> initialData = {
//       DateTime.utc(2024, 3, 1): 'hadir',
//       DateTime.utc(2024, 3, 5): 'sakit',
//       DateTime.utc(2024, 3, 10): 'alpha',
//       DateTime.utc(2024, 3, 15): 'izin',
//     };
//     attendanceStatus.value = initialData;
//   }

//   String? getStatus(DateTime date) {
//     final compareDate = DateTime.utc(date.year, date.month, date.day);
    
//     // Mencari status untuk tanggal yang sesuai
//     for (var entry in attendanceStatus.value.entries) {
//       if (isSameDay(entry.key, compareDate)) {
//         return entry.value;
//       }
//     }
//     return null;
//   }

//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'hadir':
//         return Colors.green;
//       case 'sakit':
//         return Colors.blue;
//       case 'alpha':
//         return Colors.red;
//       case 'izin':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   bool hasStatus(DateTime date) {
//     final compareDate = DateTime.utc(date.year, date.month, date.day);
//     return attendanceStatus.value.keys.any((key) => isSameDay(key, compareDate));
//   }
// }