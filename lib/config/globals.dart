import 'package:flutter/material.dart';

import '../data/local/preference_utils.dart';

class Globals {
  // static late FlutterSecureStorage secureStorage;

  static GlobalKey<NavigatorState> materialKey = GlobalKey<NavigatorState>();

  static BuildContext get context {
    return materialKey.currentContext!;
  }

  static Future<void> initializeAll() async {
    // Globals.initializeSecureStorage();
    await PreferenceUtils.init();
  }

  static void initializeSecureStorage() {
    // secureStorage = const FlutterSecureStorage();
  }
}
