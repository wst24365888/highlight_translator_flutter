import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight_translator_flutter/models/translator.dart';
import 'package:highlight_translator_flutter/models/mouse_state.dart';
import 'package:highlight_translator_flutter/services/copy_to_clipboard.dart';
import 'package:highlight_translator_flutter/services/get_mouse_state.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  MouseState _lastMouseState = MouseState.pressed;
  Translator _translator = Translator(source: "", targetLang: "");

  final LinkedScrollControllerGroup _controllers =
      LinkedScrollControllerGroup();
  ScrollController _sourceWidgetScrollController = ScrollController();
  ScrollController _resultWidgetScrollController = ScrollController();

  bool _isInside = false;

  @override
  void initState() {
    super.initState();
    _sourceWidgetScrollController = _controllers.addAndGet();
    _resultWidgetScrollController = _controllers.addAndGet();

    _captureMouseEvent();
  }

  @override
  void dispose() {
    _sourceWidgetScrollController.dispose();
    _resultWidgetScrollController.dispose();

    super.dispose();
  }

  void _captureMouseEvent() {
    const Duration captureFrameDuration = Duration(milliseconds: 10);

    Timer.periodic(captureFrameDuration, (Timer t) {
      _update();
    });
  }

  void _onEnter(_) {
    _isInside = true;
  }

  void _onExit(_) {
    _isInside = false;
  }

  void _update() async {
    final MouseState mouseState = getMouseState();

    if (mouseState != _lastMouseState) {
      debugPrint(mouseState.toString());
      _lastMouseState = mouseState;

      if (mouseState == MouseState.released) {
        if (_isInside) {
          return;
        }

        copyToClipboard();

        sleep(const Duration(milliseconds: 10));

        try {
          ClipboardData? clipboardData =
              await Clipboard.getData(Clipboard.kTextPlain);

          Translator translator = Translator(
              source: clipboardData!.text ?? "", targetLang: "zh-TW");

          setState(() {
            _translator = translator;
          });

          await translator.translate();

          setState(() {
            _translator = translator;
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
      body: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey[200],
                  ),
                  child: SingleChildScrollView(
                    controller: _sourceWidgetScrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "SOURCE",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: SelectableText(
                            _translator.source,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey[200],
                  ),
                  child: SingleChildScrollView(
                    controller: _resultWidgetScrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "RESULT",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: (_translator.result?.isEmpty ?? true)
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[600] ?? Colors.black,
                                  highlightColor:
                                      Colors.grey[100] ?? Colors.black,
                                  // See: https://github.com/hnvn/flutter_shimmer/issues/47
                                  enabled: _translator.result?.isEmpty ?? true,
                                  child: const SelectableText(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              : SelectableText(
                                  _translator.result ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
