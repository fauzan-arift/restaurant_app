import 'package:flutter/foundation.dart';
import '../../notif/background_service.dart';
import '../../notif/notification_service.dart';
import '../../data/local/notification_shared_preferences_service.dart';
import 'dart:convert';

class ReminderProvider with ChangeNotifier {
  final NotificationSharedPreferencesService _prefsService =
      NotificationSharedPreferencesService();

  bool _isDailyReminderEnabled = false;
  String _reminderTime = '11:00';

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  String get reminderTime => _reminderTime;

  ReminderProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _isDailyReminderEnabled = await _prefsService.isDailyReminderEnabled();
      _reminderTime = await _prefsService.getReminderTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    try {
      if (enabled) {
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.requestPermissions();

        final permissionStatus = await getPermissionStatus();
        if (permissionStatus['allPermissionsGranted'] != true) {
          debugPrint('Permissions not granted. Cannot enable daily reminder.');
          return;
        }
      }

      await _prefsService.setDailyReminderEnabled(enabled);
      _isDailyReminderEnabled = enabled;

      if (enabled) {
        await _enableDailyReminder();
      } else {
        await _disableDailyReminder();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting daily reminder: $e');
    }
  }

  Future<void> setReminderTime(String time) async {
    try {
      await _prefsService.setReminderTime(time);
      _reminderTime = time;

      if (_isDailyReminderEnabled) {
        await _disableDailyReminder();
        await _enableDailyReminder();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting reminder time: $e');
    }
  }

  Future<void> _enableDailyReminder() async {
    try {
      final timeParts = _reminderTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final notificationService = NotificationService();
      await notificationService.initialize();

      debugPrint('Fetching fresh restaurant data for daily reminder...');
      final restaurant = await BackgroundService.fetchRandomRestaurant();

      String title = '🍽️ Daily Restaurant Reminder';
      String body = 'Saatnya makan! Lihat rekomendasi restoran hari ini.';
      String? payload;

      if (restaurant != null) {
        final restaurantName = restaurant['name'] ?? 'Restoran Pilihan';
        final city = restaurant['city'] ?? '';
        final rating = restaurant['rating']?.toString() ?? '';

        body = 'Saatnya makan! ';
        if (city.isNotEmpty) {
          body += 'Coba "$restaurantName" di $city';
        } else {
          body += 'Coba "$restaurantName"';
        }

        if (rating.isNotEmpty) {
          body += ' (Rating: $rating⭐)';
        }

        payload = json.encode(restaurant);
        debugPrint('Daily reminder scheduled with restaurant: $restaurantName');
      } else {
        debugPrint(
          'Daily reminder scheduled with fallback message - API failed',
        );
      }

      await notificationService.scheduleDailyNotification(
        id: 1,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: payload,
      );

      await BackgroundService.registerDailyReminder();

      debugPrint(
        'Daily reminder enabled for $hour:${minute.toString().padLeft(2, '0')} with fresh data + background service',
      );
    } catch (e) {
      debugPrint('Error enabling daily reminder: $e');
    }
  }

  Future<void> _disableDailyReminder() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.cancelNotification(1);

      debugPrint('Daily reminder disabled');
    } catch (e) {
      debugPrint('Error disabling daily reminder: $e');
    }
  }

  Future<void> testNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final restaurant = await BackgroundService.fetchRandomRestaurant();

      if (restaurant != null) {
        final restaurantName = restaurant['name'] ?? 'Restoran Pilihan';
        final city = restaurant['city'] ?? '';
        final rating = restaurant['rating']?.toString() ?? '';

        String notificationBody = 'Saatnya makan! ';
        if (city.isNotEmpty) {
          notificationBody += 'Coba "$restaurantName" di $city';
        } else {
          notificationBody += 'Coba "$restaurantName"';
        }

        if (rating.isNotEmpty) {
          notificationBody += ' (Rating: $rating⭐)';
        }

        await notificationService.showInstantNotification(
          id: 999,
          title: '🍽️ Daily Restaurant Reminder',
          body: notificationBody,
          payload: json.encode(restaurant),
        );
      } else {
        await notificationService.showInstantNotification(
          id: 999,
          title: '🍽️ Daily Restaurant Reminder',
          body: 'Saatnya makan! Jangan lupa untuk makan yang bergizi.',
        );
      }
    } catch (e) {
      debugPrint('Error testing notification: $e');

      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.showInstantNotification(
          id: 999,
          title: '🍽️ Daily Restaurant Reminder',
          body: 'Saatnya makan! Jangan lupa untuk makan yang bergizi.',
        );
      } catch (fallbackError) {
        debugPrint('Error in fallback notification: $fallbackError');
      }
    }
  }

  Future<Map<String, dynamic>> getPermissionStatus() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final notificationsEnabled = await notificationService
          .areNotificationsEnabled();
      final exactAlarmEnabled = await notificationService
          .canScheduleExactNotifications();

      return {
        'notifications': notificationsEnabled,
        'exactAlarm': exactAlarmEnabled,
        'allPermissionsGranted': notificationsEnabled && exactAlarmEnabled,
      };
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return {
        'notifications': false,
        'exactAlarm': false,
        'allPermissionsGranted': false,
        'error': e.toString(),
      };
    }
  }

  List<String> get availableReminderTimes =>
      _prefsService.getAvailableReminderTimes();

  String getFormattedReminderTime() {
    return _prefsService.formatTimeForDisplay(_reminderTime);
  }
}
