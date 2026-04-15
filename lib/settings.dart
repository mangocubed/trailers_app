import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

const _unrestrictedConnections = [ConnectivityResult.ethernet, ConnectivityResult.wifi];

enum AutoplayVideos {
  always,
  wifi,
  never;

  String toText() {
    switch (this) {
      case AutoplayVideos.always:
        return 'Always';
      case AutoplayVideos.never:
        return 'Never';
      default:
        return 'Wi-Fi only';
    }
  }

  Future<bool> shouldAutoplay() async {
    if (this == AutoplayVideos.always) {
      return true;
    }

    if (this == AutoplayVideos.never) {
      return false;
    }

    final connectivity = await Connectivity().checkConnectivity();

    return connectivity.any((result) => _unrestrictedConnections.contains(result));
  }
}

class Settings {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<AutoplayVideos> getAutoplayVideos() async {
    final prefs = await _prefs;

    return AutoplayVideos.values.byName(prefs.getString(keyAutoplayVideos) ?? 'wifi');
  }

  static Future<bool> getShowWelcome() async {
    final prefs = await _prefs;

    return prefs.getBool(keyShowWelcome) ?? true;
  }

  static Future<void> setAutoplayVideos(AutoplayVideos value) async {
    final prefs = await _prefs;

    await prefs.setString(keyAutoplayVideos, value.name);
  }

  static Future<void> setShowWelcome(bool value) async {
    final prefs = await _prefs;

    await prefs.setBool(keyShowWelcome, value);
  }
}
