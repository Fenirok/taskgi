import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskgi/features/tasks/presentation/screens/logout_screen.dart';

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

      body: Column(
        children: [

          /// HEADER
          _header(),

          /// FILTERS
          _filters(notifier),

          /// TASK LIST

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6FA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groupedList(ref),
            ),
          ),

        ],
      ),

      /// ADD BUTTON
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddEditTaskScreen(),
              ),
            );
          },
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Icon(Icons.list, color: Colors.grey.shade700),

              const SizedBox(width: 40), // space for FAB

              //Icon(Icons.calendar_today, color: Colors.grey.shade700),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.grey.shade700),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogoutScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER UI

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP ROW (menu + profile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text("👤"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// SEARCH BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Search tasks...",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "My Tasks",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _groupedList(WidgetRef ref) {
    final notifier = ref.read(taskProvider.notifier);
    final grouped = notifier.groupedTasks;

    /// EMPTY CHECK
    final isEmpty = grouped.values.every((list) => list.isEmpty);

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.task_alt, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("No tasks yet"),
          ],
        ),
      );
    }

    /// EXISTING LIST
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: grouped.entries.map((entry) {
        final title = entry.key;
        final tasks = entry.value;

        if (tasks.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// SECTION HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// TASKS
            ...tasks.map((task) {
              return Dismissible(
                key: Key(task.id),


                direction: DismissDirection.endToStart,


                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                /// OPTIONAL: slight confirm feel (prevents accidental delete)
                confirmDismiss: (direction) async {
                  return true; // you can add dialog later if needed
                },

                onDismissed: (_) {
                  ref.read(taskProvider.notifier).removeTask(task.id);
                },

                child: TaskCard(task: task),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  /// FILTER UI
  Widget _filters(TaskNotifier notifier) {
    final state = ref.watch(taskProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// PRIORITY FILTER
          _filterChip(
            label: _priorityLabel(state.priorityFilter),
            icon: Icons.flag,
            onTap: () {
              _showPrioritySheet(context, notifier);
            },
          ),

          /// STATUS FILTER
          _filterChip(
            label: _statusLabel(state.statusFilter),
            icon: Icons.check_circle_outline,
            onTap: () {
              _showStatusSheet(context, notifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
  String _priorityLabel(String value) {
    switch (value) {
      case 'low':
        return "Low";
      case 'medium':
        return "Medium";
      case 'high':
        return "High";
      default:
        return "All";
    }
  }

  String _statusLabel(bool? value) {
    if (value == null) return "All";
    if (value) return "Completed";
    return "Incomplete";
  }

  void _showPrioritySheet(BuildContext context, TaskNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _sheetItem("All", () {
              notifier.setPriorityFilter('all');
              Navigator.pop(context);
            }),

            _sheetItem("Low", () {
              notifier.setPriorityFilter('low');
              Navigator.pop(context);
            }),

            _sheetItem("Medium", () {
              notifier.setPriorityFilter('medium');
              Navigator.pop(context);
            }),

            _sheetItem("High", () {
              notifier.setPriorityFilter('high');
              Navigator.pop(context);
            }),
          ],
        );
      },
    );
  }

  void _showStatusSheet(BuildContext context, TaskNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _sheetItem("All", () {
              notifier.setStatusFilter(null);
              Navigator.pop(context);
            }),

            _sheetItem("Completed", () {
              notifier.setStatusFilter(true);
              Navigator.pop(context);
            }),

            _sheetItem("Incomplete", () {
              notifier.setStatusFilter(false);
              Navigator.pop(context);
            }),
          ],
        );
      },
    );
  }

  Widget _sheetItem(String text, VoidCallback onTap) {
    return ListTile(
      title: Text(text),
      onTap: onTap,
    );
  }

}