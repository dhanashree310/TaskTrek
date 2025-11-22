import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Cancel a scheduled notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint("Notification cancelled: $id");
  }

  static Future<void> init() async {
    tz.initializeTimeZones();

    // Set local timezone explicitly to IST
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android Initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Request notification permission
    await _requestNotificationPermission();

    // Request exact alarm permission (Android 12+)
    if (Platform.isAndroid) {
      final android = AndroidFlutterLocalNotificationsPlugin();
      await android.requestExactAlarmsPermission();
    }

    debugPrint("Notification service initialized!");
  }

  static Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) openAppSettings();
    }
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskName,
    required DateTime dateTime,
    bool daily = false,
    bool weekly = false,
  }) async {
    // Convert to local time (IST)
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    // Format with intl for correct IST display
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(tzDate);
    print('Scheduled local time (IST): $formattedTime');

    // Determine repeat pattern
    DateTimeComponents? repeat;
    if (daily) repeat = DateTimeComponents.time;
    if (weekly) repeat = DateTimeComponents.dayOfWeekAndTime;

    final messages = [
      "Don't forget your task '$taskName'! 🚀",
      "Hey! '$taskName' is waiting for you! 🎯",
      "Time to complete '$taskName'! 🕒",
      "Reminder: '$taskName' – let's crush it! 💪",
      "Psst… '$taskName' is calling your name! 📣",
      "Oops! '$taskName' is still pending 😅",
      "Heads up! '$taskName' needs attention ⚡",
      "Your mission, should you choose to accept it: '$taskName' 🕵️‍♀️",
      "Don't make me remind you again… '$taskName'! 😎",
      "Alert! '$taskName' is plotting to get done! 🚨",
      "Rise and shine! Time for '$taskName' ☀️",
      "Tick-tock! '$taskName' won't finish itself ⏰",
      "Hey procrastinator! '$taskName' is calling 📞",
      "Let’s get moving! '$taskName' awaits 🏃‍♂️",
      "The force is strong with '$taskName' 💫",
      "Quick! Before it's too late: '$taskName' ⚡",
      "Don't ghost your tasks! '$taskName' 👻",
      "Reminder powered by caffeine: '$taskName' ☕",
      "💡 Lightbulb moment: Time for '$taskName'!",
      "🚀 Blast off to complete '$taskName'!"
    ];

    final randomMessage = (messages..shuffle()).first;

    await _notifications.zonedSchedule(
      id,
      "Task Reminder ⏰",
      randomMessage,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Task Reminders',
          channelDescription: 'Reminders for pending tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeat,
    );

    debugPrint("Reminder scheduled: $taskName at $formattedTime (IST)");
  }
}
