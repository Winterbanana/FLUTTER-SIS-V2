class AuditLog {
  final int? id;
  final int? userId;
  final String action;
  final String entity;
  final String? entityId;
  final String? details;
  final String createdAt;

  AuditLog({
    this.id,
    this.userId,
    required this.action,
    required this.entity,
    this.entityId,
    this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'details': details,
      'created_at': createdAt,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'],
      userId: map['user_id'],
      action: map['action'],
      entity: map['entity'],
      entityId: map['entity_id'],
      details: map['details'],
      createdAt: map['created_at'],
    );
  }
}