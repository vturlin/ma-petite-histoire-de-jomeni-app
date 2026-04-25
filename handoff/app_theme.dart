// Jomeni — ThemeData global
//
// Usage dans main.dart :
//   MaterialApp(
//     theme: AppTheme.light(),
//     home: ...
//   )
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent2,
      onPrimary: AppColors.accentInk,
      primaryContainer: AppColors.accent1,
      onPrimaryContainer: AppColors.accentInk,
      secondary: AppColors.sky,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.accentInk,
      tertiary: AppColors.lilac,
      onTertiary: AppColors.ink,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.paper2,
      outline: AppColors.line,
      outlineVariant: AppColors.line2,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: AppText.displayLarge,
        headlineLarge: AppText.headlineLarge,
        headlineMedium: AppText.headlineMedium,
        titleLarge: AppText.titleLarge,
        titleMedium: AppText.titleMedium,
        bodyLarge: AppText.bodyLarge,
        bodyMedium: AppText.bodyMedium,
        bodySmall: AppText.bodySmall,
        labelLarge: AppText.labelLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.titleLarge,
      ),
      // Bouton primaire CTA — accent peach
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent1,
          foregroundColor: AppColors.accentInk,
          minimumSize: const Size.fromHeight(AppSize.ctaMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
          elevation: 0,
        ).copyWith(
          shadowColor: WidgetStateProperty.all(AppColors.shadowWarmStrong),
        ),
      ),
      // Bouton secondaire — fond blanc, bordure
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(AppSize.ctaMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppText.button.copyWith(color: AppColors.ink),
          side: const BorderSide(color: AppColors.line, width: 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        ),
      ),
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.bodyLarge.copyWith(color: AppColors.inkMute),
        border: OutlineInputBorder(
          borderRadius: AppRadius.all(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.line, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.line, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent2, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
    );
  }
}
