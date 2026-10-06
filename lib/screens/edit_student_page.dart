import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';

class EditStudentPage extends StatefulWidget {
  final Student student;

  const EditStudentPage({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController courseController;
  late TextEditingController yearController;
  late TextEditingController emailController;

  final database = DatabaseHelper.instance;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.student.name,
    );

    courseController = TextEditingController(
      text: widget.student.course,
    );

    yearController = TextEditingController(
      text: widget.student.yearLevel.toString(),
    );

    emailController = TextEditingController(
      text: widget.student.email,
    );
  }

  Future<void> saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      final updatedStudent = Student(
        id: widget.student.id,
        name: nameController.text.trim(),
        course: courseController.text.trim(),
        yearLevel: int.parse(yearController.text.trim()),
        email: emailController.text.trim(),
      );

      await database.updateStudent(updatedStudent);

      if (!mounted) return;

      Navigator.pop(context, updatedStudent);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update student: $e'),
        ),
      );
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
    nameController.dispose();
    courseController.dispose();
    yearController.dispose();
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter student name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter student course';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year Level',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final year = int.tryParse(value ?? '');

                  if (year == null) {
                    return 'Enter a valid year level';
                  }

                  if (year < 1 || year > 4) {
                    return 'Year level must be 1-4';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter email';
                  }

                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving ? null : saveStudent,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Update Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}