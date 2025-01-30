import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/token_helper.dart';
import 'package:logger/logger.dart';

class AbsenceService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.get('API_URL');
  final logger = Logger();

  Future<Map<String, int>> getAbsenceStatistics(int studentId) async {
    try {
      final token = await TokenHelper.getToken();

      final response = await _dio.get(
        '$baseUrl/absence/statistics/$studentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return {
          'present': data['present'] ?? 0,
          'permission': data['permission'] ?? 0,
          'sick': data['sick'] ?? 0,
          'alpha': data['alpha'] ?? 0,
        };
      }

      throw Exception('Gagal mengambil data statistik absensi');
    } catch (e) {
      logger.e('Error getting absence statistics: $e');
      throw Exception('Gagal mengambil data statistik absensi');
    }
  }

  Future<Map<String, String>> getMonthlyAbsences(
      int studentId, DateTime month) async {
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
        Map<String, String> absences = {};

        for (var item in data) {
          final date = DateTime.parse(item['date']);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          // Konversi status dari backend ke format frontend
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
            default:
              status = 'hadir';
          }

          absences[dateKey] = status;
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
