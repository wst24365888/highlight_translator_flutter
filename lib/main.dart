import 'dart:io';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:highlight_translator_flutter/views/home_page.dart';
import 'package:window_size/window_size.dart';
import 'package:win32/win32.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Highlight Translator");
    setWindowMinSize(const Size(960, 540));
    setWindowMaxSize(Size.infinite);
  }

  CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);

  ShellExecute(
    0,
    TEXT('open'),
    TEXT(Directory.current.path + '\\services\\google-translate-backend.exe'),
    nullptr,
    nullptr,
    SW_SHOW,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Highlight Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}
