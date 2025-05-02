import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_theme.dart';

class AddTodo extends StatefulWidget {
  final Function(Map<String, dynamic>) onTodoAdded;
  final Map<String, dynamic>? initialTask;

  const AddTodo({
    super.key,
    required this.onTodoAdded,
    this.initialTask,
  });

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _priority = "High";
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      _titleController.text = widget.initialTask!['title'] ?? '';
      _descriptionController.text = widget.initialTask!['description'] ?? '';
      _categoryController.text = widget.initialTask!['category'] ?? '';
      _amountController.text = widget.initialTask!['amount']?.toString() ?? '0.00';
      _priority = widget.initialTask!['priority'] ?? 'High';
      if (widget.initialTask!['deadline'] != null) {
        _deadline = DateTime.parse(widget.initialTask!['deadline']);
      }
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CustomTheme.primaryColor,
              onPrimary: Colors.white,
              surface: CustomTheme.backgroundColor,
              onSurface: CustomTheme.textColor,
            ),
            dialogBackgroundColor: CustomTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      prefixIcon: Icon(icon, color: CustomTheme.primaryColor),
      filled: true,
      fillColor: CustomTheme.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CustomTheme.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CustomTheme.accentColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: CustomTheme.primaryColor,
        title: Text(
          widget.initialTask != null ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              TextFormField(
                controller: _titleController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: _getInputDecoration(
                  label: 'Task Title',
                  icon: Icons.title,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                decoration: _getInputDecoration(
                  label: 'Description',
                  icon: Icons.description,
                ),
              ),
              const SizedBox(height: 16),

              // Priority Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Finance'),
                      selected: _priority == 'Finance',
                      onSelected: (selected) {
                        setState(() {
                          _priority = 'Finance';
                        });
                      },
                      selectedColor: CustomTheme.primaryColor,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _priority == 'Finance' ? Colors.white : CustomTheme.textColor,
                        fontFamily: 'Poppins',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Personal'),
                      selected: _priority == 'Personal',
                      onSelected: (selected) {
                        setState(() {
                          _priority = 'Personal';
                        });
                      },
                      selectedColor: CustomTheme.primaryColor,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _priority == 'Personal' ? Colors.white : CustomTheme.textColor,
                        fontFamily: 'Poppins',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deadline
              GestureDetector(
                onTap: _selectDeadline,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _deadline == null
                          ? ''
                          : DateFormat('MMM dd, yyyy').format(_deadline!),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: _getInputDecoration(
                      label: 'Deadline',
                      icon: Icons.calendar_today,
                    ),
                    validator: (value) {
                      if (_deadline == null) {
                        return 'Please select a deadline';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newTask = {
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'category': _categoryController.text,
                        'amount': double.tryParse(_amountController.text) ?? 0.0,
                        'deadline': _deadline!.toIso8601String(),
                        'priority': _priority,
                        'isCompleted': widget.initialTask?['isCompleted'] ?? false,
                        'type': widget.initialTask?['type'] ?? 'finance', // Maintain existing type
                      };
                      widget.onTodoAdded(newTask);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.initialTask != null ? 'Update Task' : 'Add Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}