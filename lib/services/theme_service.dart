import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';

  /// Get current theme mode
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _darkTheme; // Default to dark
  }

  /// Set theme mode
  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  /// Check if theme is light
  static Future<bool> isLightTheme() async {
    final theme = await getTheme();
    return theme == _lightTheme;
  }

  /// Toggle between light and dark theme
  static Future<String> toggleTheme() async {
    final currentTheme = await getTheme();
    final newTheme = currentTheme == _lightTheme ? _darkTheme : _lightTheme;
    await setTheme(newTheme);
    return newTheme;
  }
}
