import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/token_helper.dart';
import 'package:logger/logger.dart';

class AbsenceService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.get('API_URL');
  final logger = Logger();

  // Fungsi untuk statistik (bisa digunakan untuk keseluruhan atau per bulan)
  Future<Map<String, int>> getStatistics(
    int studentId, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await TokenHelper.getToken();

      // Buat query parameters jika ada year dan month
      final queryParams = <String, dynamic>{};
      if (year != null && month != null) {
        queryParams['year'] = year;
        queryParams['month'] = month;
      }

      final response = await _dio.get(
        '$baseUrl/absence/statistics/$studentId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        logger.d('Response data: $data');

        return {
          'present': data['present'] ?? 0,
          'permission': data['permission'] ?? 0,
          'sick': data['sick'] ?? 0,
          'alpha': data['alpha'] ?? 0,
          'late': data['late'] ?? 0,
        };
      }

      throw Exception('Gagal mengambil statistik absensi');
    } catch (e) {
      logger.e('Error getting statistics: $e');
      throw Exception('Gagal mengambil statistik absensi: ${e.toString()}');
    }
  }

  // Fungsi untuk mendapatkan detail absensi per bulan (untuk calendar)
  Future<Map<String, Map<String, dynamic>>> getMonthlyAbsences(
    int studentId,
    DateTime month,
  ) async {
    try {
      final token = await TokenHelper.getToken();

      final response = await _dio.get(
        '$baseUrl/absence/monthly/$studentId',
        queryParameters: {
          'year': month.year,
          'month': month.month,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        Map<String, Map<String, dynamic>> absences = {};

        for (var item in data) {
          final date = DateTime.parse(item['date']);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          String status;
          switch (item['status']) {
            case 'Present':
              status = 'hadir';
              break;
            case 'Permission':
              status = 'izin';
              break;
            case 'Sick':
              status = 'sakit';
              break;
            case 'Alpha':
              status = 'alpha';
              break;
            case 'Late':
              status = 'terlambat';
              break;
            default:
              status = 'hadir';
          }

          // Ambil waktu dari field date dan konversi ke GMT+7 (WIB)
          final dateInWIB = date.add(Duration(hours: 7));

          // Jika waktu adalah 00:00, gunakan waktu default berdasarkan status
          String timeString;
          if (dateInWIB.hour == 0 && dateInWIB.minute == 0) {
            switch (status) {
              case 'hadir':
                timeString = '07:15'; // Waktu hadir standar
                break;
              case 'terlambat':
                timeString = '08:30'; // Waktu terlambat
                break;
              case 'sakit':
              case 'izin':
                timeString = '06:45'; // Waktu izin/sakit (biasanya pagi)
                break;
              case 'alpha':
                timeString = '-'; // Tidak ada waktu untuk alpha
                break;
              default:
                timeString = '07:00';
            }
          } else {
            timeString =
                '${dateInWIB.hour.toString().padLeft(2, '0')}:${dateInWIB.minute.toString().padLeft(2, '0')}';
          }

          absences[dateKey] = {
            'status': status,
            'time': timeString,
          };
        }

        return absences;
      }

      throw Exception('Gagal mengambil data absensi');
    } catch (e) {
      logger.e('Error getting monthly absences: $e');
      throw Exception('Gagal mengambil data absensi');
    }
  }
}
