import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/section.dart';
import '../../models/student.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/section_repository.dart';
import '../../repositories/student_repository.dart';
import '../../services/student_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/student_form.dart';

class AddStudentPage extends StatefulWidget {
  final AppUser user;

  const AddStudentPage({super.key, required this.user});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  late final StudentService studentService;

  List<Course> courses = [];
  List<Section> sections = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final db = DatabaseHelper.instance;

    studentService = StudentService(StudentRepository(db), db);

    loadData();
  }

  Future<void> loadData() async {
    final db = DatabaseHelper.instance;

    courses = await CourseRepository(db).getAll();

    sections = await SectionRepository(db).getAll();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveStudent(Student student) async {
    await studentService.createStudent(
      student,
      currentUserId: widget.user.id,
      currentUserRole: widget.user.role,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student added successfully.')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: isLoading
          ? const LoadingWidget()
          : StudentForm(
              courses: courses,
              sections: sections,
              onSave: saveStudent,
            ),
    );
  }
}
