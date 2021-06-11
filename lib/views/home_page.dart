import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

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
      final MouseState mouseState = _isMousePressed();

      if (mouseState != _lastMouseState) {
        debugPrint(mouseState.toString());
        _lastMouseState = mouseState;

        if (mouseState == MouseState.released) {
          _copyToClipboard();
        }
      }
    });
  }

  void _copyToClipboard() {
    // Ctrl+C

    final Pointer<INPUT> kbd = calloc<INPUT>();

    kbd.ref.type = INPUT_KEYBOARD;

    kbd.ki.wVk = 0x11;
    SendInput(1, kbd, sizeOf<INPUT>());

    kbd.ki.wVk = 0x43;
    SendInput(1, kbd, sizeOf<INPUT>());

    kbd.ki.wVk = 0x11;
    kbd.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, kbd, sizeOf<INPUT>());

    kbd.ki.wVk = 0x43;
    kbd.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, kbd, sizeOf<INPUT>());

    free(kbd);
  }

  MouseState _isMousePressed() {
    final int mouseState = GetKeyState(QS_KEY);

    if (mouseState == 0 || mouseState == 1) {
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
