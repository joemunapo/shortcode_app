import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const _ink = Color(0xFF14222B);
  static const _paper = Color(0xFFF5F8F6);
  static const _emerald = Color(0xFF009B8B);
  static const _cyan = Color(0xFF0EA5E9);
  static const _lime = Color(0xFFD4F45F);

  static const systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: _paper,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _emerald,
      brightness: Brightness.light,
      primary: _emerald,
      secondary: _lime,
      surface: Colors.white,
      error: const Color(0xFFDC2626),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _paper,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _ink,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 0.98,
        ),
        titleLarge: TextStyle(
          color: _ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: _ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: _ink, fontSize: 16, height: 1.35),
        bodyMedium: TextStyle(color: Color(0xFF586660), height: 1.35),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F5F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class AppColors {
  static const ink = Color(0xFF14222B);
  static const mutedInk = Color(0xFF586660);
  static const emerald = Color(0xFF009B8B);
  static const cyan = Color(0xFF0EA5E9);
  static const lime = Color(0xFFD4F45F);
  static const surfaceTint = Color(0xFFF0F5F2);
}
