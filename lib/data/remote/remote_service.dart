import 'package:dio/dio.dart' as dio;
import 'package:fr_demo/data/remote/api_client.dart';
import 'package:fr_demo/data/remote/api_response.dart';
import 'package:fr_demo/data/remote/api_route.dart';
import 'package:get/get.dart';

import '../models/response_message.dart';

class RemoteService extends GetxService {
  final apiClient = APIClient();

  Future<ResponseMessage?> doRegister(dio.FormData data) async {
    final result = await apiClient.request(
      route: APIRoute(APIType.register),
      create: () =>
          APIResponse<ResponseMessage>(create: () => ResponseMessage()),
      data: data,
    );
    final ResponseMessage? responseMessage = result.response?.data;
    return responseMessage;
  }
}
