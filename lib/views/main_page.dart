import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/models/recognition.dart';
import 'package:object_detector/viewmodels/detector.dart';

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Object Detector')),
      body: watch(detectorProvider(size)).when(
        data: (detector) => Stack(
          children: [
            CameraView(detector.controller),
            buildBoxes(watch(recognitionsProvider).state, detector.actualPreviewSize, detector.ratio),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(err.toString()),
        ),
      ),
    );
  }

  Widget buildBoxes(
      List<Recognition> recognitions,
      Size actualPreviewSize,
      double ratio,
      ) {
    if (recognitions == null || recognitions.isEmpty) {
      return const SizedBox();
    }
    return Stack(
      children: recognitions.map((result) {
        return BoundingBox(
          result,
          actualPreviewSize,
          ratio,
        );
      }).toList(),
    );
  }
}

class CameraView extends StatelessWidget {
  final CameraController _cameraController;

  const CameraView(this._cameraController);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _cameraController.value.aspectRatio,
      child: CameraPreview(_cameraController),
    );
  }
}

class BoundingBox extends ConsumerWidget {
  final Recognition _result;
  final Size _actualPreviewSize;
  final double _ratio;

  const BoundingBox(this._result, this._actualPreviewSize, this._ratio);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final Rect renderLocation = _result.getRenderLocation(_actualPreviewSize, _ratio);
    return Positioned(
      left: renderLocation.left,
      top: renderLocation.top,
      width: renderLocation.width,
      height: renderLocation.height,
      child: Container(
        width: renderLocation.width,
        height: renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).accentColor,
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: buildBoxLabel(_result, context),
      ),
    );
  }

  /// 認識結果のラベルを表示
  Align buildBoxLabel(Recognition result, BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: FittedBox(
        child: ColoredBox(
          color: Theme.of(context).accentColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.label,
              ),
              Text(
                ' ${result.score.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
