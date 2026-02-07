/// Avalanche Theme System
/// 
/// Winter-inspired color palette with frosted glass UI
library;

import 'package:flutter/material.dart';

/// Avalanche color palette - winter/ice theme
class AvalancheColors {
  AvalancheColors._();

  // Primary colors
  static const Color iceBlue = Color(0xFF7DD3FC);
  static const Color deepIce = Color(0xFF38BDF8);
  static const Color frostWhite = Color(0xFFF0F9FF);
  
  // Background colors
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color midnightBlue = Color(0xFF1E293B);
  static const Color darkSlate = Color(0xFF334155);
  
  // Accent colors
  static const Color auroraPurple = Color(0xFFA78BFA);
  static const Color auroraGreen = Color(0xFF34D399);
  static const Color snowWhite = Color(0xFFFFFFFF);
  
  // Semantic colors
  static const Color connected = Color(0xFF34D399);
  static const Color disconnected = Color(0xFFF87171);
  static const Color connecting = Color(0xFFFBBF24);
  
  // Frosted glass colors
  static const Color frostedSurface = Color(0xB31E293B); // 70% opacity
  static const Color frostedBorder = Color(0x33FFFFFF);  // 20% opacity white
}

/// Frosted glass decoration constants
class FrostedGlass {
  FrostedGlass._();
  
  static const double blurIntensity = 10.0;
  static const double borderRadius = 16.0;
  static const double borderWidth = 1.0;
  
  static BoxDecoration decoration({
    double radius = borderRadius,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AvalancheColors.frostedSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AvalancheColors.frostedBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

/// Avalanche theme data
class AvalancheTheme {
  AvalancheTheme._();
  
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AvalancheColors.iceBlue,
        secondary: AvalancheColors.auroraPurple,
        surface: AvalancheColors.midnightBlue,
        error: AvalancheColors.disconnected,
        onPrimary: AvalancheColors.deepNavy,
        onSecondary: AvalancheColors.snowWhite,
        onSurface: AvalancheColors.frostWhite,
        onError: AvalancheColors.snowWhite,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: AvalancheColors.frostedSurface,
      dividerColor: AvalancheColors.frostedBorder,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AvalancheColors.frostWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AvalancheColors.frostWhite),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AvalancheColors.frostedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FrostedGlass.borderRadius),
          side: const BorderSide(color: AvalancheColors.frostedBorder),
        ),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        iconColor: AvalancheColors.iceBlue,
        textColor: AvalancheColors.frostWhite,
      ),
      
      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AvalancheColors.iceBlue,
        foregroundColor: AvalancheColors.deepNavy,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AvalancheColors.frostWhite, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AvalancheColors.frostWhite, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AvalancheColors.frostWhite, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(color: AvalancheColors.frostWhite, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AvalancheColors.frostWhite, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: AvalancheColors.frostWhite),
        bodyLarge: TextStyle(color: AvalancheColors.frostWhite),
        bodyMedium: TextStyle(color: AvalancheColors.frostWhite),
        bodySmall: TextStyle(color: Color(0xFFCBD5E1)),
        labelLarge: TextStyle(color: AvalancheColors.iceBlue, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: AvalancheColors.iceBlue),
        labelSmall: TextStyle(color: Color(0xFF94A3B8)),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: AvalancheColors.iceBlue,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AvalancheColors.iceBlue;
          }
          return AvalancheColors.darkSlate;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AvalancheColors.iceBlue.withOpacity(0.3);
          }
          return AvalancheColors.midnightBlue;
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AvalancheColors.iceBlue,
        inactiveTrackColor: AvalancheColors.midnightBlue,
        thumbColor: AvalancheColors.iceBlue,
        overlayColor: AvalancheColors.iceBlue.withOpacity(0.2),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AvalancheColors.iceBlue,
        linearTrackColor: AvalancheColors.midnightBlue,
      ),
    );
  }
}
