// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:fr_demo/data/models/face_detection.dart';
import 'package:fr_demo/utils/app_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/response_message.dart';
import '../../data/remote/remote_service.dart';
import '../../utils/app_constants.dart';
import '../components/progress_bar/progress_controller.dart';

class HomeController extends GetxController {
  RemoteService remoteService = Get.find();

  Future<bool> uploadFile(String filePath, Position? position) async {
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
      final uuid = const Uuid().v4();
      var request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.baseUrl}/fd/upload/$uuid/image'));
      // request.fields.addAll({
      //   'lat': '$latitude',
      //   'lng': '$longitude',
      // });

      request.headers.addAll({
        "tenantUid": "test",
        "tuid": "test",
        "Authorization": "Basic YWRtaW46YWRtaW4="
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
      String mediaType = 'image';
      if (filePath.endsWith('.mp4')) {
        mediaType = 'video';
      }
      final file = await http.MultipartFile.fromPath('file', filePath,
          contentType: MediaType(mediaType, fileExtension));
      request.files.add(file);
      var res = await request.send();

      if (res.statusCode == 200) {
        final respString = await res.stream.bytesToString();
        debugPrint('respString: $respString');
        // const JsonCodec json = JsonCodec();
        // final ResponseMessage decodedResponse = json.decode(respString);

        AppUtils.showToast(AppConstants.fileUploadSuccess);
        processFile();
        return true;
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

  Future<List<FaceDetection>?> getServerData() async {
    ProgressController.showLoader();
    try {
      List<FaceDetection>? response = await remoteService.getData();
      ProgressController.hideLoader();
      return response;
    } catch (e) {
      ProgressController.hideLoader();
      AppUtils.showToast('${AppConstants.somethingWentWrong}, ${e.toString()}');
    }
    return null;
  }

  Future<void> processFile() async {
    try {
      ResponseMessage? response = await remoteService.processFile();
      if (response != null) {
        AppUtils.showToast(AppConstants.oneMomentPlease);
      }
    } catch (e) {
      AppUtils.showToast('${AppConstants.somethingWentWrong}, ${e.toString()}');
    }
  }
}
