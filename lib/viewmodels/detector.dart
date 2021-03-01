import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/models/isolate_data.dart';
import 'package:object_detector/models/recognition.dart';
import 'package:object_detector/viewmodels/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final StateProvider<List<Recognition>> recognitionsProvider = StateProvider<List<Recognition>>((ref) => []);
final detectorProvider = FutureProvider.autoDispose.family<Detector, Size>((ref, size) async {
  final List<CameraDescription> cameras = await availableCameras();
  final CameraController controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
  await controller.initialize();
  return Detector(ref, controller, size);
});

class Detector {
  Size _actualPreviewSize;
  Size get actualPreviewSize => _actualPreviewSize;
  final CameraController _controller;
  CameraController get controller => _controller;
  double _ratio;
  double get ratio => _ratio;

  final ProviderReference _reference;
  final Size _cameraViewSize;
  Classifier _classifier;
  bool _isPredicting = false;

  Detector(this._reference, this._controller, this._cameraViewSize) {
    Future(() async {
      _classifier = Classifier();
      _ratio = Platform.isAndroid ?
      _cameraViewSize.width / _controller.value.previewSize.height :
      _cameraViewSize.width / _controller.value.previewSize.width;
      _actualPreviewSize = Size(_cameraViewSize.width, _cameraViewSize.width * _ratio);
      await _controller.startImageStream(onLatestImageAvailable);
    });
  }

  Future<void> onLatestImageAvailable(CameraImage image) async {
    if (_classifier.interpreter == null && _classifier.labels == null && _isPredicting) {
      return;
    }
    _isPredicting = true;
    final IsolateData data = IsolateData(
      cameraImage: image,
      interpreterAddress: _classifier.interpreter.address,
      labels: _classifier.labels,
    );
    _reference.watch(recognitionsProvider).state = await compute(inference, data);
    _isPredicting = false;
  }

  static Future<List<Recognition>> inference(IsolateData data) async {
    image_lib.Image image = convertYUV420ToImage(data.cameraImage);
    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, 90);
    }
    final Classifier classifier = Classifier(
      interpreter: Interpreter.fromAddress(data.interpreterAddress),
      labels: data.labels,
    );
    return classifier.predict(image);
  }

  static image_lib.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel;
    final image = image_lib.Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = yuv2rgb(y, u, v);
      }
    }

    return image;
  }

  /// Convert a single YUV pixel to RGB
  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255).toInt();
    g = g.clamp(0, 255).toInt();
    b = b.clamp(0, 255).toInt();

    return 0xff000000 |
      ((b << 16) & 0xff0000) |
      ((g << 8) & 0xff00) |
      (r & 0xff);
  }
}
