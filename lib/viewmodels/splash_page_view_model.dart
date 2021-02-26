import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/logger.dart';

final splashPageViewModelProvider = ChangeNotifierProvider((ref) => SplashPageViewModel());

class SplashPageViewModel extends ChangeNotifier {}
