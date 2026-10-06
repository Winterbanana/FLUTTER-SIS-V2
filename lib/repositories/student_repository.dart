import '../database/database_helper.dart';
import '../models/student.dart';

class StudentRepository {
  final DatabaseHelper db;

  StudentRepository(this.db);

  Future<List<Student>> getAll() async {
    return db.getStudents();
  }

  Future<Student?> findByStudentId(String studentId) async {
    final rows = await db.query(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Student.fromMap(rows.first);
  }

  Future<int> insert(Student student) {
    return db.insert('students', student.toMap());
  }

  Future<int> update(Student student) {
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> delete(int id) {
    return db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}
