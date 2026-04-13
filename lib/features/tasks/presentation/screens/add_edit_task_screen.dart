import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskEntity? task;

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
      backgroundColor: const Color(0xFFF5F6FA),

      body: Column(
        children: [

          /// 🔥 HEADER
          _header(context),

          /// FORM
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    /// TITLE FIELD
                    _inputField(
                      controller: titleController,
                      hint: "Task title",
                      validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 14),

                    /// DESCRIPTION FIELD
                    _inputField(
                      controller: descriptionController,
                      hint: "Description",
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    /// DATE + PRIORITY
                    Row(
                      children: [

                        /// DATE
                        Expanded(
                          child: _actionBox(
                            icon: Icons.calendar_today,
                            text: selectedDate == null
                                ? "Select date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            onTap: _pickDate,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// PRIORITY
                        Expanded(
                          child: _actionBox(
                            icon: Icons.flag,
                            text: priority.toUpperCase(),
                            onTap: _showPrioritySheet,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEdit ? "Update Task" : "Add Task",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HEADER
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text(
            isEdit ? "Edit Task" : "New Task",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ACTION BOX (DATE + PRIORITY)
  Widget _actionBox({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PRIORITY SELECT SHEET
  void _showPrioritySheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _priorityItem("low"),
            _priorityItem("medium"),
            _priorityItem("high"),
          ],
        );
      },
    );
  }

  Widget _priorityItem(String value) {
    return ListTile(
      title: Text(value.toUpperCase()),
      onTap: () {
        setState(() {
          priority = value;
        });
        Navigator.pop(context);
      },
    );
  }
}