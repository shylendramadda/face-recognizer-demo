import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fr_demo/utils/app_colors.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Position? position;
  static Future<void> launchURL(String url, BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      showSnackBarMessage(context, 'Unable to load this URL');
    }
  }

  static void showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          // const Icon(Icons.favorite_border, color: Colors.deepOrange),
          Text(
            message,
            style: const TextStyle(color: Colors.amber),
          )
        ],
      ),
      duration: const Duration(milliseconds: 2000),
    ));
  }

  static void showToast(String message, {int duration = Toast.lengthShort}) {
    Toast.show(
      message,
      duration: Toast.lengthLong,
      gravity: Toast.center,
      textStyle: const TextStyle(color: AppColors.white),
      backgroundColor: Colors.black,
    );
  }

  static Future<String> getFileSize(String filepath, int decimals) async {
    if (filepath.startsWith("https")) {
      return '';
    }
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static bool isNetworkFile(String filePath) {
    return filePath.isNotEmpty &&
        (filePath.startsWith('http') || filePath.startsWith('https'));
  }

  static Future<bool> isNetworkAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  static String getFileExtension(String filePath) {
    try {
      int index = filePath.lastIndexOf('.');
      return filePath.substring(index + 1);
    } catch (e) {
      return '';
    }
  }

  static bool isSupportedFormat(String path) {
    var filePath = path.toLowerCase();
    return filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.png') ||
        filePath.endsWith('.mp4');
  }

  static String getDate(int myValue) {
    final df = DateFormat('dd-MM-yyyy hh:mm a');
    final date = df.format(DateTime.fromMillisecondsSinceEpoch(myValue));
    debugPrint(date);
    return date;
  }
}
