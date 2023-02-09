import 'package:fr_demo/data/remote/decodable.dart';

class ResponseMessage extends Decodable<ResponseMessage> {
  String? message;
  String? code;
  String? uuid;
  String? entityUid;

  ResponseMessage({this.message, this.uuid});

  ResponseMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? 'No response message from server';
    code = json['code'] ?? '';
    uuid = json['uuid'] ?? '';
    entityUid = json['entityUid'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['code'] = code;
    data['uuid'] = uuid;
    data['entityUid'] = entityUid;
    return data;
  }

  @override
  ResponseMessage decode(data) => ResponseMessage.fromJson(data);
}
