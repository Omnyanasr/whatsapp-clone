import 'package:flutter/material.dart';

class AppTheme {
  // WhatsApp-like colors
  static const Color _waGreen = Color(0xFF00A884);
  static const Color _waBgLight = Color(0xFFEFEAE2); // chat bg pattern hue
  static const Color _waBgDark = Color(0xFF0B141A);
  static const Color _waSurfaceDark = Color(0xFF111B21);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _waGreen,
        primary: _waGreen,
        secondary: const Color(0xFF128C7E),
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.black,
        ),
        foregroundColor: Colors.black,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      scaffoldBackgroundColor: _waBgLight,
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _waGreen,
        primary: _waGreen,
        secondary: const Color(0xFF25D366),
        surface: _waSurfaceDark,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1F2C34),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      scaffoldBackgroundColor: _waBgDark,
    );
  }
}
