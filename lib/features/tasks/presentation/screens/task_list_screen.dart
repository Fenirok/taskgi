import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {

  @override
  void initState() {
    super.initState();

    /// Fetch tasks on screen load
    Future.microtask(() {
      ref.read(taskProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            _header(),

            /// FILTERS
            _filters(notifier),

            /// TASK LIST
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifier.filteredTasks.isEmpty
                  ? const Center(child: Text("No tasks found"))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: notifier.filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = notifier.filteredTasks[index];

                  return Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      notifier.removeTask(task.id);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: TaskCard(task: task),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// HEADER UI
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "My Tasks",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER UI
  Widget _filters(TaskNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// Priority filter
          DropdownButton<String>(
            value: ref.watch(taskProvider).priorityFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text("All")),
              DropdownMenuItem(value: 'low', child: Text("Low")),
              DropdownMenuItem(value: 'medium', child: Text("Medium")),
              DropdownMenuItem(value: 'high', child: Text("High")),
            ],
            onChanged: (val) {
              notifier.setPriorityFilter(val!);
            },
          ),

          /// Status filter
          DropdownButton<String>(
            value: ref.watch(taskProvider).statusFilter == null
                ? 'all'
                : ref.watch(taskProvider).statusFilter!
                ? 'completed'
                : 'incomplete',
            items: const [
              DropdownMenuItem(value: 'all', child: Text("All")),
              DropdownMenuItem(value: 'completed', child: Text("Completed")),
              DropdownMenuItem(value: 'incomplete', child: Text("Incomplete")),
            ],
            onChanged: (val) {
              if (val == 'all') {
                notifier.setStatusFilter(null);
              } else if (val == 'completed') {
                notifier.setStatusFilter(true);
              } else {
                notifier.setStatusFilter(false);
              }
            },
          ),
        ],
      ),
    );
  }
}