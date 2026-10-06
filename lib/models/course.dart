class Course {
  final int? id;
  final String courseCode;
  final String courseName;

  Course({
    this.id,
    required this.courseCode,
    required this.courseName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_code': courseCode,
      'course_name': courseName,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      courseCode: map['course_code'],
      courseName: map['course_name'],
    );
  }
}