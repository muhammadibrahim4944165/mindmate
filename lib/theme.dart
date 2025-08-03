import 'package:flutter/material.dart';

final ColorScheme mindMateColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.light,
  primary: const Color(0xFF6750A4),
  secondary: const Color(0xFF4F378B),
  tertiary: const Color(0xFF7D5260),
  background: const Color(0xFFF8F7FC),
  surface: Colors.white,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onTertiary: Colors.white,
  onBackground: Color(0xFF1C1B1F),
  onSurface: Color(0xFF1C1B1F),
);

ThemeData mindMateTheme = ThemeData(
  colorScheme: mindMateColorScheme,
  useMaterial3: true,
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF1C1B1F),
    centerTitle: true,
  ),
);