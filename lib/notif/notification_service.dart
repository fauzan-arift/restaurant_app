import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> _selectNotificationStream =
      StreamController<String?>.broadcast();

  Stream<String?> get selectNotificationStream =>
      _selectNotificationStream.stream;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        debugPrint('Notification tapped (foreground): $payload');
        if (payload != null && payload.isNotEmpty) {
          _selectNotificationStream.add(payload);
        }
      },
    );

    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> requestPermissions() async {
    await _requestPermissions();
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  Future<bool> canScheduleExactNotifications() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.canScheduleExactNotifications() ??
          false;
    }
    return false;
  }

  Future<void> requestBatteryOptimizationExemption() async {
    try {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting battery optimization exemption: $e');
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'restaurant_reminder',
          'Restaurant Daily Reminder',
          channelDescription: 'Daily reminder for restaurant recommendations',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body, contentTitle: title),
          autoCancel: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    debugPrint('=== Scheduling Daily Notification ===');
    debugPrint('Target time: $hour:$minute');
    debugPrint('Current time: ${DateTime.now()}');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'restaurant_daily_reminder',
          'Restaurant Daily Reminder',
          channelDescription:
              'Daily reminder for restaurant recommendations at specified time',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          styleInformation: BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    debugPrint('Scheduled for: $scheduledTime');

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint('Scheduled with exactAllowWhileIdle');
    } catch (e) {
      debugPrint('exactAllowWhileIdle failed: $e');

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        debugPrint('Scheduled with alarmClock');
      } catch (e2) {
        debugPrint('alarmClock failed: $e2');

        try {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTime,
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexact,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: payload,
          );
          debugPrint('Scheduled with inexact (fallback)');
        } catch (e3) {
          debugPrint('All methods failed: $e3');
          rethrow;
        }
      }
    }

    final pending = await getPendingNotifications();
    debugPrint('Total pending: ${pending.length}');
    for (var notif in pending) {
      debugPrint('- ID: ${notif.id}, Title: ${notif.title}');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Current time: $now');
    debugPrint('Scheduled time: $scheduledDate');
    debugPrint('Timezone: ${tz.local.name}');

    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async {
    return await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
  }

  void dispose() {
    _selectNotificationStream.close();
  }
}
