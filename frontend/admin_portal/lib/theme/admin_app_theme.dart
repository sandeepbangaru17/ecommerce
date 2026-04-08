import 'package:flutter/material.dart';

class AdminAppTheme {
  static const Color primaryGreen = Color(0xFF1B5E3B);
  static const Color accentLime = Color(0xFFC8F04A);
  static const Color pageBg = Color(0xFFF5F5F0);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color sidebarBg = Color(0xFF0F3D26);
  static const Color sidebarText = Color(0xFFB8E0C8);
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);

  static const Color primary = primaryGreen;
  static const Color secondary = accentLime;
  static const Color surface = cardBg;
  static const Color surfaceRaised = cardBg;
  static const Color canvas = pageBg;
  static const Color text = textPrimary;
  static const Color muted = textSecondary;

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentLime,
        surface: cardBg,
        error: danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: pageBg,
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          color: textSecondary,
          height: 1.45,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pageBg,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: cardBg,
        selectedColor: primaryGreen,
        side: const BorderSide(color: textSecondary),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryGreen,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: textSecondary.withValues(alpha: 0.2),
    );
  }
}
