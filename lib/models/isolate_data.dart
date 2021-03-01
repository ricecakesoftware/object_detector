import 'package:camera/camera.dart';

class IsolateData {
  final CameraImage cameraImage;
  final int interpreterAddress;
  final List<String> labels;

  IsolateData({
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  });
}
