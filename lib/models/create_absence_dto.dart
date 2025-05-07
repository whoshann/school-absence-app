class CreateAbsenceDto {
  final int studentId;
  final DateTime date;
  final String status;
  final String? note;
  final double? latitude;
  final double? longitude;

  CreateAbsenceDto({
    required this.studentId,
    required this.date,
    required this.status,
    this.note,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'date': date.toIso8601String(),
      'status': status,
      if (note != null) 'note': note,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
