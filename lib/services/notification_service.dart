import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (details) {
      // App opens automatically, nothing to handle for now
    });

    await _requestNotificationPermission();
    await AndroidAlarmManager.initialize();
    tz.initializeTimeZones();

    // Schedule next notification
    await scheduleDailyCatNotification();
  }

  static Future<void> scheduleDailyCatNotification() async {
    final now = DateTime.now();
    final rnd = Random();
    final scheduleDate = DateTime(now.year, now.month, now.day, 6)
        .add(Duration(minutes: rnd.nextInt(6 * 60 - 1))); // between 6 and 11:59

    if (scheduleDate.isBefore(now)) {
      // schedule for next day
      return scheduleDailyCatNotificationTomorrow();
    }

    await AndroidAlarmManager.oneShotAt(scheduleDate, 0, _showNotification);
  }

  static Future<void> scheduleDailyCatNotificationTomorrow() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final rnd = Random();
    final scheduleDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6)
        .add(Duration(minutes: rnd.nextInt(6 * 60 - 1)));
    await AndroidAlarmManager.oneShotAt(scheduleDate, 1, _showNotification);
  }

  static Future<void> _showNotification() async {
    const emojis = ['🐾', '😺', '🧶', '🐈'];
    final emoji = emojis[Random().nextInt(emojis.length)];
    const androidDetails = AndroidNotificationDetails(
        'daily_cat_channel', 'Daily Cat',
        channelDescription: 'Daily cat notification', importance: Importance.max);
    const notifDetails = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(0,
        "$emoji Your Today's Cat", 'Tap to view today\'s cat', notifDetails);
    // schedule next
    await scheduleDailyCatNotificationTomorrow();
  }

  static Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
}
