import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/theme/theme_provider.dart';
import 'package:restaurant_app/provider/reminder/reminder_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Tema'),
          const SizedBox(height: 8),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                children: [
                  _buildThemeOption(
                    context,
                    title: 'Tema Terang',
                    icon: Icons.light_mode,
                    isSelected: themeProvider.isLightMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context,
                    title: 'Tema Gelap',
                    icon: Icons.dark_mode,
                    isSelected: themeProvider.isDarkMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context,
                    title: 'Ikuti Sistem',
                    icon: Icons.settings_suggest,
                    isSelected: themeProvider.isSystemMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Notifikasi'),
          const SizedBox(height: 8),
          Consumer<ReminderProvider>(
            builder: (context, reminderProvider, _) {
              return Column(
                children: [
                  _buildReminderToggle(context, reminderProvider),
                  if (reminderProvider.isDailyReminderEnabled) ...[
                    const SizedBox(height: 12),
                    _buildReminderTimeSelector(context, reminderProvider),
                    const SizedBox(height: 12),
                    _buildTestNotificationButton(context, reminderProvider),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? colorScheme.primary : null),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderToggle(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: reminderProvider.isDailyReminderEnabled
                  ? colorScheme.primary
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Restaurant Reminder',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: reminderProvider.isDailyReminderEnabled
                          ? colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(
                    'Dapatkan rekomendasi restoran setiap hari',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: reminderProvider.isDailyReminderEnabled,
              onChanged: (value) {
                reminderProvider.setDailyReminderEnabled(value);
              },
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimeSelector(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showTimePicker(context, reminderProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu Reminder',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      reminderProvider.getFormattedReminderTime(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          await reminderProvider.testNotification();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test notifikasi telah dikirim!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.bug_report,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Test Notifikasi',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.send,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Waktu Reminder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reminderProvider.availableReminderTimes.length,
              itemBuilder: (context, index) {
                final time = reminderProvider.availableReminderTimes[index];
                final isSelected = time == reminderProvider.reminderTime;

                return ListTile(
                  title: Text(
                    _formatTimeForDisplay(time),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    reminderProvider.setReminderTime(time);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimeForDisplay(String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (hour == 0) {
      return '${12}:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour < 12) {
      return '$hour:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour == 12) {
      return '${12}:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
    }
  }
}
