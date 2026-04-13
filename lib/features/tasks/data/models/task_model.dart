import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
    required super.createdAt,
  });

  /// 🔄 Firestore → Model
  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: map['priority'] ?? 'low',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 🔁 Convert Entity → Model (IMPORTANT)
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      priority: entity.priority,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }
}