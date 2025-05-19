import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart';
import '../views/login_screen.dart';
import 'package:logger/logger.dart';

class TokenHelper {
  static final Logger logger = Logger();

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Validasi token dan redirect ke login jika tidak valid
  static Future<bool> validateToken() async {
    try {
      logger.d('Validating token...');
      final token = await getToken();

      // Jika token null, redirect ke login
      if (token == null) {
        logger.d('Token is null, redirecting to login');
        await _redirectToLogin(
            'Sesi Anda telah berakhir. Silakan login kembali.');
        return false;
      }

      // Cek apakah token expired
      final isExpired = JwtDecoder.isExpired(token);

      // Jika token expired, redirect ke login
      if (isExpired) {
        logger.d('Token is expired, redirecting to login');
        await _redirectToLogin(
            'Sesi Anda telah berakhir. Silakan login kembali.');
        return false;
      }

      // Cek berapa lama waktu token akan expired
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeToExpiry = expirationDate.difference(now);

      logger.d('Token will expire in ${timeToExpiry.inMinutes} minutes');
      return true;
    } catch (e) {
      logger.e('Error validating token: $e');
      await _redirectToLogin(
          'Terjadi kesalahan pada sesi. Silakan login kembali.');
      return false;
    }
  }

  static Future<void> _redirectToLogin(String message) async {
    await removeToken();
    Get.offAll(() => LoginScreen(), arguments: message);
  }
}
