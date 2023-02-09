import 'package:fr_demo/data/models/face_detection.dart';
import 'package:fr_demo/data/models/response_message.dart';
import 'package:fr_demo/data/remote/api_client.dart';
import 'package:fr_demo/data/remote/api_response.dart';
import 'package:fr_demo/data/remote/api_route.dart';
import 'package:fr_demo/utils/app_constants.dart';
import 'package:fr_demo/utils/app_utils.dart';
import 'package:get/get.dart';

class RemoteService extends GetxService {
  final apiClient = APIClient();

  Future<List<FaceDetection>?> getData() async {
    apiClient.setBaseUrl(AppConstants.baseUrl);
    // if (await checkNetwork()) {
    if (true) {
      final result = await apiClient.request(
        route: APIRoute(APIType.getData),
        create: () =>
            APIListResponse<FaceDetection>(create: () => FaceDetection()),
      );
      final response = result.response?.data;
      return response;
    } else {
      return null;
    }
  }

  Future<ResponseMessage?> processFile() async {
    apiClient.setBaseUrl(AppConstants.baseUrl);
    final result = await apiClient.request(
      route: APIRoute(APIType.processFile),
      create: () =>
          APIResponse<ResponseMessage>(create: () => ResponseMessage()),
    );
    final response = result.response?.data;
    return response;
  }

  Future<bool> checkNetwork() async {
    final isExists = await AppUtils.isNetworkAvailable();
    if (!isExists) {
      AppUtils.showToast(AppConstants.noInternet);
      return false;
    }
    return true;
  }
}
