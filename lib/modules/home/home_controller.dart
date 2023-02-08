import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fr_demo/utils/app_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

import '../../data/remote/remote_service.dart';
import '../../utils/app_constants.dart';
import '../components/progress_bar/progress_controller.dart';

class HomeController extends GetxController {
  RemoteService remoteService = Get.find();

  Future<bool> uploadFile(String filePath, Position? position) async {
    final isExists = await AppUtils.isNetworkAvailable();
    if (!isExists) {
      AppUtils.showToast(AppConstants.noInternet);
      return false;
    }
    try {
      ProgressController.showLoader();
      /* var fileSize = await AppUtils.getFileSize(filePath, 1);
      if (fileSize.isNotEmpty) {
        final splits = fileSize.toString().split(' ');
        final size = splits[0];
        final suffix = splits[1];
        if (suffix != 'B' && suffix != 'KB' && double.parse(size) > 25) {
          AppUtils.showToast('File size should not be more than 25 MB');
          return false;
        }
      } */
      var latitude = position?.latitude;
      var longitude = position?.longitude;
      var request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.baseUrl}/upload'));
      request.fields.addAll({
        'lat': '$latitude',
        'lng': '$longitude',
      });
      debugPrint(request.url.toString());
      return upload(request, filePath);
    } catch (e) {
      ProgressController.hideLoader();
      AppUtils.showToast('${AppConstants.somethingWentWrong}, ${e.toString()}');
    }
    return false;
  }

  Future<bool> upload(http.MultipartRequest request, String filePath) async {
    try {
      debugPrint('filePath: $filePath');
      var fileExtension = AppUtils.getFileExtension(filePath);
      if (fileExtension.isEmpty) {
        AppUtils.showToast('File extension was not found');
        return false;
      }
      final file = await http.MultipartFile.fromPath('file', filePath,
          contentType: MediaType('application', fileExtension));
      request.files.add(file);
      var res = await request.send();

      if (res.statusCode == 200) {
        final respString = await res.stream.bytesToString();
        debugPrint('respString: $respString');
        AppUtils.showToast(AppConstants.fileUploadSuccess);
        try {
          final file = File(filePath);
          await file.delete();
          return true;
        } catch (e) {
          ProgressController.hideLoader();
          e.printError();
        }
      } else {
        AppUtils.showToast(AppConstants.uploadIssue);
      }
      ProgressController.hideLoader();
    } catch (e) {
      ProgressController.hideLoader();
      AppUtils.showToast(AppConstants.uploadIssue);
    }
    return false;
  }
}
