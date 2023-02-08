import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  PreferenceUtils._();

  static Future<SharedPreferences> get _instance async =>
      _sharedPreferences ??= await SharedPreferences.getInstance();
  static SharedPreferences? _sharedPreferences;

  static Future<SharedPreferences?> init() async {
    return _instance;
  }

  static String? getString(String key, {String? defaultValue}) {
    return _sharedPreferences?.getString(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) async {
    final preference = await _instance;
    return preference.setString(key, value);
  }

  static bool? getBool(String key, {bool? defaultValue}) {
    return _sharedPreferences?.getBool(key) ?? defaultValue;
  }

  static Future<bool> setBool(String key, {required bool value}) async {
    final preference = await _instance;
    return preference.setBool(key, value);
  }
}
