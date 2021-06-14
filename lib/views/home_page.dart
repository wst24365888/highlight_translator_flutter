import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight_translator_flutter/models/translator.dart';
import 'package:highlight_translator_flutter/models/mouse_state.dart';
import 'package:highlight_translator_flutter/services/copy_to_clipboard.dart';
import 'package:highlight_translator_flutter/services/get_mouse_state.dart';

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
    final MouseState mouseState = getMouseState();

    if (mouseState != _lastMouseState) {
      debugPrint(mouseState.toString());
      _lastMouseState = mouseState;

      if (mouseState == MouseState.released) {
        copyToClipboard();

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
