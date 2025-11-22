import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../providers/profile_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/helpers.dart'; // for showSnackBar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _askNotificationPermission();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _askNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) return;

    PermissionStatus newStatus = await Permission.notification.request();
    if (newStatus.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Enable Notifications"),
          content: Text(
              "Notifications are disabled permanently. Please enable them from Settings."),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }

  bool get isGuest => currentUser == null;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final theme = Theme.of(context);

    // Filter tasks based on category & search
    List<Task> tasks = provider.tasks;
    if (selectedCategory == "To-Do") tasks = tasks.where((t) => !t.isCompleted).toList();
    if (selectedCategory == "Completed") tasks = tasks.where((t) => t.isCompleted).toList();
    if (searchQuery.isNotEmpty) {
      tasks = tasks.where(
          (t) => t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    int completed = provider.tasks.where((t) => t.isCompleted).length;
    double progress = provider.tasks.isEmpty ? 0 : completed / provider.tasks.length;
    int streak = provider.streak;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B4EFF), Color(0xFF8A65FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App title + email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TaskTrek",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white24, borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          isGuest ? "Guest" : currentUser!.email ?? "User",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  // Right icons
                  Row(
                    children: [
                      // Theme toggle
                      IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                      ),

                      // Profile avatar
                      if (!isGuest)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: _getAvatar(profileProvider),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Progress + Streak
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Monthly Progress",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary)),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: theme.dividerColor,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text("${(progress * 100).toInt()}% completed",
                            style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall!.color)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.whatshot, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("$streak-Day Streak",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Search bar
                  TextField(
                    style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                    decoration: InputDecoration(
                      hintText: "Search tasks...",
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                  SizedBox(height: 10),

                  // Category Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["All", "To-Do", "Completed"]
                        .map((title) => buildChip(title, theme))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Task List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                  child: TaskCard(
                    task: task,
                    onToggle: () {
                      provider.updateTask(task.copyWith(isCompleted: !task.isCompleted));
                      showSnackBar(
                          context,
                          task.isCompleted
                              ? "Task marked as To-Do!"
                              : "Task marked as Completed!");
                    },
                    onDelete: () {
                      provider.deleteTask(task.id);
                      showSnackBar(context, "Task deleted successfully!");
                    },
                  ),
                );
              },
              childCount: tasks.length,
            ),
          ),

          // Calendar
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverToBoxAdapter(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: DateTime.now(),
                eventLoader: (day) => tasks
                    .where((t) =>
                        t.dateTime.year == day.year &&
                        t.dateTime.month == day.month &&
                        t.dateTime.day == day.day)
                    .toList(),
                calendarStyle: CalendarStyle(
                  todayDecoration:
                      BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  formatButtonVisible: false,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: theme.textTheme.bodyMedium!.color),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium!.color),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildChip(String title, ThemeData theme) {
    bool selected = title == selectedCategory;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
              color: selected ? Colors.white : theme.colorScheme.primary,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  ImageProvider _getAvatar(ProfileProvider profileProvider) {
    if (profileProvider.customImage != null) {
      return FileImage(profileProvider.customImage!);
    } else if (profileProvider.avatarPath != null &&
        profileProvider.avatarPath!.isNotEmpty) {
      return AssetImage(profileProvider.avatarPath!);
    } else {
      return AssetImage('assets/images/default.png');
    }
  }
}
