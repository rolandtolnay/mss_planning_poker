import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _storageKeyIsDarkMode = 'isDarkMode';

@Injectable()
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _preferences;

  ThemeModeNotifier(this._preferences)
      : super(_preferences.storedThemeMode ?? ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    if (mode.isDarkMode == null) {
      _preferences.remove(_storageKeyIsDarkMode);
    } else {
      _preferences.setBool(_storageKeyIsDarkMode, mode.isDarkMode!);
    }
    state = mode;
  }
}

extension on SharedPreferences {
  ThemeMode? get storedThemeMode {
    final isDarkMode = getBool(_storageKeyIsDarkMode);
    if (isDarkMode == null) return null;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

extension on ThemeMode {
  bool? get isDarkMode {
    switch (this) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      default:
        return null;
    }
  }
}
