import 'dart:math';
import 'package:flutter/material.dart';

class Recognition {
  final int _id;
  int get id => _id;
  final String _label;
  String get label => _label;
  final double _score;
  double get score => _score;
  final Rect _location;
  Rect get location => _location;

  Recognition(this._id, this._label, this._score, [this._location]);

  Rect getRenderLocation(Size actualPreviewSize, double pixelRatio) {
    double ratioX = pixelRatio;
    double ratioY = ratioX;
    double transLeft = max(0.1, location.left * ratioX);
    double transTop = max(0.1, location.top * ratioY);
    double transWidth = min(location.width * ratioX, actualPreviewSize.width,);
    double transHeight = min(location.height * ratioY, actualPreviewSize.height,);
    Rect transformedRect = Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }
}
