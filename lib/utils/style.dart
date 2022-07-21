import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StyleManager extends ChangeNotifier {
  /// Change theme in the local storage.
  Future<void> setTheme(ThemeMode theme) async {
    var box = await Hive.openBox('style');
    await box.put('theme', theme == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<ThemeMode?> getTheme() async {
    var box = await Hive.openBox('style');

    String? themeString = await box.get('theme');

    if (themeString == null) {
      return null;
    }

    return themeString == 'light' ? ThemeMode.light : ThemeMode.dark;
  }
}
