import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('API_URL'),
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Tambahkan interceptor untuk handling auth
      _dio!.interceptors.add(AuthInterceptor());
    }

    return _dio!;
  }
}
