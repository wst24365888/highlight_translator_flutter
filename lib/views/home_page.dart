import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    _captureMouseEvent();
  }

  void _captureMouseEvent() {
    const Duration captureFrameDuration = Duration(milliseconds: 1);
    Timer.periodic(captureFrameDuration, (Timer t) {
      debugPrint(_isMousePressed().toString());
    });
  }

  bool _isMousePressed() {
    final int keyState = GetKeyState(QS_KEY);

    if (keyState == 0 || keyState == 1) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
      ),
    );
  }
}
