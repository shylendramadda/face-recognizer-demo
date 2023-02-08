import 'package:fr_demo/data/remote/decodable.dart';

import '../../utils/app_constants.dart';

///A function that creates an object of type [T]

typedef Create<T> = T Function();

///Construct to get object from generic class

abstract class GenericObject<T> {
  Create<Decodable<dynamic>> create;

  GenericObject({required this.create});

  T genericObject(dynamic data) {
    final item = create();
    return item.decode(data);
  }
}

///Construct to wrap response from API.
///
///Used it as return object of APIController to handle any kind of response.

class ResponseWrapper<T> extends GenericObject<T> {
  T? response;

  ResponseWrapper({required Create<Decodable<dynamic>> create})
      : super(create: create);

  factory ResponseWrapper.init(
      {Create<Decodable<dynamic>>? create, dynamic data}) {
    final wrapper = ResponseWrapper<T>(create: create!);
    wrapper.response = wrapper.genericObject(data);
    return wrapper;
  }
}

class APIResponse<T> extends GenericObject<T>
    implements Decodable<APIResponse<T>> {
  String? error;
  T? data;

  APIResponse({required Create<Decodable<dynamic>> create})
      : super(create: create);

  @override
  APIResponse<T> decode(dynamic json) {
    data = genericObject(json);
    return this;
  }
}

class APIListResponse<T> extends GenericObject<T>
    implements Decodable<APIListResponse<T>> {
  List<T>? data;

  APIListResponse({required Create<Decodable<dynamic>> create})
      : super(create: create);

  @override
  APIListResponse<T> decode(dynamic json) {
    data = [];
    json.forEach((item) {
      data?.add(genericObject(item));
    });
    return this;
  }
}

class ErrorResponse implements Exception {
  String? errorCode;
  String? errorSummary;
  ErrorResponse({
    this.errorCode,
    this.errorSummary,
  });

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'] ?? '500';
    errorSummary = json['errorSummary'] ?? AppConstants.somethingWentWrong;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorSummary'] = errorSummary;
    return data;
  }
}

class ErrorCauses {
  String? errorSummary;

  ErrorCauses({this.errorSummary});

  ErrorCauses.fromJson(Map<String, dynamic> json) {
    errorSummary = json['errorSummary'] ?? AppConstants.somethingWentWrong;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorSummary'] = errorSummary;
    return data;
  }

  @override
  String toString() {
    return errorSummary ?? 'Failed to convert message to string.';
  }
}
