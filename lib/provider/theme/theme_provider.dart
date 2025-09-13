import 'package:flutter/material.dart';
import 'package:restaurant_app/data/local/theme_shared_preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeSharedPreferencesService? _prefsService;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _prefsService = await ThemeSharedPreferencesService.instance;

    final savedThemeMode = _prefsService?.getThemePreference();

    if (savedThemeMode != null) {
      _themeMode = _getThemeModeFromString(savedThemeMode);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    await _prefsService?.setThemePreference(_getStringFromThemeMode(mode));
  }

  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  ThemeMode _getThemeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
