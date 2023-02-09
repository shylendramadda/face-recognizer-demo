import 'package:dio/dio.dart';
import 'package:fr_demo/data/remote/log_interceptor.dart';
import 'package:fr_demo/modules/components/progress_bar/progress_controller.dart';

import '../../utils/app_constants.dart';
import 'api_response.dart';
import 'api_route.dart';
import 'decodable.dart';

class APIClient {
  late BaseOptions options;
  late Dio instance;

  APIClient({BaseOptions? options}) {
    this.options = options ?? BaseOptions(baseUrl: AppConstants.baseUrl);
    instance = Dio(options);
    final interceptors = [
      APILogInterceptor(),
    ];
    instance.interceptors.addAll(interceptors);
  }

  void setBaseUrl(String baseUrl) {
    options.baseUrl = baseUrl;
  }

  Future<ResponseWrapper<T>> request<T extends Decodable<dynamic>>({
    required APIRouteConfigurable route,
    required Create<T> create,
    dynamic data,
  }) async {
    final config = route.getConfig();
    config?.headers.addAll({
      "tenantUid": "test",
      "tuid": "test",
      "Authorization": "Basic YWRtaW46YWRtaW4="
    });
    if (config == null) {
      throw ErrorResponse(errorSummary: AppConstants.requestFailed);
    }
    config.baseUrl = options.baseUrl;

    if (data != null) {
      config.method == APIMethod.get
          ? config.queryParameters = data
          : config.data = data;
    }
    try {
      final response = await instance.fetch(config);
      return ResponseWrapper.init(create: create, data: response.data);
    } on DioError catch (err) {
      ProgressController.showLoader();
      if (err.response != null) {
        throw ErrorResponse.fromJson(err.response?.data);
      } else {
        throw ErrorResponse(errorSummary: AppConstants.somethingWentWrong);
      }
    }
  }
}
