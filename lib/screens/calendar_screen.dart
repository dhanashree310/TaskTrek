import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/reminder_provider.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade300;
      case TaskPriority.medium:
        return Colors.orange.shade300;
      case TaskPriority.low:
      default:
        return Colors.green.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);

    // Filter tasks for selected day
    List<Task> dayTasks = _selectedDay == null
        ? []
        : provider.tasks.where((task) =>
            task.dateTime.year == _selectedDay!.year &&
            task.dateTime.month == _selectedDay!.month &&
            task.dateTime.day == _selectedDay!.day).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          SizedBox(height: 8),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text('Select a day to see tasks'))
                : dayTasks.isEmpty
                    ? Center(child: Text('No tasks for this day'))
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: dayTasks.length,
                        itemBuilder: (context, index) {
                          final task = dayTasks[index];
                          return Card(
                            color: task.isCompleted
                                ? Colors.green.shade100
                                : Colors.yellow.shade100,
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              getPriorityColor(task.priority),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          task.priority
                                              .toString()
                                              .split('.')
                                              .last
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    task.description,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  SizedBox(height: 8),
                                  if (!task.isCompleted)
                                    LinearProgressIndicator(
                                      value: task.progress,
                                      backgroundColor: Colors.grey[200],
                                      color: Colors.blue,
                                      minHeight: 6,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
