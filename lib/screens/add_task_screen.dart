import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/reminder_provider.dart';
import 'package:intl/intl.dart';
import 'package:remind/utils/helpers.dart'; // SnackBar helper

class AddTaskScreen extends StatefulWidget {
  final Task? task; // null → add, not null → edit

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;
  TaskPriority _selectedPriority = TaskPriority.low;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task?.title ?? '';
    _descController.text = widget.task?.description ?? '';
    _selectedDate = widget.task?.dateTime;
    _selectedPriority = widget.task?.priority ?? TaskPriority.low;
    _progress = widget.task?.progress ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter a title' : null,
                ),
                SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date & Time'
                              : DateFormat('yyyy-MM-dd – kk:mm')
                                  .format(_selectedDate!),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _selectedDate ?? DateTime.now()),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Priority
                Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((priority) {
                    bool isSelected = _selectedPriority == priority;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                            priority.toString().split('.').last.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedPriority = priority);
                        },
                        selectedColor: Color.fromARGB(255, 121, 0, 202),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Progress
                Text('Progress (optional)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _progress,
                  onChanged: (val) => setState(() => _progress = val),
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: '${(_progress * 100).round()}%',
                ),
                SizedBox(height: 24),

                // Add / Update Task Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (_selectedDate == null) {
                        showSnackBar(context, "Please select date & time");
                        return;
                      }

                      final task = widget.task?.copyWith(
                            title: _titleController.text.trim(),
                            description: _descController.text.trim(),
                            dateTime: _selectedDate!,
                            priority: _selectedPriority,
                            progress: _progress,
                          ) ??
                          Task(
                            id: '',
                            title: _titleController.text.trim(),
                            description: _descController.text.trim(),
                            dateTime: _selectedDate!,
                            priority: _selectedPriority,
                            progress: _progress,
                          );

                      if (widget.task == null) {
                        await provider.addTask(task);
                        showSnackBar(context, "Task added successfully!");
                      } else {
                        await provider.updateTask(task);
                        showSnackBar(context, "Task updated successfully!");
                      }

                      await Future.delayed(Duration(milliseconds: 500));
                      Navigator.pop(context);
                    },
                    child: Text(widget.task == null ? 'Add Task' : 'Update Task',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
