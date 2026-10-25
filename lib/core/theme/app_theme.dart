import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Palette (Soft & Calm)
  static const Color backgroundLight = Color(0xFFF6F8F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6EAEF);

  // Dark Theme Palette (POCO F7 AMOLED Optimized)
  static const Color backgroundDark = Color(0xFF0F1215);
  static const Color surfaceDark = Color(0xFF161B20);
  static const Color cardDark = Color(0xFF1D232A);
  static const Color borderDark = Color(0xFF28303A);

  // Sage Green (Aksen Tugas Selesai & Tanggal Kalender Aktif)
  static const Color sagePrimary = Color(0xFF6B8F71);
  static const Color sageLight = Color(0xFFEAF2EC);
  static const Color sageDarkContainer = Color(0xFF1E2D22);
  static const Color sageAccent = Color(0xFF82A688);
  static const Color sageDot = Color(0xFF6B8F71);

  // Sand / Warm Beige (Aksen Tugas Sedang Dikerjakan)
  static const Color sandPrimary = Color(0xFFC48B5E);
  static const Color sandLight = Color(0xFFFBF4ED);
  static const Color sandDarkContainer = Color(0xFF33271D);
  static const Color sandAccent = Color(0xFFD4A373);

  // Soft Slate (Aksen Tugas Harus Dikerjakan)
  static const Color slatePrimary = Color(0xFF5A6E82);
  static const Color slateLight = Color(0xFFF0F4F8);
  static const Color slateDarkContainer = Color(0xFF1D2631);
  static const Color slateAccent = Color(0xFF788E9E);

  // Weekend & Pastel Holiday (Muted Red / Pink Pastel - Tidak menyala)
  static const Color weekendPastel = Color(0xFFCF7B7B);
  static const Color weekendPastelLight = Color(0xFFFAF0F0);
  static const Color weekendPastelDark = Color(0xFF381F1F);

  // Text Colors
  static const Color textDarkPrimary = Color(0xFF1E2630);
  static const Color textDarkSecondary = Color(0xFF606F7B);
  static const Color textDarkTertiary = Color(0xFF9AA5B1);

  static const Color textLightPrimary = Color(0xFFF0F4F8);
  static const Color textLightSecondary = Color(0xFFA0AEC0);
  static const Color textLightTertiary = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.sagePrimary,
        secondary: AppColors.sandPrimary,
        surface: AppColors.surfaceLight,
        error: AppColors.weekendPastel,
        onPrimary: Colors.white,
        onSurface: AppColors.textDarkPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textDarkPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sagePrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        modalBackgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slateLight.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sagePrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textDarkPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textDarkPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: AppColors.textDarkPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textDarkPrimary,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textDarkSecondary,
          fontSize: 13.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.textDarkTertiary,
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.sageAccent,
        secondary: AppColors.sandAccent,
        surface: AppColors.surfaceDark,
        error: AppColors.weekendPastel,
        onPrimary: AppColors.backgroundDark,
        onSurface: AppColors.textLightPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textLightPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textLightPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sageAccent,
        foregroundColor: AppColors.backgroundDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textLightPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textLightPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: AppColors.textLightPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textLightPrimary,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textLightSecondary,
          fontSize: 13.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.textLightTertiary,
          fontSize: 12,
        ),
      ),
    );
  }
}
