import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier that manages the current [ThemeMode] and persists it.
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      state = ThemeMode.dark;
    } else if (value == 'light') {
      state = ThemeMode.light;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Convenience toggle between light ↔ dark.
  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }
}

/// Global provider for the current theme mode.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
