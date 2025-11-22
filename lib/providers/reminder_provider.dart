import 'dart:math';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final DBService _dbService = DBService();
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks.where((t) => !t.isArchived).toList();

  ReminderProvider() {
    _init();
  }

  /// Streak calculation
  int get streak {
    final completedTasks = _tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (completedTasks.isEmpty) return 0;

    int streakCount = 1;
    for (int i = 0; i < completedTasks.length - 1; i++) {
      DateTime currentDay = DateTime(completedTasks[i].dateTime.year,
          completedTasks[i].dateTime.month, completedTasks[i].dateTime.day);
      DateTime nextDay = DateTime(
          completedTasks[i + 1].dateTime.year,
          completedTasks[i + 1].dateTime.month,
          completedTasks[i + 1].dateTime.day);
      if (currentDay.difference(nextDay).inDays == 1) {
        streakCount++;
      } else {
        break;
      }
    }
    return streakCount;
  }

  void _init() {
    _dbService.streamTasks().listen((taskList) {
      _tasks = taskList.where((t) => !t.isArchived).toList();
      _tasks.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return a.dateTime.compareTo(b.dateTime);
      });

      // Schedule smart reminders for all pending tasks
      for (var task in _tasks) {
        if (!task.isCompleted) {
          _scheduleSmartReminders(task);
        }
      }

      notifyListeners();
    });
  }

  /// Add new task
  Future<void> addTask(Task task) async {
    await _dbService.addTask(task);
    _tasks.add(task);

    if (!task.isCompleted) {
      _scheduleSmartReminders(task);
    }

    notifyListeners();
  }

  /// Update task (mark complete/incomplete or edit)
  Future<void> updateTask(Task task) async {
    await _dbService.updateTask(task);
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;

      // Cancel old notifications
      _cancelTaskNotifications(task);

      // Schedule new smart reminders if task is incomplete
      if (!task.isCompleted) {
        _scheduleSmartReminders(task);
      }
    }

    notifyListeners();
  }

  /// Delete task
  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);

    // Cancel all notifications for this task
    final task = _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () =>
          Task(id: '', title: '', description: '', dateTime: DateTime.now()),
    );
    _cancelTaskNotifications(task);

    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// -----------------------------
  /// Helper functions for smart reminders
  /// -----------------------------
  final List<Duration> _reminderIntervals = [
    Duration(days: 3),
    Duration(days: 2),
    Duration(days: 1),
    Duration(days: 1),
    Duration(hours: 12),
    Duration(hours: 6),
    Duration(hours: 3),
    Duration(hours: 1),
    Duration(minutes: 30),
    Duration(minutes: 15),
    Duration(minutes: 5),
  ];

  void _scheduleSmartReminders(Task task) {
    final messages = [
      "Don't forget your task '\$taskName'! 🚀",
      "Hey! '\$taskName' is waiting for you! 🎯",
      "Time to complete '\$taskName'! 🕒",
      "Reminder: '\$taskName' – let's crush it! 💪",
      "Psst… '\$taskName' is calling your name! 📣",
      "Oops! '\$taskName' is still pending 😅",
      "Heads up! '\$taskName' needs attention ⚡",
      "Your task '\$taskName' is approaching fast! 🏃‍♂️",
      "Tick-tock! '\$taskName' deadline is near ⏰",
    ];

    final random = Random();

    for (var interval in _reminderIntervals) {
      final notifyTime = task.dateTime.subtract(interval);
      if (notifyTime.isAfter(DateTime.now())) {
        final message = messages[random.nextInt(messages.length)]
            .replaceAll("\$taskName", task.title);

        NotificationService.scheduleTaskReminder(
          id: task.id.hashCode + interval.inSeconds,
          taskName: message,
          dateTime: notifyTime,
          daily: false,
        );
      }
    }
  }

  void _cancelTaskNotifications(Task task) {
    for (var interval in _reminderIntervals) {
      NotificationService.cancelNotification(
          task.id.hashCode + interval.inSeconds);
    }
  }
}
