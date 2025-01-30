import 'package:dio/dio.dart';
import '../models/login_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.get('API_URL');

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    }
  }
}
