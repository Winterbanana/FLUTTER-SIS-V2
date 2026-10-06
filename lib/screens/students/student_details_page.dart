import 'package:flutter/material.dart';

import '../../models/student.dart';

class StudentDetailsPage
    extends StatelessWidget {
  final Student student;

  const StudentDetailsPage({
    super.key,
    required this.student,
  });

  Widget detail(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Details',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            student.fullName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          detail(
            'Student ID',
            student.studentId,
          ),

          detail(
            'First Name',
            student.firstName,
          ),

          detail(
            'Middle Name',
            student.middleName,
          ),

          detail(
            'Last Name',
            student.lastName,
          ),

          detail(
            'Gender',
            student.gender,
          ),

          detail(
            'Birth Date',
            student.birthDate,
          ),

          detail(
            'Email',
            student.email,
          ),

          detail(
            'Phone',
            student.phone,
          ),

          detail(
            'Address',
            student.address,
          ),

          detail(
            'Year Level',
            student.yearLevel.toString(),
          ),

          detail(
            'Status',
            student.status,
          ),

          detail(
            'Date Enrolled',
            student.dateEnrolled,
          ),
        ],
      ),
    );
  }
}