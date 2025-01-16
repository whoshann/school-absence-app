import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationMapWidget extends StatelessWidget {
  final Position? currentPosition;
  final bool isLoadingLocation;
  final VoidCallback onRetryLocation;
  final String? presensi;
  final bool isWithinSchoolArea;
  final LatLng smkn4Location;
  final double visualRadius;
  final VoidCallback onLocationButtonPressed;

  const LocationMapWidget({
    Key? key,
    required this.currentPosition,
    required this.isLoadingLocation,
    required this.onRetryLocation,
    required this.presensi,
    required this.isWithinSchoolArea,
    required this.smkn4Location,
    required this.visualRadius,
    required this.onLocationButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (presensi == 'Hadir' && !isLoadingLocation && currentPosition != null)
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWithinSchoolArea ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isWithinSchoolArea
                  ? 'Anda berada dalam area sekolah'
                  : 'Anda berada di luar area sekolah',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          'Lokasi Anda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildMapContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    if (isLoadingLocation) {
      return Center(child: CircularProgressIndicator());
    }

    if (currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Tidak dapat mengakses lokasi',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[700],
              ),
            ),
            TextButton(
              onPressed: onRetryLocation,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              currentPosition!.latitude,
              currentPosition!.longitude,
            ),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: smkn4Location,
                  child: presensi == 'Hadir'
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: visualRadius * 2,
                              height: visualRadius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isWithinSchoolArea
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                border: Border.all(
                                  color: isWithinSchoolArea
                                      ? Colors.green
                                      : Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.school,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ],
                        )
                      : Icon(
                          Icons.school,
                          color: Colors.blue,
                          size: 40,
                        ),
                ),
                Marker(
                  point: LatLng(
                    currentPosition!.latitude,
                    currentPosition!.longitude,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: FloatingActionButton.small(
            onPressed: onLocationButtonPressed,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: Color.fromRGBO(31, 80, 154, 1),
            ),
          ),
        ),
      ],
    );
  }
}