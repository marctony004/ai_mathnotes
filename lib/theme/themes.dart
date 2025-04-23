import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.blueAccent),
  primaryColor: Colors.blueAccent,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
  primaryColor: Colors.deepPurple,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);

final ThemeData gryffindorTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF2B0909), // Deep red
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF740001)), // Gryffindor red
  primaryColor: const Color(0xFFEEBA30), // Gold
  cardColor: const Color(0xFF740001),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFEEBA30), fontFamily: 'Serif'),
    bodyMedium: TextStyle(color: Color(0xFFEEBA30)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFEEBA30)),
);
