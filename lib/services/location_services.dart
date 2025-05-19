import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final logger = Logger();

  static Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Coba dapatkan lokasi beberapa kali untuk hasil yang lebih stabil
      Position? bestPosition;
      double bestAccuracy = double.infinity;

      for (int i = 0; i < 3; i++) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          );

          // Jika akurasi lebih baik, gunakan posisi ini
          if (position.accuracy < bestAccuracy) {
            bestPosition = position;
            bestAccuracy = position.accuracy;
          }

          // Jika akurasi sudah cukup baik, langsung gunakan
          if (position.accuracy <= 10) {
            return position;
          }

          // Tunggu sebentar sebelum mencoba lagi
          await Future.delayed(Duration(seconds: 1));
        } catch (e) {
          logger.e('Error in attempt ${i + 1}: $e');
        }
      }

      return bestPosition;
    } catch (e) {
      logger.e('Error getting location: $e');
      return null;
    }
  }

  static bool isWithinSchoolArea(
      Position position, LatLng schoolLocation, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      schoolLocation.latitude,
      schoolLocation.longitude,
    );

    // Tambahkan toleransi untuk akurasi GPS
    final effectiveRadius = radiusInMeters + position.accuracy;
    return distanceInMeters <= effectiveRadius;
  }
}
