import '../database/database_helper.dart';
import '../models/course.dart';

class CourseRepository {
  final DatabaseHelper db;

  CourseRepository(this.db);

  Future<List<Course>> getAll() async {
    return await db.getCourses();
  }

  Future<int> insert(Course course) {
    return db.insert(
      'courses',
      course.toMap(),
    );
  }
}