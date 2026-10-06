import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import 'add_student_page.dart';
import 'edit_student_page.dart';
import 'student_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = DatabaseHelper.instance;

  final searchController = TextEditingController();

  List<Student> students = [];
  List<Student> filteredStudents = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await database.getStudents();

      setState(() {
        students = result;
        filteredStudents = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Database error: $e');

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load students.';
      });
    }
  }

  void searchStudents(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredStudents = students.where((student) {
        return student.name.toLowerCase().contains(lowerQuery) ||
            student.course.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> addStudent() async {
    final newStudent = await Navigator.push<Student>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStudentPage(),
      ),
    );

    if (newStudent != null) {
      await loadStudents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully.'),
        ),
      );
    }
  }

  Future<void> editStudent(Student student) async {
    final updatedStudent = await Navigator.push<Student>(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(
          student: student,
        ),
      ),
    );

    if (updatedStudent != null) {
      await loadStudents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully.'),
        ),
      );
    }
  }

  Future<void> deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete ${student.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await database.deleteStudent(student.id!);

        await loadStudents();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted.'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete student.'),
          ),
        );
      }
    }
  }

  Widget buildStudentList() {
    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student = filteredStudents[index];

          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(student.name),
            subtitle: Text(student.course),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    editStudent(student);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteStudent(student);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDetailsPage(
                    student: student,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 70,
          ),
          const SizedBox(height: 16),
          const Text(
            'No students found.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: addStudent,
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Unable to load students.',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loadStudents,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information System'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: searchStudents,
              decoration: const InputDecoration(
                labelText: 'Search Student',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : errorMessage != null
                    ? buildErrorState()
                    : filteredStudents.isEmpty
                        ? buildEmptyState()
                        : buildStudentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}