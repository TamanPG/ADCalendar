import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.black,  //default
    onPrimary: Colors.white,
    secondary: Colors.orange,  //today
    onSecondary: Colors.white,
    tertiary: Color.fromARGB(235, 0, 168, 215),  //selected
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.grey,
    surface: Color.fromARGB(255, 1, 203, 254),
    onSurface: Colors.black,
  ),
);

final darkTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white,  //default
    onPrimary: Colors.black,
    secondary: Colors.orange,  //today
    onSecondary: Colors.black,
    tertiary: Color.fromARGB(255, 1, 203, 254),  //selected
    onTertiary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.black,
    onBackground: Color.fromARGB(255, 192, 192, 192),
    surface: Color.fromARGB(235, 0, 168, 215),
    onSurface: Colors.black,
  ),
);