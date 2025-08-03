import 'package:flutter/material.dart';

final ColorScheme mindMateDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF22223B),
  brightness: Brightness.dark,
);

ThemeData mindMateDarkTheme = ThemeData(
  colorScheme: mindMateDarkColorScheme,
  useMaterial3: true,
);