import 'package:latlong2/latlong.dart';

class PresenceConstants {
  // Radius dalam meter - jarak maksimum dari titik koordinat untuk dianggap "di dalam area sekolah"
  // Tingkatkan nilai ini jika Anda ingin memperluas area
  static const double RADIUS_IN_METERS =
      25; // Ditingkatkan ke 25 meter untuk memberikan toleransi yang cukup

  // Radius visual untuk tampilan di peta (dalam meter)
  static const double VISUAL_RADIUS = 25.0; // Sesuaikan dengan RADIUS_IN_METERS

  // Koordinat lokasi sekolah
  // Format: LatLng(latitude, longitude)
  static const LatLng SMKN4_LOCATION =
      LatLng(-7.9896111735200845, 112.62731069520423);
}
