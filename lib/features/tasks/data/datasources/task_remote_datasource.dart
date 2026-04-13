import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> addTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  /// 🔐 CURRENT USER ID (CRITICAL)
  String get _uid {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// 📦 TASK COLLECTION REFERENCE
  CollectionReference<Map<String, dynamic>> get _taskRef {
    return firestore
        .collection('users')
        .doc(_uid)
        .collection('tasks');
  }

  /// ➕ ADD TASK
  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await _taskRef.add(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
    print("Writing to Firestore for UID: $_uid");
  }

  /// 📥 GET TASKS (SORTED BY DUE DATE)
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _taskRef
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// ✏️ UPDATE TASK
  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskRef.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// ❌ DELETE TASK
  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRef.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}