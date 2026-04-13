import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskEntity task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(taskProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// CHECKBOX
          GestureDetector(
            onTap: () {
              notifier.toggleComplete(task);
            },
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xFF6C63FF)
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                const SizedBox(height: 4),

                /// DESCRIPTION
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                const SizedBox(height: 8),

                /// FOOTER ROW (DATE + PRIORITY)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// DATE
                    Text(
                      _formatDate(task.dueDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    /// PRIORITY CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PRIORITY COLOR
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// DATE FORMAT
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}