import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/app_user.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';
import '../services/student_service.dart';
import '../widgets/loading_widget.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'students/student_list_page.dart';

class DashboardPage extends StatefulWidget {
  final AppUser user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {
  late final StudentService studentService;

  List<Student> students = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final db = DatabaseHelper.instance;

    studentService = StudentService(
      StudentRepository(db),
      db,
    );

    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result =
          await studentService.getStudents();

      setState(() {
        students = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load dashboard data.';
      });
    }
  }

  int get totalStudents =>
      students.length;

  int get activeStudents =>
      students
          .where(
            (student) =>
                student.status == 'Active',
          )
          .length;

  int get inactiveStudents =>
      students
          .where(
            (student) =>
                student.status == 'Inactive',
          )
          .length;

  int get graduatedStudents =>
      students
          .where(
            (student) =>
                student.status == 'Graduated',
          )
          .length;

  Future<void> logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget statCard(
    String title,
    int value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Information System',
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfilePage(
                    user: widget.user,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const LoadingWidget()
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : RefreshIndicator(
                  onRefresh: loadStudents,
                  child: ListView(
                    padding:
                        const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Welcome, ${widget.user.username}',
                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Role: ${widget.user.role.toUpperCase()}',
                      ),

                      const SizedBox(height: 24),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          statCard(
                            'Total Students',
                            totalStudents,
                            Icons.people,
                          ),
                          statCard(
                            'Active',
                            activeStudents,
                            Icons.check_circle,
                          ),
                          statCard(
                            'Inactive',
                            inactiveStudents,
                            Icons.pause_circle,
                          ),
                          statCard(
                            'Graduated',
                            graduatedStudents,
                            Icons.school,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      if (widget.user.role ==
                              'admin' ||
                          widget.user.role ==
                              'faculty')
                        Card(
                          child: ListTile(
                            leading:
                                const Icon(
                              Icons.people,
                            ),
                            title: const Text(
                              'Student List',
                            ),
                            subtitle:
                                const Text(
                              'Search, filter, sort and manage students.',
                            ),
                            trailing:
                                const Icon(
                              Icons.arrow_forward,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StudentListPage(
                                    user:
                                        widget.user,
                                  ),
                                ),
                              ).then(
                                (_) =>
                                    loadStudents(),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 12),

                      Card(
                        child: ListTile(
                          leading:
                              const Icon(
                            Icons.person,
                          ),
                          title: const Text(
                            'Profile',
                          ),
                          subtitle:
                              const Text(
                            'View account information.',
                          ),
                          trailing:
                              const Icon(
                            Icons.arrow_forward,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfilePage(
                                  user:
                                      widget.user,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}