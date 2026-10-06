import '../database/database_helper.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';

class StudentService {
  final StudentRepository repository;
  final DatabaseHelper db;

  StudentService(this.repository, this.db);

  Future<List<Student>> getStudents() => repository.getAll();

  void _ensureCanManageStudents(String role) {
    if (role != 'admin') {
      throw Exception('Only administrators can manage student records.');
    }
  }

  Future<void> createStudent(
    Student student, {
    required int? currentUserId,
    required String currentUserRole,
  }) async {
    _ensureCanManageStudents(currentUserRole);

    final existing = await repository.findByStudentId(student.studentId);
    if (existing != null) {
      throw Exception('Student ID already exists.');
    }

    await repository.insert(student);
    await db.logAction(
      userId: currentUserId,
      action: 'CREATE',
      entity: 'Student',
      entityId: student.studentId,
      details: 'Student record created',
    );
  }

  Future<void> updateStudent(
    Student student, {
    required int? currentUserId,
    required String currentUserRole,
  }) async {
    _ensureCanManageStudents(currentUserRole);

    if (student.id == null) {
      throw Exception('Student ID is missing.');
    }

    final existing = await repository.findByStudentId(student.studentId);
    if (existing != null && existing.id != student.id) {
      throw Exception('Student ID already exists.');
    }

    await repository.update(student);
    await db.logAction(
      userId: currentUserId,
      action: 'UPDATE',
      entity: 'Student',
      entityId: student.studentId,
      details: 'Student record updated',
    );
  }

  Future<void> deleteStudent(
    int id, {
    required int? currentUserId,
    required String currentUserRole,
    String? studentId,
  }) async {
    _ensureCanManageStudents(currentUserRole);

    await repository.delete(id);
    await db.logAction(
      userId: currentUserId,
      action: 'DELETE',
      entity: 'Student',
      entityId: studentId,
      details: 'Student record deleted',
    );
  }
}
