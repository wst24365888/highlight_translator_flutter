import 'dart:ffi';

import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

void copyToClipboard() {
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
