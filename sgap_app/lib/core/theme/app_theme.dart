import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// S-GAP Application Theme
///
/// Design principles:
/// - Large 18sp body text for readability (informal workers)
/// - All text scales up 20% for accessibility
/// - Poppins (English) + Noto Sans Devanagari (Hindi)
/// - Elevated buttons: full width, 56px height, rounded 12px
/// - Dark-first design with orange (#F97316) brand accent
class AppTheme {
  AppTheme._();

  /// Accessibility text scale factor — 20% uplift.
  static const double accessibilityScale = 1.2;

  // ──────────────────────────────────────────
  //  Typography
  // ──────────────────────────────────────────

  static TextTheme _baseTextTheme(Color textPrimary, Color textSecondary) {
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 57 * accessibilityScale,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 45 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 36 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32 * accessibilityScale,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16 * accessibilityScale,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14 * accessibilityScale,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.1,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 18 * accessibilityScale,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16 * accessibilityScale,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 14 * accessibilityScale,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 14 * accessibilityScale,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12 * accessibilityScale,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ──────────────────────────────────────────
  //  Component Themes
  // ──────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
        disabledForegroundColor:
            isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16 * accessibilityScale,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: GoogleFonts.poppins(
          fontSize: 16 * accessibilityScale,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.poppins(
          fontSize: 16 * accessibilityScale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 16 * accessibilityScale,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 16 * accessibilityScale,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
      errorStyle: GoogleFonts.poppins(
        fontSize: 13 * accessibilityScale,
        color: AppColors.error,
      ),
    );
  }

  static CardThemeData _cardTheme(bool isDark) {
    return CardThemeData(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  static AppBarTheme _appBarTheme(bool isDark) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20 * accessibilityScale,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        size: 24,
      ),
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor:
          isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: isDark ? 0 : 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12 * accessibilityScale,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12 * accessibilityScale,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static FloatingActionButtonThemeData _fabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  static ChipThemeData _chipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedColor: AppColors.primarySurface,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14 * accessibilityScale,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // ──────────────────────────────────────────
  //  Dark Theme
  // ──────────────────────────────────────────

  static ThemeData get darkTheme {
    final textTheme = _baseTextTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: _elevatedButtonTheme(true),
      outlinedButtonTheme: _outlinedButtonTheme(true),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(true),
      cardTheme: _cardTheme(true),
      appBarTheme: _appBarTheme(true),
      bottomNavigationBarTheme: _bottomNavTheme(true),
      floatingActionButtonTheme: _fabTheme(),
      chipTheme: _chipTheme(true),
      dividerColor: AppColors.divider,
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
    );
  }

  // ──────────────────────────────────────────
  //  Light Theme
  // ──────────────────────────────────────────

  static ThemeData get lightTheme {
    final textTheme = _baseTextTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: _elevatedButtonTheme(false),
      outlinedButtonTheme: _outlinedButtonTheme(false),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(false),
      cardTheme: _cardTheme(false),
      appBarTheme: _appBarTheme(false),
      bottomNavigationBarTheme: _bottomNavTheme(false),
      floatingActionButtonTheme: _fabTheme(),
      chipTheme: _chipTheme(false),
      dividerColor: AppColors.lightBorder,
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
    );
  }
}
