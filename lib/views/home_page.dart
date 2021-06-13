import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight_translator_flutter/models/translator.dart';
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
  String? _result;

  @override
  void initState() {
    super.initState();

    _captureMouseEvent();
  }

  void _captureMouseEvent() {
    const Duration captureFrameDuration = Duration(milliseconds: 10);

    Timer.periodic(captureFrameDuration, (Timer t) {
      _update();
    });
  }

  void _update() async {
    final MouseState mouseState = _isMousePressed();

    if (mouseState != _lastMouseState) {
      debugPrint(mouseState.toString());
      _lastMouseState = mouseState;

      if (mouseState == MouseState.released) {
        _copyToClipboard();

        sleep(const Duration(milliseconds: 10));

        try {
          ClipboardData? clipboardData =
              await Clipboard.getData(Clipboard.kTextPlain);

          Translator translator = Translator(
              source: clipboardData!.text ?? "", targetLang: "zh-TW");
          await translator.translate();

          setState(() {
            _result = translator.result ?? "NULL";
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
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
        child: Center(
          child: Text(
            _result ?? "NULL",
            style: const TextStyle(
              fontSize: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
