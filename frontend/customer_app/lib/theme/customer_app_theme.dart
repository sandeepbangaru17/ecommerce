import 'package:flutter/material.dart';

class CustomerAppTheme {
  static const Color canvas = Color(0xFFF7F1E8);
  static const Color surface = Color(0xFFFFFBF5);
  static const Color primary = Color(0xFF123524);
  static const Color secondary = Color(0xFFB8893E);
  static const Color accent = Color(0xFFD7A85D);
  static const Color text = Color(0xFF1F1A17);
  static const Color muted = Color(0xFF736A60);
  static const Color success = Color(0xFF2E7D58);
  static const Color danger = Color(0xFFB34336);

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Georgia',
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        displayMedium: const TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: const TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: const TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          color: text,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          color: muted,
          height: 1.45,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.92),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: secondary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: surface,
          backgroundColor: primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: primary.withValues(alpha: 0.06),
        selectedColor: accent.withValues(alpha: 0.16),
        side: BorderSide.none,
        labelStyle: const TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: const TextStyle(color: surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: primary.withValues(alpha: 0.08),
    );
  }
}
