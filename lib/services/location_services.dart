import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  static bool isWithinSchoolArea(Position position, LatLng schoolLocation, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      schoolLocation.latitude,
      schoolLocation.longitude,
    );
    return distanceInMeters <= radiusInMeters;
  }
}