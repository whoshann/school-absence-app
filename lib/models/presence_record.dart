class AttendanceRecord {
  final DateTime date;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.status,
  });

  // Untuk konversi dari JSON
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }
}