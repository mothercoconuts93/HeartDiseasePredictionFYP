import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A4FA0);
  static const Color primaryBright = Color(0xFF0D5BB5);
  static const Color lightBlue = Color(0xFFEAF1FB);
  static const Color background = Color(0xFFF6F7FB);
  static const Color border = Color(0xFFE2E4EA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF1D8A4A);
  static const Color successLight = Color(0xFFDFF3E6);
  static const Color warning = Color(0xFFB5651D);
  static const Color warningLight = Color(0xFFFBE3D0);
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerLight = Color(0xFFFBDCDC);

  // Backwards-compatible aliases for existing UI references.
  static const Color primaryRed = primary;
  static const Color darkRed = primaryBright;
  static const Color lightRed = lightBlue;

  static ThemeData get lightTheme {
    const radius = BorderRadius.all(Radius.circular(12));
    final base = ThemeData(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryBright,
        surface: Colors.white,
        error: danger,
      ),
      textTheme: base.textTheme
          .apply(
            fontFamily: 'monospace',
            bodyColor: textPrimary,
            displayColor: textPrimary,
          )
          .copyWith(
            headlineSmall: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            titleLarge: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            titleMedium: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            bodyMedium: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: textSecondary,
              height: 1.45,
            ),
            labelLarge: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: border)),
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          color: primary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: primary),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: lightBlue,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: textSecondary, fontSize: 12),
        hintStyle: TextStyle(color: Color(0xFF8A8F98), fontSize: 12),
        prefixIconColor: primary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: danger),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: lightBlue,
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: primary)),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: 'monospace',
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}
