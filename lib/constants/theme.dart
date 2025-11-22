import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF6B4EFF),
    scaffoldBackgroundColor: Color(0xFFF4F0FF),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF6B4EFF)),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6B4EFF),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF6B4EFF),
    scaffoldBackgroundColor: Color(0xFF1C1C1C),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6B4EFF),
    ),
  );
}
