import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _followSystemTheme = true;

  ThemeMode get themeMode => _themeMode;
  bool get followSystemTheme => _followSystemTheme;
  
  // Get effective brightness based on system or manual setting
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
    // Listen to system theme changes
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_followSystemTheme) {
        notifyListeners();
      }
    };
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('themeMode');
    _followSystemTheme = prefs.getBool('followSystemTheme') ?? true;
    
    if (_followSystemTheme) {
      _themeMode = ThemeMode.system;
    } else if (mode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (mode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode, {bool follow = false}) async {
    _themeMode = mode;
    _followSystemTheme = follow;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    await prefs.setBool('followSystemTheme', follow);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setTheme(ThemeMode.dark, follow: false);
    } else if (_themeMode == ThemeMode.dark) {
      await setTheme(ThemeMode.system, follow: true);
    } else {
      await setTheme(ThemeMode.light, follow: false);
    }
  }
  
  Future<void> enableSystemTheme() async {
    await setTheme(ThemeMode.system, follow: true);
  }
  
  String getThemeStatusText() {
    if (_followSystemTheme) {
      return 'Following System';
    }
    return _themeMode == ThemeMode.light ? 'Light Mode' : 'Dark Mode';
  }
  
  IconData getThemeIcon() {
    if (_followSystemTheme) {
      return Icons.brightness_auto;
    }
    return _themeMode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;
  }
}

