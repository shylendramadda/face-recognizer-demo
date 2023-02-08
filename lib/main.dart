import 'package:flutter/material.dart';
import 'package:fr_demo/face_recognizer.dart';

import 'config/globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.initializeAll();
  runApp(const FaceRecognizer());
}
