import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/add_task_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onLongPress: onDelete,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHECKBOX
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.tealAccent
                        : const Color.fromARGB(255, 121, 33, 243),
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? (isDarkMode
                          ? Colors.tealAccent
                          : const Color.fromARGB(255, 123, 30, 236))
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? Icon(Icons.check,
                        color: isDarkMode ? Colors.black : Colors.white, size: 16)
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            // TEXT AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRIORITY BADGE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority)
                          .withOpacity(isDarkMode ? 0.3 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.priority.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _priorityColor(task.priority),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TITLE
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // DESCRIPTION
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DATE
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // EDIT & DELETE BUTTONS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EDIT BUTTON
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(task: task),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                ),

                // DELETE BUTTON
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete,
                      color: isDarkMode ? Colors.red[300] : Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
