class Student {
  final int? id;
  final String studentId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String birthDate;
  final String email;
  final String phone;
  final String address;
  final int courseId;
  final int yearLevel;
  final int sectionId;
  final String status;
  final String dateEnrolled;
  final String createdAt;
  final String updatedAt;

  Student({
    this.id,
    required this.studentId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.email,
    required this.phone,
    required this.address,
    required this.courseId,
    required this.yearLevel,
    required this.sectionId,
    required this.status,
    required this.dateEnrolled,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName =>
      '$firstName $middleName $lastName'.replaceAll(RegExp(r' +'), ' ');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate,
      'email': email,
      'phone': phone,
      'address': address,
      'course_id': courseId,
      'year_level': yearLevel,
      'section_id': sectionId,
      'status': status,
      'date_enrolled': dateEnrolled,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentId: map['student_id'],
      firstName: map['first_name'],
      middleName: map['middle_name'] ?? '',
      lastName: map['last_name'],
      gender: map['gender'],
      birthDate: map['birth_date'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      courseId: map['course_id'],
      yearLevel: map['year_level'],
      sectionId: map['section_id'],
      status: map['status'],
      dateEnrolled: map['date_enrolled'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}