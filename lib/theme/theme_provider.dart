import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_constants.dart';

enum ThemeModeOption { light, dark, cyberpunk, gryffindor }

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeConstants.lightTheme;
  ThemeModeOption _mode = ThemeModeOption.light;

  // ✅ Stylus-only drawing mode toggle
  bool _stylusOnlyMode = false;

  ThemeData get currentTheme => _currentTheme;
  ThemeModeOption get currentThemeMode => _mode;
  bool get stylusOnlyMode => _stylusOnlyMode;

  /// ✅ Load saved theme + stylusOnly toggle before app builds
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('themeModeIndex') ?? 0;
    final stylusPref = prefs.getBool('stylusOnlyMode') ?? false;

    _mode = ThemeModeOption.values[savedIndex];
    _stylusOnlyMode = stylusPref;
    _applyTheme(_mode, save: false);
  }

  void setTheme(ThemeModeOption mode) async {
    _mode = mode;
    _applyTheme(mode);
  }

  void _applyTheme(ThemeModeOption mode, {bool save = true}) async {
    switch (mode) {
      case ThemeModeOption.light:
        _currentTheme = ThemeConstants.lightTheme;
        break;
      case ThemeModeOption.dark:
        _currentTheme = ThemeConstants.darkTheme;
        break;
      case ThemeModeOption.cyberpunk:
        _currentTheme = ThemeConstants.cyberpunkTheme;
        break;
      case ThemeModeOption.gryffindor:
        _currentTheme = ThemeConstants.gryffindorTheme;
        break;
    }

    if (save) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeModeIndex', mode.index);
    }

    notifyListeners();
  }

  /// ✅ Update stylus-only toggle & persist it
  void setStylusOnly(bool enabled) async {
    _stylusOnlyMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stylusOnlyMode', enabled);
    notifyListeners();
  }
}
