import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/logger.dart';

final mainPageViewModelProvider = ChangeNotifierProvider((ref) => MainPageViewModel());

class MainPageViewModel extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}
