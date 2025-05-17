import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_to_do.dart';
import 'custom_theme.dart';
import 'services/firebase_service.dart';
import 'services/task_service.dart';

class MyTasks extends StatefulWidget {
  const MyTasks({super.key});

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const Color _primaryColor = Color(0xFF6C63FF);
  static const Color _secondaryColor = Color(0xFF4A45B1);
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _cardColor = Colors.white;
  static const Color _textColor = Color(0xFF2D3748);
  static const Color _textSecondaryColor = Color(0xFF718096);
  static const Color _accentColor = Color(0xFF48BB78);
  static const Color _dangerColor = Color(0xFFE53E3E);

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (FirebaseService.currentUserId == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _taskService.getUserTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tasks: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _addNewTask(Map<String, dynamic> newTask) async {
    setState(() => _isLoading = true);

    try {
      // Add userId and createdAt
      newTask['userId'] = FirebaseService.currentUserId;
      newTask['createdAt'] = DateTime.now().toIso8601String();

      final taskId = await _taskService.addTask(newTask);
      if (taskId != null) {
        // Add the ID to the task and add it to the list
        newTask['id'] = taskId;
        setState(() {
          _tasks.add(newTask);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to add task';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToEditPage(Map<String, dynamic> task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTodo(
          onTodoAdded: (updatedTask) => _updateTask(task['id'], updatedTask),
          initialTask: task,
        ),
      ),
    );
  }

  void _updateTask(String taskId, Map<String, dynamic> updatedTask) async {
    setState(() => _isLoading = true);

    try {
      // Ensure we keep the ID and user ID
      updatedTask['id'] = taskId;
      updatedTask['userId'] = FirebaseService.currentUserId;

      final success = await _taskService.updateTask(updatedTask);
      if (success) {
        setState(() {
          // Update the task in the local list
          final index = _tasks.indexWhere((t) => t['id'] == taskId);
          if (index != -1) {
            _tasks[index] = updatedTask;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to update task';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      final success = await _taskService.toggleTaskCompletion(taskId, isCompleted);
      if (success) {
        setState(() {
          final index = _tasks.indexWhere((task) => task['id'] == taskId);
          if (index != -1) {
            _tasks[index]['isCompleted'] = !isCompleted;
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update task status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);

                try {
                  final success = await _taskService.deleteTask(taskId);
                  if (success) {
                    setState(() {
                      _tasks.removeWhere((task) => task['id'] == taskId);
                      _isLoading = false;
                    });

                    if (mounted) {
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
                    }
                  } else {
                    setState(() {
                      _errorMessage = 'Failed to delete task';
                      _isLoading = false;
                    });
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Error: $e';
                    _isLoading = false;
                  });
                }
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
    if (_isLoading) {
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
        body: const Center(
          child: CircularProgressIndicator(
            color: CustomTheme.primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Tasks',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
            tooltip: 'Refresh tasks',
          ),
        ],
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
        backgroundColor: Colors.deepPurple,
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
              Icon(Icons.task_alt_rounded, color: Colors.grey, size: 60,),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task['priority'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: priorityColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        // Category Tag
                        if (task['category'] != null && task['category'].isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task['category'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: _primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        // Deadline Tag
                        if (deadline != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: _textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd').format(deadline),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: _textSecondaryColor,
                                    fontWeight: FontWeight.w500,
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
              // Right side actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Delete Button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: _textSecondaryColor.withOpacity(0.7),
                    ),
                    onPressed: () => _deleteTask(task['id']),
                    iconSize: 20,
                  ),
                  const SizedBox(height: 4),
                  // Amount if present
                  if (task['amount'] != null && (task['amount'] as double) > 0) ...[
                    Text(
                      'JOD ${task['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: _textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}