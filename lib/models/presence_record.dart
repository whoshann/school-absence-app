class AttendanceRecord {
  final DateTime date;
  final String status;
  final double? latitude;
  final double? longitude;

  AttendanceRecord({
    required this.date,
    required this.status,
    this.latitude,
    this.longitude,
  });

  // Untuk konversi dari JSON
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
