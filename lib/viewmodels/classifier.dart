import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:object_detector/logger.dart';
import 'package:object_detector/models/recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  static const String _modelFileName = 'tflite/detect.tflite';
  static const String _labelFileName = 'tflite/labelmap.txt';
  static const int _inputSize = 300;
  static const double _threshold = 0.6;
  static const int _results = 10;

  Interpreter _interpreter;
  Interpreter get interpreter => _interpreter;
  List<String> _labels;
  List<String> get labels => _labels;

  ImageProcessor _processor;
  List<List<int>> _outputShapes;
  List<TfLiteType> _outputTypes;

  Classifier({Interpreter interpreter, List<String> labels,}) {
    loadModel(interpreter);
    loadLabels(labels);
  }

  Future<void> loadModel(Interpreter interpreter) async {
    try {
      _interpreter = interpreter ?? await Interpreter.fromAsset(
        '$_modelFileName',
        options: InterpreterOptions()..threads = 4,
      );
      List<Tensor> outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      for (Tensor tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } on Exception catch (e) {
      logger.shout(e.toString());
    }
  }

  Future<void> loadLabels(List<String> labels) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels('assets/$_labelFileName');
    } on Exception catch (e) {
      logger.shout(e.toString());
    }
  }

  TensorImage preprocess(TensorImage image) {
    final int padSize = max(image.height, image.width);
    _processor ??= ImageProcessorBuilder()
      .add(ResizeWithCropOrPadOp(padSize, padSize),)
      .add(ResizeOp(_inputSize, _inputSize, ResizeMethod.BILINEAR),)
      .build();
    return _processor.process(image);
  }

  List<Recognition> predict(image_lib.Image image) {
    if (_interpreter == null) {
      return null;
    }

    TensorImage tensor = preprocess(TensorImage.fromImage(image));
    TensorBufferFloat outputLocations = TensorBufferFloat(_outputShapes[0]);
    TensorBufferFloat outputClasses = TensorBufferFloat(_outputShapes[1]);
    TensorBufferFloat outputScores = TensorBufferFloat(_outputShapes[2]);
    TensorBufferFloat numLocations = TensorBufferFloat(_outputShapes[3]);
    List<ByteBuffer> inputs = [tensor.buffer];
    Map<int, ByteBuffer> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };
    _interpreter.runForMultipleInputs(inputs, outputs);

    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: _inputSize,
      width: _inputSize,
    );
    List<Recognition> recognitions = [];
    for (int i = 0; i < min(_results, numLocations.getIntValue(0)); i++) {
      double score = outputScores.getDoubleValue(i);
      if (score > _threshold) {
        int index = outputClasses.getIntValue(i) + 1;
        String label = _labels.elementAt(index);
        Rect rect = _processor.inverseTransformRect(locations[i], image.height, image.width);
        recognitions.add(Recognition(i, label, score, rect));
      }
    }
    return recognitions;
  }
}
