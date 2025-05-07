import 'package:dio/dio.dart';
import '../models/student.dart';
import '../utils/token_helper.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.get('API_URL');

  static Student? _currentStudent;

  static Student? get currentStudent => _currentStudent;

  Future<Student> getCurrentStudent() async {
    if (_currentStudent != null) return _currentStudent!;

    try {
      final token = await TokenHelper.getToken();
      final decodedToken = JwtDecoder.decode(token!);
      final studentId = decodedToken['sub'];

      final response = await _dio.get(
        '$baseUrl/student/$studentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      _currentStudent = Student.fromJson(response.data['data']);
      return _currentStudent!;
    } catch (e) {
      throw Exception('Gagal mengambil data siswa: $e');
    }
  }
}
