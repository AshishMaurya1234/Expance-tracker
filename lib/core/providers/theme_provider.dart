import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String themeKey = "IS_DARK_MODE";

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(themeKey) ?? false;

    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = value;

    await prefs.setBool(themeKey, value);

    notifyListeners();
  }
}