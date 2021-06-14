import 'package:highlight_translator_flutter/models/mouse_state.dart';
import 'package:win32/win32.dart';

MouseState getMouseState() {
  final int mouseState = GetKeyState(QS_KEY);

  if (mouseState == 0 || mouseState == 1) {
    return MouseState.released;
  }

  return MouseState.pressed;
}
