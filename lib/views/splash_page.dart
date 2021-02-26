import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/syougatsu2_mochi.png'),
        ),
      ),
      backgroundColor: Colors.blue,
    );
  }
}
