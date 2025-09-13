import 'package:shared_preferences/shared_preferences.dart';

class ThemeSharedPreferencesService {
  final SharedPreferences _preferences;

  static const String _keyThemeMode = "THEME_MODE";

  static ThemeSharedPreferencesService? _instance;

  static Future<ThemeSharedPreferencesService> get instance async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = ThemeSharedPreferencesService._(prefs);
    }
    return _instance!;
  }

  ThemeSharedPreferencesService._(this._preferences);

  String? getThemePreference() {
    return _preferences.getString(_keyThemeMode);
  }

  Future<bool> setThemePreference(String themeMode) async {
    return await _preferences.setString(_keyThemeMode, themeMode);
  }
}
