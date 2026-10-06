import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class StudentForm extends StatefulWidget {
  final Student? student;
  final List<Course> courses;
  final List<Section> sections;
  final Future<void> Function(Student student) onSave;

  const StudentForm({
    super.key,
    this.student,
    required this.courses,
    required this.sections,
    required this.onSave,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController studentIdController;
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController birthDateController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dateEnrolledController;

  String gender = 'Male';
  String status = 'Active';
  int yearLevel = 1;

  int? selectedCourseId;
  int? selectedSectionId;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final student = widget.student;

    studentIdController = TextEditingController(text: student?.studentId ?? '');

    firstNameController = TextEditingController(text: student?.firstName ?? '');

    middleNameController = TextEditingController(
      text: student?.middleName ?? '',
    );

    lastNameController = TextEditingController(text: student?.lastName ?? '');

    birthDateController = TextEditingController(text: student?.birthDate ?? '');

    emailController = TextEditingController(text: student?.email ?? '');

    phoneController = TextEditingController(text: student?.phone ?? '');

    addressController = TextEditingController(text: student?.address ?? '');

    dateEnrolledController = TextEditingController(
      text:
          student?.dateEnrolled ??
          DateTime.now().toIso8601String().split('T').first,
    );

    gender = student?.gender ?? 'Male';
    status = student?.status ?? 'Active';
    yearLevel = student?.yearLevel ?? 1;

    selectedCourseId = student?.courseId;

    selectedSectionId = student?.sectionId;
  }

  Future<void> selectBirthDate() async {
    DateTime initialDate = DateTime.now();

    if (birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(birthDateController.text);
      } catch (_) {}
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      birthDateController.text = selected.toIso8601String().split('T').first;
    }
  }

  Future<void> selectEnrollmentDate() async {
    DateTime initialDate = DateTime.now();

    if (dateEnrolledController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(dateEnrolledController.text);
      } catch (_) {}
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      dateEnrolledController.text = selected.toIso8601String().split('T').first;
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course.')));
      return;
    }

    if (selectedSectionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a section.')));
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      final now = DateTime.now().toIso8601String();

      final student = Student(
        id: widget.student?.id,
        studentId: studentIdController.text.trim(),
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: gender,
        birthDate: birthDateController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        courseId: selectedCourseId!,
        yearLevel: yearLevel,
        sectionId: selectedSectionId!,
        status: status,
        dateEnrolled: dateEnrolledController.text.trim(),
        createdAt: widget.student?.createdAt ?? now,
        updatedAt: now,
      );

      await widget.onSave(student);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save student: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    studentIdController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dateEnrolledController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: studentIdController,
            decoration: const InputDecoration(labelText: 'Student ID'),
            validator: (value) => Validators.required(value, 'Student ID'),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (value) => Validators.required(value, 'First Name'),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: middleNameController,
            decoration: const InputDecoration(labelText: 'Middle Name'),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) => Validators.required(value, 'Last Name'),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: AppConstants.genders
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  gender = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: birthDateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Birth Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: selectBirthDate,
            validator: (value) => Validators.required(value, 'Birth Date'),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: Validators.email,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: Validators.phone,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: addressController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) => Validators.required(value, 'Address'),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: selectedCourseId,
            decoration: const InputDecoration(labelText: 'Course'),
            items: widget.courses
                .map(
                  (course) => DropdownMenuItem<int>(
                    value: course.id,
                    child: Text('${course.courseCode} - ${course.courseName}'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCourseId = value;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: selectedSectionId,
            decoration: const InputDecoration(labelText: 'Section'),
            items: widget.sections
                .map(
                  (section) => DropdownMenuItem<int>(
                    value: section.id,
                    child: Text(
                      '${section.sectionName} - Year ${section.yearLevel}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedSectionId = value;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: yearLevel,
            decoration: const InputDecoration(labelText: 'Year Level'),
            items: [1, 2, 3, 4]
                .map(
                  (value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('Year $value'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  yearLevel = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value < 1 || value > 4) {
                return 'Year level must be 1 to 4.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: AppConstants.statuses
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  status = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: dateEnrolledController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date Enrolled',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: selectEnrollmentDate,
            validator: (value) => Validators.required(value, 'Date Enrolled'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : submit,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.student == null ? 'Add Student' : 'Update Student',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
