import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskEntity? task; // null = add, not null = edit

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() =>
      _AddEditTaskScreenState();
}

class _AddEditTaskScreenState
    extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  DateTime? selectedDate;
  String priority = 'low';

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.task?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    selectedDate = widget.task?.dueDate;
    priority = widget.task?.priority ?? 'low';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// PICK DATE
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// SAVE TASK
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a due date")),
      );
      return;
    }

    final notifier = ref.read(taskProvider.notifier);

    final task = TaskEntity(
      id: isEdit ? widget.task!.id : '',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: selectedDate!,
      priority: priority,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await notifier.editTask(task);
    } else {
      await notifier.createTask(task);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),

              const SizedBox(height: 12),

              /// DATE PICKER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? "No date selected"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// PRIORITY DROPDOWN
              DropdownButtonFormField<String>(
                value: priority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text("Low")),
                  DropdownMenuItem(value: 'medium', child: Text("Medium")),
                  DropdownMenuItem(value: 'high', child: Text("High")),
                ],
                onChanged: (val) {
                  setState(() {
                    priority = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Priority",
                ),
              ),

              const SizedBox(height: 20),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(isEdit ? "Update Task" : "Add Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}