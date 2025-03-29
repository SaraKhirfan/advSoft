import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AddToDo.dart';
import 'custom_theme.dart';

class MyTasks extends StatefulWidget {
  const MyTasks({super.key});

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Pay electricity bill',
      'description': 'Due on 15th of the month',
      'category': 'Bills',
      'amount': 85.50,
      'deadline': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'isCompleted': true,
      'type': 'finance',
    },
    {
      'id': '2',
      'title': 'Monthly savings transfer',
      'description': 'Move 20% to savings account',
      'category': 'Savings',
      'amount': 500.00,
      'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'isCompleted': true,
      'type': 'finance',
    },
    {
      'id': '3',
      'title': 'Grocery shopping',
      'description': 'Weekly groceries for family',
      'category': 'Shopping',
      'amount': 120.00,
      'deadline': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'isCompleted': true,
      'type': 'personal',
    },
    {
      'id': '4',
      'title': 'Call accountant',
      'description': 'Discuss tax deductions',
      'category': 'Financial Planning',
      'amount': 0.00,
      'deadline': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'isCompleted': false,
      'type': 'finance',
    },
    {
      'id': '5',
      'title': 'Morning workout',
      'description': '30 min cardio session',
      'category': 'Health',
      'amount': 0.00,
      'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'isCompleted': false,
      'type': 'personal',
    },
  ];

  // Custom Theme Colors
  static const Color _primaryColor = Color(0xFF6C63FF);
  static const Color _secondaryColor = Color(0xFF4A45B1);
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _cardColor = Colors.white;
  static const Color _textColor = Color(0xFF2D3748);
  static const Color _textSecondaryColor = Color(0xFF718096);
  static const Color _accentColor = Color(0xFF48BB78);
  static const Color _dangerColor = Color(0xFFE53E3E);

  void _addNewTask(Map<String, dynamic> newTask) {
    setState(() {
      _tasks.add({
        ...newTask,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'isCompleted': false,
      });
    });
  }

  void _navigateToEditPage(Map<String, dynamic> task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTodo(
          onTodoAdded: _addNewTask,
          initialTask: task,
        ),
      ),
    );
  }

  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    setState(() {
      final index = _tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        _tasks[index]['isCompleted'] = !isCompleted;
      }
    });
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Task?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          content: const Text(
            'This task will be permanently removed.',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: _textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _textSecondaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks.removeWhere((task) => task['id'] == taskId);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    content: const Text(
                      "Task deleted",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _dangerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: CustomTheme.primaryColor,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddTodo(onTodoAdded: _addNewTask),
          ),
        ),
        backgroundColor: CustomTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    final completedTasks = _tasks.where((task) => task['isCompleted']).toList();
    final incompleteTasks = _tasks.where((task) => !task['isCompleted']).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (incompleteTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "TO-DO (${incompleteTasks.length})",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CustomTheme.primaryColor,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...incompleteTasks.map((task) => _buildTaskCard(task)),
        ],
        if (completedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              "COMPLETED (${completedTasks.length})",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CustomTheme.primaryColor,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...completedTasks.map((task) => _buildTaskCard(task)),
        ],
        if (_tasks.isEmpty) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty_tasks.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  "No tasks yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: _textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap + to add your first task",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: _textSecondaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final deadline = task['deadline'] != null
        ? DateTime.parse(task['deadline'])
        : null;

    Color priorityColor;
    switch (task['priority']) {
      case 'High':
        priorityColor = _dangerColor;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = _accentColor;
        break;
      default:
        priorityColor = _textSecondaryColor;
    }

    return Card(
      color: _cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditPage(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task['isCompleted'] ? _accentColor : _textSecondaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    task['isCompleted'] ? Icons.check_rounded : null,
                    color: _accentColor,
                    size: 20,
                  ),
                  onPressed: () => _toggleTaskCompletion(task['id'], task['isCompleted']),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] ?? 'Untitled Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        decoration: task['isCompleted']
                            ? TextDecoration.lineThrough
                            : null,
                        color: task['isCompleted']
                            ? _textSecondaryColor
                            : _textColor,
                      ),
                    ),
                    if (task['description'] != null && task['description'].isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task['description'],
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Priority Tag
                        if (task['priority'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle_rounded,
                                  size: 8,
                                  color: priorityColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  task['priority'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: priorityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Deadline
                        if (deadline != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: deadline.isBefore(DateTime.now())
                                  ? _dangerColor.withOpacity(0.1)
                                  : _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: deadline.isBefore(DateTime.now())
                                      ? _dangerColor
                                      : _primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM dd').format(deadline),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: deadline.isBefore(DateTime.now())
                                        ? _dangerColor
                                        : _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                color: _textSecondaryColor.withOpacity(0.5),
                onPressed: () => _showTaskOptions(task['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskOptions(String taskId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  final task = _tasks.firstWhere((t) => t['id'] == taskId);
                  _navigateToEditPage(task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded),
                title: const Text('Delete Task'),
                textColor: _dangerColor,
                iconColor: _dangerColor,
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(taskId);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}