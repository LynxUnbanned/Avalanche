import 'package:flutter/material.dart';
import 'package:avalanche/core/theme/app_theme_mode.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);
  final AppThemeMode mode;
  final String fontFamily;

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    final ColorScheme scheme = lightColorScheme ??
        ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: const <ThemeExtension<dynamic>>{
        ConnectionButtonTheme.light,
        GlassmorphismTheme.light,
      },
    );
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final ColorScheme scheme = darkColorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.dark,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: fontFamily,
      extensions: const <ThemeExtension<dynamic>>{
        ConnectionButtonTheme.dark,
        GlassmorphismTheme.dark,
      },
    );
  }
}
