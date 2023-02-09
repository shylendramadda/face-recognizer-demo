import 'package:fr_demo/data/remote/decodable.dart';

class FaceDetection extends Decodable<FaceDetection> {
  String? name;
  String? brief;
  String? uuid;
  String? filePath;
  int? faceDetectedOn;

  FaceDetection({this.name, this.brief});

  FaceDetection.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    brief = json['brief'] ?? '';
    uuid = json['uuid'] ?? '';
    filePath = json['filePath'] ?? '';
    faceDetectedOn = json['faceDetectedOn'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['brief'] = brief;
    data['uuid'] = uuid;
    data['filePath'] = filePath;
    data['faceDetectedOn'] = faceDetectedOn;
    return data;
  }

  @override
  FaceDetection decode(data) => FaceDetection.fromJson(data);
}
