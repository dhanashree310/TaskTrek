import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for task priority
enum TaskPriority { low, medium, high }

class Task {
  String id;
  String title;
  String description;
  DateTime dateTime;
  bool isCompleted;
  TaskPriority priority;
  double progress;
  bool isPinned;
  bool isArchived;
  String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.priority = TaskPriority.low,
    this.progress = 0.0,
    this.isPinned = false,
    this.isArchived = false,
    this.category = "Personal",
  });

  /// Create a Task object from Firestore document
factory Task.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  return Task(
    id: doc.id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    // Convert Firestore timestamp to UTC
    dateTime: data['dateTime'] != null
        ? (data['dateTime'] as Timestamp).toDate().toUtc()
        : DateTime.now().toUtc(),
    isCompleted: data['completed'] ?? false,
    priority: _priorityFromString(data['priority'] ?? 'low'),
    progress: (data['progress'] ?? 0).toDouble(),
    isPinned: data['isPinned'] ?? false,
    isArchived: data['isArchived'] ?? false,
    category: data['category'] ?? 'Personal',
  );
}


  /// Convert Task object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'completed': isCompleted,
      'priority': priority.toString().split('.').last,
      'progress': progress,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'category': category,
    };
  }

  /// Copy a Task object with new values
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    TaskPriority? priority,
    double? progress,
    bool? isPinned,
    bool? isArchived,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      category: category ?? this.category,
    );
  }

  /// Convert string to TaskPriority safely
  static TaskPriority _priorityFromString(String? value) {
    if (value == null) return TaskPriority.low;
    switch (value.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }
}
