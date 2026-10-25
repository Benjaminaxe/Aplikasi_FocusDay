import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      // Create Android Notification Channel
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        const channel = AndroidNotificationChannel(
          'focusday_reminders',
          'Pengingat Tugas FocusDay',
          description: 'Notifikasi pengingat waktu tugas jadwal harian',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await androidImpl?.createNotificationChannel(channel);
        await androidImpl?.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e, stack) {
      debugPrint('NotificationService init error: $e\n$stack');
    }
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // If scheduled time is in the past, do not schedule
      if (scheduledDateTime.isBefore(DateTime.now())) {
        debugPrint('Scheduled time $scheduledDateTime is in the past; skipping.');
        return;
      }

      final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

      // Generate a stable 31-bit integer notification ID from task ID string
      final int notificationId = taskId.hashCode.abs() % 100000;

      const androidDetails = AndroidNotificationDetails(
        'focusday_reminders',
        'Pengingat Tugas FocusDay',
        channelDescription: 'Notifikasi pengingat waktu tugas jadwal harian',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: '⏰ FocusDay: $title',
        body: body.isEmpty ? 'Waktunya mengerjakan tugas Anda.' : body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: taskId,
      );

      debugPrint('Notification scheduled for $title at $tzDateTime (id: $notificationId)');
    } catch (e, stack) {
      debugPrint('Error scheduling notification: $e\n$stack');
    }
  }

  Future<void> cancelReminder(String taskId) async {
    if (!_isInitialized) return;
    try {
      final int notificationId = taskId.hashCode.abs() % 100000;
      await _notifications.cancel(id: notificationId);
      debugPrint('Cancelled notification for id: $notificationId');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
