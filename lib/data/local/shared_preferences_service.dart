import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  static const String _keyThemeMode = "THEME_MODE";

  static SharedPreferencesService? _instance;

  static Future<SharedPreferencesService> get instance async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = SharedPreferencesService._(prefs);
    }
    return _instance!;
  }

  SharedPreferencesService._(this._preferences);

  String? getThemePreference() {
    return _preferences.getString(_keyThemeMode);
  }

  Future<bool> setThemePreference(String themeMode) async {
    return await _preferences.setString(_keyThemeMode, themeMode);
  }
}
