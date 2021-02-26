import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/views/main_page.dart';
import 'package:object_detector/views/splash_page.dart';

class App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
/*
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
              home: SplashPage(),
          );
        } else {
*/
          return MaterialApp(
            title: 'Object Detector',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity
            ),
            home: MainPage(),
          );
/*
        }
      },
    );
*/
  }
}
