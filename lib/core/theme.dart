import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SannidhiTheme {
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkCard = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color teal = Color(0xFF0D9488); // Teal 600
  static const Color tealLight = Color(0xFF14B8A6); // Teal 500
  static const Color tealDark = Color(0xFF0F766E); // Teal 700
  static const Color iceBlue = Color(0xFF0EA5E9); // Sky 500
  static const Color iceBlueLight = Color(0xFFE0F2FE); // Sky 100
  
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: teal,
      scaffoldBackgroundColor: lightBg,
      cardTheme: CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      colorScheme: ColorScheme.light(
        primary: teal,
        secondary: iceBlue,
        background: lightBg,
        surface: lightCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textDark,
        onSurface: textDark,
        outline: lightBorder,
      ),
      hoverColor: iceBlueLight.withOpacity(0.4),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: teal,
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      colorScheme: ColorScheme.dark(
        primary: teal,
        secondary: iceBlue,
        background: darkBg,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textLight,
        onSurface: textLight,
        outline: darkBorder,
      ),
      hoverColor: darkBorder.withOpacity(0.4),
    );
  }
}
