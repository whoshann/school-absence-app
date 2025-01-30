class Student {
  final int id;
  final String name;
  final String nis;
  final String nisn;
  final ClassInfo classInfo;
  final MajorInfo majorInfo;
  // tambahkan field lain sesuai kebutuhan

  Student({
    required this.id,
    required this.name,
    required this.nis,
    required this.nisn,
    required this.classInfo,
    required this.majorInfo,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      nis: json['nis'],
      nisn: json['nisn'],
      classInfo: ClassInfo.fromJson(json['class']),
      majorInfo: MajorInfo.fromJson(json['major']),
    );
  }
}

class ClassInfo {
  final String name;
  final String grade;

  ClassInfo({required this.name, required this.grade});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      name: json['name'],
      grade: json['grade'],
    );
  }
}

class MajorInfo {
  final String name;

  MajorInfo({required this.name});

  factory MajorInfo.fromJson(Map<String, dynamic> json) {
    return MajorInfo(
      name: json['name'],
    );
  }
}
