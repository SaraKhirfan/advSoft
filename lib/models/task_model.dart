// models/task_model.dart
class Task {
  final String? id;
  final String title;
  final String description;
  final String category;
  final double amount;
  final DateTime deadline;
  final String priority;
  final bool isCompleted;
  final String type; // 'finance' or 'personal'
  final String userId;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.deadline,
    required this.priority,
    required this.isCompleted,
    required this.type,
    required this.userId,
    required this.createdAt,
  });

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'amount': amount,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'type': type,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firebase document
  factory Task.fromFirestore(Map<String, dynamic> data, String docId) {
    return Task(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      deadline: DateTime.parse(data['deadline']),
      priority: data['priority'] ?? 'High',
      isCompleted: data['isCompleted'] ?? false,
      type: data['type'] ?? 'finance',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  // Create copy with changes
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? amount,
    DateTime? deadline,
    String? priority,
    bool? isCompleted,
    String? type,
    String? userId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}