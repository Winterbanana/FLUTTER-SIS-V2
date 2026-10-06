import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/section.dart';
import '../../models/student.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/section_repository.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/student_card.dart';
import 'add_student_page.dart';
import 'edit_student_page.dart';
import 'student_details_page.dart';

class StudentListPage extends StatefulWidget {
  final AppUser user;

  const StudentListPage({super.key, required this.user});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final searchController = TextEditingController();

  late final StudentService studentService;
  late final AuthService authService;

  List<Student> students = [];
  List<Course> courses = [];
  List<Section> sections = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedStatus = 'All';
  String selectedSort = 'A-Z';
  int? selectedCourseId;
  int? selectedYearLevel;

  @override
  void initState() {
    super.initState();

    final db = DatabaseHelper.instance;

    studentService = StudentService(StudentRepository(db), db);

    authService = AuthService(
      // The login repository is not needed
      // on this screen.
      // This object is only used for RBAC.
      // A repository instance is still supplied
      // because AuthService requires one.
      __EmptyUserRepository(db),
      db,
    );

    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final studentResult = await studentService.getStudents();

      final courseResult = await CourseRepository(
        DatabaseHelper.instance,
      ).getAll();

      final sectionResult = await SectionRepository(
        DatabaseHelper.instance,
      ).getAll();

      setState(() {
        students = studentResult;
        courses = courseResult;
        sections = sectionResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load students.';
      });
    }
  }

  List<Student> get filteredStudents {
    final query = searchController.text.trim().toLowerCase();

    var result = students.where((student) {
      final name = student.fullName.toLowerCase();

      return student.studentId.toLowerCase().contains(query) ||
          name.contains(query) ||
          student.email.toLowerCase().contains(query);
    }).toList();

    if (selectedStatus != 'All') {
      result = result
          .where((student) => student.status == selectedStatus)
          .toList();
    }

    if (selectedCourseId != null) {
      result = result
          .where((student) => student.courseId == selectedCourseId)
          .toList();
    }

    if (selectedYearLevel != null) {
      result = result
          .where((student) => student.yearLevel == selectedYearLevel)
          .toList();
    }

    if (selectedSort == 'A-Z') {
      result.sort((a, b) => a.lastName.compareTo(b.lastName));
    }

    if (selectedSort == 'Z-A') {
      result.sort((a, b) => b.lastName.compareTo(a.lastName));
    }

    if (selectedSort == 'Newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (selectedSort == 'Oldest') {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return result;
  }

  Future<void> deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete student?'),
          content: Text(
            'Delete ${student.fullName}? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await studentService.deleteStudent(
        student.id!,
        currentUserId: widget.user.id,
        currentUserRole: widget.user.role,
        studentId: student.studentId,
      );

      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.user.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      floatingActionButton: widget.user.role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddStudentPage(user: widget.user),
                  ),
                );

                if (result == true) {
                  await loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: isLoading
          ? const LoadingWidget()
          : errorMessage != null
          ? ErrorState(message: errorMessage!, onRetry: loadData)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search Student',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Text('Inactive'),
                            ),
                            DropdownMenuItem(
                              value: 'Graduated',
                              child: Text('Graduated'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedSort,
                          decoration: const InputDecoration(labelText: 'Sort'),
                          items: const [
                            DropdownMenuItem(
                              value: 'A-Z',
                              child: Text('Name A-Z'),
                            ),
                            DropdownMenuItem(
                              value: 'Z-A',
                              child: Text('Name Z-A'),
                            ),
                            DropdownMenuItem(
                              value: 'Newest',
                              child: Text('Newest'),
                            ),
                            DropdownMenuItem(
                              value: 'Oldest',
                              child: Text('Oldest'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSort = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: selectedCourseId,
                          decoration: const InputDecoration(
                            labelText: 'Course',
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Courses'),
                            ),
                            ...courses.map(
                              (course) => DropdownMenuItem<int?>(
                                value: course.id,
                                child: Text(course.courseCode),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCourseId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: selectedYearLevel,
                          decoration: const InputDecoration(
                            labelText: 'Year Level',
                          ),
                          items: const [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Years'),
                            ),
                            DropdownMenuItem(value: 1, child: Text('Year 1')),
                            DropdownMenuItem(value: 2, child: Text('Year 2')),
                            DropdownMenuItem(value: 3, child: Text('Year 3')),
                            DropdownMenuItem(value: 4, child: Text('Year 4')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedYearLevel = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: filteredStudents.isEmpty
                      ? const EmptyState(message: 'No students found.')
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];

                            return StudentCard(
                              student: student,
                              onView: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StudentDetailsPage(student: student),
                                  ),
                                );
                              },
                              onEdit: () async {
                                if (widget.user.role != 'admin') {
                                  return;
                                }

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditStudentPage(
                                      student: student,
                                      user: widget.user,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await loadData();
                                }
                              },
                              onDelete: () => deleteStudent(student),
                              canEdit: widget.user.role == 'admin',
                              canDelete: canDelete,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class __EmptyUserRepository extends UserRepository {
  __EmptyUserRepository(super.db);
}
