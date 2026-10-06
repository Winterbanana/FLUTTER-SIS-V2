import '../database/database_helper.dart';
import '../models/app_user.dart';

class UserRepository {
  final DatabaseHelper db;

  UserRepository(this.db);

  Future<AppUser?> findByUsername(String username) async {
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> getAll() async {
    final rows = await db.query(
      'users',
      orderBy: 'username ASC',
    );

    return rows.map(AppUser.fromMap).toList();
  }
}