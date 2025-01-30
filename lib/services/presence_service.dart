import '../models/presence_record.dart';
import 'package:dio/dio.dart';
import '../models/create_absence_dto.dart';
import '../utils/token_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class AttendanceService {
  // Simulasi API call
  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    // Nanti bisa diganti dengan actual API call
    await Future.delayed(Duration(seconds: 1)); // Simulasi network delay

    return [
      AttendanceRecord(
        date: DateTime.now(),
        status: 'Hadir',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 1)),
        status: 'Sakit',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 2)),
        status: 'Izin',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 3)),
        status: 'Alpha',
      ),
    ];
  }
}

class PresenceService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.get('API_URL');
  final logger = Logger();

  Future<void> submitPresence({
    required int studentId,
    required String status,
    required DateTime date,
    Position? position,
    String? note,
    XFile? photo,
  }) async {
    try {
      final token = await TokenHelper.getToken();

      // Prepare form data
      final Map<String, dynamic> formMap = {
        'studentId': studentId,
        'status': status,
        'date': date.toIso8601String(),
      };

      // Add location data if status is Present
      if (status == 'Present') {
        if (position == null) {
          throw Exception('Lokasi diperlukan untuk status Hadir');
        }
        formMap['latitude'] = position.latitude.toString(); // Convert to string
        formMap['longitude'] =
            position.longitude.toString(); // Convert to string
      }

      // Add note if present
      if (note != null && note.isNotEmpty) {
        formMap['note'] = note;
      }

      // Log request data untuk debugging
      logger.i('Preparing to send data: $formMap');

      FormData formData = FormData();

      // Add all form fields
      formMap.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add photo if exists and status is not Present
      if (photo != null && status != 'Present') {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.name,
            ),
          ),
        );
      }

      logger.i('Sending request to: $baseUrl/absence');
      logger.i('Form data fields: ${formData.fields}');
      if (formData.files.isNotEmpty) {
        logger.i('Form data files: ${formData.files}');
      }

      final response = await _dio.post(
        '$baseUrl/absence',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      logger.i('Response status: ${response.statusCode}');
      logger.i('Response data: ${response.data}');

      if (response.statusCode == 403) {
        final errorMessage = response.data['error_message'] ??
            'Anda sudah melakukan absensi hari ini';
        throw Exception(errorMessage);
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Gagal mengirim absensi');
      }
    } catch (e) {
      logger.e('Error submitting presence: $e');
      if (e is DioException) {
        if (e.response != null) {
          logger.e('Server response: ${e.response?.data}');
          final message = e.response?.data['error_message'] ??
              e.response?.data['message'] ??
              'Gagal mengirim absensi';
          throw Exception(message);
        }
        throw Exception('Gagal terhubung ke server');
      }
      rethrow;
    }
  }
}
