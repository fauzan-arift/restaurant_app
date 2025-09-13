import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import '../data/local/notification_shared_preferences_service.dart';

class BackgroundService {
  static const String dailyReminderTask = 'dailyReminderTask';
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    debugPrint('Workmanager initialized');
  }

  static Future<void> registerDailyReminder() async {
    await Workmanager().cancelByUniqueName(dailyReminderTask);

    final delay = await _calculateInitialDelay();

    await Workmanager().registerPeriodicTask(
      dailyReminderTask,
      dailyReminderTask,
      frequency: const Duration(hours: 24),
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
    debugPrint('Daily reminder registered with initial delay: $delay');
  }

  static Future<Duration> _calculateInitialDelay() async {
    try {
      final prefsService = NotificationSharedPreferencesService();
      final reminderTime = await prefsService.getReminderTime();
      final timeParts = reminderTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      final targetTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (now.isAfter(targetTime)) {
        final tomorrow = targetTime.add(const Duration(days: 1));
        return tomorrow.difference(now);
      } else {
        return targetTime.difference(now);
      }
    } catch (e) {
      debugPrint('Error calculating delay, using default 11:00: $e');
      final now = DateTime.now();
      final targetTime = DateTime(now.year, now.month, now.day, 11, 0);
      if (now.isAfter(targetTime)) {
        final tomorrow = targetTime.add(const Duration(days: 1));
        return tomorrow.difference(now);
      } else {
        return targetTime.difference(now);
      }
    }
  }

  static Future<void> cancelDailyReminder() async {
    await Workmanager().cancelByUniqueName(dailyReminderTask);
  }

  static Future<Map<String, dynamic>?> fetchRandomRestaurant() async {
    debugPrint('Background: Starting fetchRandomRestaurant');
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/list'))
          .timeout(const Duration(seconds: 15));

      debugPrint('Background: HTTP response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Background: Parsed data error: ${data['error']}');

        if (data['error'] == false && data['restaurants'] != null) {
          final restaurants = data['restaurants'] as List;
          debugPrint('Background: Found ${restaurants.length} restaurants');

          if (restaurants.isNotEmpty) {
            final random = Random();
            final selectedRestaurant =
                restaurants[random.nextInt(restaurants.length)];
            debugPrint(
              'Background: Selected restaurant: ${selectedRestaurant['name']}',
            );
            return selectedRestaurant;
          }
        }
      }
    } catch (e) {
      debugPrint('Background: Error fetching restaurant: $e');
    }
    debugPrint('Background: Returning null restaurant');
    return null;
  }

  static Map<String, String> _formatRestaurantNotification(
    Map<String, dynamic> restaurant,
  ) {
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

    return {'title': '🍽️ Daily Restaurant Reminder', 'body': notificationBody};
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == BackgroundService.dailyReminderTask) {
        debugPrint('Background: Daily reminder task started');

        final prefsService = NotificationSharedPreferencesService();
        final isDailyReminderEnabled = await prefsService
            .isDailyReminderEnabled();

        debugPrint(
          'Background: Daily reminder enabled: $isDailyReminderEnabled',
        );

        if (!isDailyReminderEnabled) {
          debugPrint('Background: Daily reminder disabled, skipping');
          return Future.value(true);
        }

        final notificationService = NotificationService();
        await notificationService.initialize();
        debugPrint('Background: Notification service initialized');

        await notificationService.cancelNotification(1);
        debugPrint('Background: Cancelled existing scheduled notification');

        final restaurant = await BackgroundService.fetchRandomRestaurant();

        final reminderTime = await prefsService.getReminderTime();
        final timeParts = reminderTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        String title = '🍽️ Daily Restaurant Reminder';
        String body = 'Saatnya makan! Lihat rekomendasi restoran hari ini.';
        String? payload;

        if (restaurant != null) {
          final notificationData =
              BackgroundService._formatRestaurantNotification(restaurant);
          title = notificationData['title']!;
          body = notificationData['body']!;
          payload = json.encode({'id': restaurant['id']});
          debugPrint(
            'Background: Got fresh restaurant data: ${restaurant['name']}',
          );
        } else {
          debugPrint('Background: No restaurant data, using fallback');
        }

        await notificationService.scheduleDailyNotification(
          id: 1,
          title: title,
          body: body,
          hour: hour,
          minute: minute,
          payload: payload,
        );

        debugPrint(
          'Background: Rescheduled notification with fresh data for next day',
        );

        return Future.value(true);
      }
    } catch (e) {
      debugPrint('Background task error: $e');
    }

    return Future.value(false);
  });
}
