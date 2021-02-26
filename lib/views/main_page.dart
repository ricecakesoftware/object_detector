import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:object_detector/viewmodels/main_page_view_model.dart';

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(title: Text('Object Detector')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              watch(mainPageViewModelProvider).counter.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: watch(mainPageViewModelProvider).increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
    );
  }
}
