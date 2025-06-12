import 'package:flutter/material.dart';

final lightTheme = ThemeData(

  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF266DD1)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF266DD1),
    foregroundColor: Colors.white,
  ),
  // Add more default widgets here
  
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF266DD1),
    brightness: Brightness.dark,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.lightBlueAccent),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.lightBlueAccent,
  ),
  // Add more default widgets here
);
