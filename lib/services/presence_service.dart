import '../models/presence_record.dart';

class AttendanceService {
  // Simulasi API call
  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    // Nanti bisa diganti dengan actual API call
    await Future.delayed(Duration(seconds: 1)); // Simulasi network delay
    
    return [
      AttendanceRecord(
        date: DateTime.now(),
        status: 'Hadir',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 1)),
        status: 'Sakit',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 2)),
        status: 'Izin',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(Duration(days: 3)),
        status: 'Alpha',
      ),
    ];
  }
}