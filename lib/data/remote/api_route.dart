import 'package:dio/dio.dart';

enum APIType {
  getData,
  uploadFile,
}

class APIRoute implements APIRouteConfigurable {
  final APIType type;
  final String? routeParams;
  final headers = {
    'accept': 'application/json',
    'content-type': 'application/json'
  };

  APIRoute(this.type, {this.routeParams});

  /// Return config of api (method, url, header)
  @override
  RequestOptions? getConfig() {
    switch (type) {
      case APIType.getData:
        return getData();
      default:
        return null;
    }
  }

  RequestOptions getData() {
    return RequestOptions(
      path: '',
      method: APIMethod.get,
    );
  }
}

// ignore: one_member_abstracts
abstract class APIRouteConfigurable {
  RequestOptions? getConfig();
}

class APIMethod {
  static const get = 'GET';
  static const post = 'POST';
  static const put = 'PUT';
  static const patch = 'PATCH';
  static const delete = 'DELETE';
}
