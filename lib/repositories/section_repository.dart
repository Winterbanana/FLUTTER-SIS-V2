import '../database/database_helper.dart';
import '../models/section.dart';

class SectionRepository {
  final DatabaseHelper db;

  SectionRepository(this.db);

  Future<List<Section>> getAll() async {
    return await db.getSections();
  }

  Future<int> insert(Section section) {
    return db.insert(
      'sections',
      section.toMap(),
    );
  }
}