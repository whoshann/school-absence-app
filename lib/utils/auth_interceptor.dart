import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'token_helper.dart';
import 'package:get/get.dart';
import '../views/login_screen.dart';

class AuthInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Jangan redirect jika sudah di halaman login
      if (!Get.currentRoute.contains('login')) {
        await TokenHelper.removeToken();
        Get.offAll(() => LoginScreen(),
            arguments: 'Sesi Anda telah berakhir. Silakan login kembali.');
      }
    }

    return handler.next(err);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Tambahkan token ke semua requests jika ada
    final token = await TokenHelper.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
