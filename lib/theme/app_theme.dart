import 'package:flutter/material.dart';

class AppTheme {
  // Aesthetic "Pastel Pink & Gray" Palette
  static const Color pastelPink = Color(0xFFE5B3BB); // Elegant Pastel Pink
  static const Color softGray = Color(0xFFB0BEC5); // Soft Blue-Gray
  static const Color warmPaper = Color(0xFFF5F5F7); // Very Light Gray
  static const Color lightPink = Color(0xFFFFD1DC); // Lighter Pastel Pink
  static const Color charcoal = Color(0xFF424242); // Dark Gray
  static const Color pureWhite = Color(0xFFFFFFFF);

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.apply(
      bodyColor: charcoal,
      displayColor: charcoal,
      fontFamily: 'SF Pro Text', // macOS system font
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: warmPaper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pastelPink,
        primary: pastelPink,
        secondary: softGray,
        surface: warmPaper,
        outline: lightPink,
      ),

      // Fix: Apply GoogleFonts to the base textTheme to ensure consistency
      textTheme: _buildTextTheme(base.textTheme),

      appBarTheme: const AppBarTheme(
        backgroundColor: warmPaper,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: charcoal),
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Text',
        ),
      ),

      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: pastelPink.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelPink,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: pastelPink,
        foregroundColor: pureWhite,
        elevation: 2,
        shape: CircleBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    // Aesthetic Dark Mode: "Midnight & Rose"
    const darkBg = Color(0xFF1C1C1E);
    const darkSurface = Color(0xFF2C2C2E);

    return base.copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pastelPink,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),

      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFEBEBF5),
        displayColor: const Color(0xFFEBEBF5),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Text',
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pastelPink.withValues(alpha: 0.5)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
    );
  }
}
