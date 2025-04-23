import 'package:flutter/material.dart';

class ThemeConstants {
  // 🌑 Dark Theme
  static const inputBorderActive = Color(0xFF00FFD1);
  static const inputBorderInactive = Colors.purpleAccent;
  static const errorRed = Color(0xFFFF1744); // Bright error red


  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurple,
      secondary: Colors.cyanAccent,
      
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white70,
          displayColor: Colors.white,
        ),
  );

  // ☀️ Light Theme
  static final lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.grey.shade100,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple,
      secondary: Colors.orangeAccent,
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black,
        ),
  );

  // 🧪 Cyberpunk Theme
  static const cyberpunkPrimary = Color(0xFF00FFD1);
  static const scaffoldBg = Color(0xFF0F0F1A);
  static const graphBg = Color(0xFF151525);

  static final cyberpunkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: scaffoldBg,
    primaryColor: cyberpunkPrimary,
    colorScheme: ColorScheme.dark(
      primary: cyberpunkPrimary,
      secondary: Colors.deepPurpleAccent,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Orbitron',
          bodyColor: Colors.white70,
          displayColor: Colors.white,
        ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white54),
      border: InputBorder.none,
    ),
  );

  // 🧙 Gryffindor Theme
  static final gryffindorTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1C0A00), // deep maroon
    primaryColor: const Color(0xFF740001), // crimson red
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF740001),
      secondary: const Color(0xFFFFD700), // gold
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Serif',
          bodyColor: const Color(0xFFFFD700),
          displayColor: const Color(0xFFFFD700),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF740001),
      iconTheme: IconThemeData(color: Color(0xFFFFD700)),
    ),
  );
}
