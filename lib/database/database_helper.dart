import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/student.dart';
import '../models/course.dart';
import '../models/section.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'sis_v2.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await _createVersion2Tables(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createVersion2Tables(db);
    }
  }

  Future<void> _createVersion2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_code TEXT NOT NULL UNIQUE,
        course_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section_name TEXT NOT NULL,
        year_level INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        middle_name TEXT NOT NULL DEFAULT '',
        last_name TEXT NOT NULL,
        gender TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        year_level INTEGER NOT NULL,
        section_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'Active',
        date_enrolled TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id)
          REFERENCES courses(id),
        FOREIGN KEY (section_id)
          REFERENCES sections(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entity_id TEXT,
        details TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    final courseCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM courses'),
        ) ??
        0;

    if (courseCount == 0) {
      await db.insert('courses', {
        'course_code': 'BSIT',
        'course_name': 'Bachelor of Science in Information Technology',
      });

      await db.insert('courses', {
        'course_code': 'BSCS',
        'course_name': 'Bachelor of Science in Computer Science',
      });

      await db.insert('courses', {
        'course_code': 'BSEMC',
        'course_name':
            'Bachelor of Science in Entertainment and Multimedia Computing',
      });
    }

    final sectionCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM sections'),
        ) ??
        0;

    if (sectionCount == 0) {
      await db.insert('sections', {'section_name': 'A', 'year_level': 1});

      await db.insert('sections', {'section_name': 'B', 'year_level': 2});

      await db.insert('sections', {'section_name': 'C', 'year_level': 3});

      await db.insert('sections', {'section_name': 'D', 'year_level': 4});
    }

    final userCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;

    if (userCount == 0) {
      final now = DateTime.now().toIso8601String();

      await db.insert('users', {
        'username': 'admin',
        'password_hash': 'admin123',
        'role': 'admin',
        'created_at': now,
      });

      await db.insert('users', {
        'username': 'faculty',
        'password_hash': 'faculty123',
        'role': 'faculty',
        'created_at': now,
      });

      await db.insert('users', {
        'username': 'student',
        'password_hash': 'student123',
        'role': 'student',
        'created_at': now,
      });
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;

    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;

    return await db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;

    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;

    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Student>> getStudents() async {
    final rows = await query('students', orderBy: 'last_name ASC');

    return rows.map(Student.fromMap).toList();
  }

  Future<List<Course>> getCourses() async {
    final rows = await query('courses', orderBy: 'course_code ASC');

    return rows.map(Course.fromMap).toList();
  }

  Future<List<Section>> getSections() async {
    final rows = await query('sections', orderBy: 'year_level ASC');

    return rows.map(Section.fromMap).toList();
  }

  Future<void> logAction({
    required int? userId,
    required String action,
    required String entity,
    String? entityId,
    String? details,
  }) async {
    await insert('audit_logs', {
      'user_id': userId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
