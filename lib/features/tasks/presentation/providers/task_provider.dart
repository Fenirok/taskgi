import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task.dart';
import '../../domain/usecases/update_task.dart';

/// --------------------
/// STATE
/// --------------------
class TaskState {
  final bool isLoading;
  final List<TaskEntity> tasks;
  final String? error;

  /// Filters
  final String priorityFilter; // all | low | medium | high
  final bool? statusFilter; // null | true | false

  const TaskState({
    this.isLoading = false,
    this.tasks = const [],
    this.error,
    this.priorityFilter = 'all',
    this.statusFilter,
  });

  TaskState copyWith({
    bool? isLoading,
    List<TaskEntity>? tasks,
    String? error,
    String? priorityFilter,
    bool? statusFilter,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      error: error,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// --------------------
/// NOTIFIER
/// --------------------
class TaskNotifier extends StateNotifier<TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskNotifier({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(const TaskState());

  /// FETCH TASKS
  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await getTasks();

      state = state.copyWith(
        isLoading: false,
        tasks: tasks,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// ADD TASK
  Future<void> createTask(TaskEntity task) async {
    await addTask(task);
    await fetchTasks();
  }

  /// UPDATE TASK
  Future<void> editTask(TaskEntity task) async {
    await updateTask(task);
    await fetchTasks();
  }

  /// DELETE TASK
  Future<void> removeTask(String id) async {
    await deleteTask(id);
    await fetchTasks();
  }

  Map<String, List<TaskEntity>> get groupedTasks {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    Map<String, List<TaskEntity>> groups = {
      "Today": [],
      "Tomorrow": [],
      "This Week": [],
      "Later": [],
    };

    for (final task in filteredTasks) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      if (taskDate == today) {
        groups["Today"]!.add(task);
      } else if (taskDate == tomorrow) {
        groups["Tomorrow"]!.add(task);
      } else if (taskDate.isBefore(nextWeek)) {
        groups["This Week"]!.add(task);
      } else {
        groups["Later"]!.add(task);
      }
    }

    return groups;
  }

  /// TOGGLE COMPLETE

  Future<void> toggleComplete(TaskEntity task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
    );


    final updatedList = state.tasks.map((t) {
      return t.id == task.id ? updated : t;
    }).toList();

    state = state.copyWith(tasks: updatedList);

    try {

      await updateTask(updated);
    } catch (e) {

      final rollbackList = state.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();

      state = state.copyWith(tasks: rollbackList);
    }
  }

  /// SET PRIORITY FILTER
  void setPriorityFilter(String value) {
    state = state.copyWith(priorityFilter: value);
  }

  /// SET STATUS FILTER
  void setStatusFilter(bool? value) {
    state = state.copyWith(statusFilter: value);
  }

  /// FILTERED + SORTED TASKS
  List<TaskEntity> get filteredTasks {
    final filtered = state.tasks.where((task) {
      final matchPriority = state.priorityFilter == 'all' ||
          task.priority == state.priorityFilter;

      final matchStatus = state.statusFilter == null ||
          task.isCompleted == state.statusFilter;

      return matchPriority && matchStatus;
    }).toList();

    /// Sort by due date
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return filtered;
  }
}

/// --------------------
/// DEPENDENCY INJECTION
/// --------------------

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return TaskRepositoryImpl(
    ref.read(taskRemoteDataSourceProvider),
  );
});

final getTasksProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.read(taskRepositoryProvider));
});

final addTaskProvider = Provider<AddTask>((ref) {
  return AddTask(ref.read(taskRepositoryProvider));
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.read(taskRepositoryProvider));
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.read(taskRepositoryProvider));
});

final taskProvider =
StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    getTasks: ref.read(getTasksProvider),
    addTask: ref.read(addTaskProvider),
    updateTask: ref.read(updateTaskProvider),
    deleteTask: ref.read(deleteTaskProvider),
  );
});