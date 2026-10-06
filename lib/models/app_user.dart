class AppUser {
  final int? id;
  final String username;
  final String passwordHash;
  final String role;
  final String createdAt;

  AppUser({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'created_at': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      role: map['role'],
      createdAt: map['created_at'],
    );
  }
}