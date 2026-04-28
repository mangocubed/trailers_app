import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class Settings {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<bool> getShowWelcome() async {
    final prefs = await _prefs;

    return prefs.getBool(keyShowWelcome) ?? true;
  }

  static Future<void> setShowWelcome(bool value) async {
    final prefs = await _prefs;

    await prefs.setBool(keyShowWelcome, value);
  }
}
