import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final logger = Logger();

  static Future<Position?> getCurrentLocation() async {
    try {
      logger.d(
          '=================== GETTING CURRENT LOCATION ===================');
      LocationPermission permission = await Geolocator.checkPermission();
      logger.d('Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        logger.d('Permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        logger.d('New permission status: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        logger.d('Location permission denied permanently');
        return null;
      }

      // Coba dapatkan lokasi beberapa kali untuk hasil yang lebih stabil
      Position? bestPosition;
      double bestAccuracy = double.infinity;

      for (int i = 0; i < 3; i++) {
        try {
          logger.d('Attempt ${i + 1} to get location...');
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          );

          logger.d(
              'Position obtained: [${position.latitude}, ${position.longitude}]');
          logger.d('Accuracy: ${position.accuracy} meters');

          // Jika akurasi lebih baik, gunakan posisi ini
          if (position.accuracy < bestAccuracy) {
            bestPosition = position;
            bestAccuracy = position.accuracy;
          }

          // Jika akurasi sudah cukup baik, langsung gunakan
          if (position.accuracy <= 10) {
            logger.d('Good accuracy achieved, using this position');
            return position;
          }

          // Tunggu sebentar sebelum mencoba lagi
          await Future.delayed(Duration(seconds: 1));
        } catch (e) {
          logger.e('Error in attempt ${i + 1}: $e');
        }
      }

      logger.d(
          'Using best position found with accuracy: ${bestPosition?.accuracy} meters');
      logger.d('=============================================================');

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

    // Logging detail untuk debugging
    logger.d(
        '=================== LOCATION CALCULATION DETAILS ===================');
    logger.d('Current Position: [${position.latitude}, ${position.longitude}]');
    logger.d(
        'School Location: [${schoolLocation.latitude}, ${schoolLocation.longitude}]');
    logger.d('Distance: $distanceInMeters meters');
    logger.d('Allowed Radius: $radiusInMeters meters');
    logger.d('Is Within Area: ${distanceInMeters <= radiusInMeters}');
    logger.d('Position Accuracy: ${position.accuracy} meters');
    logger.d('=============================================================');

    // Tambahkan toleransi untuk akurasi GPS
    final effectiveRadius = radiusInMeters + position.accuracy;
    return distanceInMeters <= effectiveRadius;
  }
}
