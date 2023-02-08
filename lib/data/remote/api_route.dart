import 'package:dio/dio.dart';

enum APIType {
  register,
  sendOtp,
  verifyOtp,
  getVideoTypes,
  getVideos,
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
      case APIType.register:
        return registerUser();
      case APIType.sendOtp:
        return sendOtp();
      case APIType.verifyOtp:
        return validateOtp();
      case APIType.getVideoTypes:
        return getVideoTypes();
      case APIType.getVideos:
        return getVideos();
      case APIType.uploadFile:
        return uploadFile();
      default:
        return null;
    }
  }

  RequestOptions registerUser() {
    return RequestOptions(
      path: '/regusers/create.php',
      method: APIMethod.post,
    );
  }

  RequestOptions sendOtp() {
    return RequestOptions(
      path: '/otp/create.php',
      method: APIMethod.post,
    );
  }

  RequestOptions validateOtp() {
    return RequestOptions(
      path: '/otp/read.php',
      method: APIMethod.post,
    );
  }

  RequestOptions getVideoTypes() {
    return RequestOptions(
      path: '/vidtypes/read.php',
      method: APIMethod.get,
    );
  }

  RequestOptions getVideos() {
    return RequestOptions(
      path: '/videos/getvideos.php',
      method: APIMethod.post,
    );
  }

  RequestOptions uploadFile() {
    return RequestOptions(
      path: '/videos/process.php',
      method: APIMethod.post,
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
