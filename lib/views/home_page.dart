import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

enum MouseState {
  pressed,
  released,
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  MouseState _lastMouseState = MouseState.pressed;

  @override
  void initState() {
    super.initState();

    _captureMouseEvent();
  }

  void _captureMouseEvent() {
    const Duration captureFrameDuration = Duration(milliseconds: 1);

    Timer.periodic(captureFrameDuration, (Timer t) {
      final MouseState keyState = _isMousePressed();

      if (keyState != _lastMouseState) {
        debugPrint(keyState.toString());
        _lastMouseState = keyState;
      }
    });
  }

  MouseState _isMousePressed() {
    final int keyState = GetKeyState(QS_KEY);

    if (keyState == 0 || keyState == 1) {
      return MouseState.released;
    }

    return MouseState.pressed;
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
