import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../database/database_helper.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository repository;
  final DatabaseHelper db;

  AuthService(
    this.repository,
    this.db,
  );

  String hashPassword(String password) {
    return sha256.convert(
      utf8.encode(password),
    ).toString();
  }

  Future<AppUser?> login(
    String username,
    String password,
  ) async {
    final user = await repository.findByUsername(
      username,
    );

    if (user == null) {
      return null;
    }

    final passwordHash = hashPassword(password);

    if (user.passwordHash == password ||
        user.passwordHash == passwordHash) {
      await db.logAction(
        userId: user.id,
        action: 'LOGIN',
        entity: 'User',
        entityId: user.id.toString(),
        details: 'Successful login',
      );

      return user;
    }

    return null;
  }

  bool canManageStudents(AppUser user) {
    return user.role == 'admin';
  }

  bool canViewStudents(AppUser user) {
    return user.role == 'admin' ||
        user.role == 'faculty';
  }

  bool canDeleteStudents(AppUser user) {
    return user.role == 'admin';
  }
}