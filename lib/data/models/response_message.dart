import 'package:fr_demo/data/remote/decodable.dart';

class ResponseMessage extends Decodable<ResponseMessage> {
  String? message;
  bool? verified;

  ResponseMessage({this.message, this.verified});

  ResponseMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? 'No response message from server';
    verified = json['verified'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['verified'] = verified;
    return data;
  }

  @override
  ResponseMessage decode(data) => ResponseMessage.fromJson(data);
}
