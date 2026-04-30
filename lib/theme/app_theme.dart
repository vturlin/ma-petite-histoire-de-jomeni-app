import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimens.dart';

class AppTheme {
  AppTheme._();

  // ── Aliases de compatibilité ───────────────────────────────────────────────
  static const Color primary    = AppColors.forestGold;
  static const Color secondary  = AppColors.forestLeaf;
  static const Color accent     = AppColors.forestGold;
  static const Color background = AppColors.forestBg1;
  static const Color surface    = AppColors.forestBg2;
  static const Color cardBg     = AppColors.forestBg2;

  static ThemeData get theme => light();

  static ThemeData light() {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.forestGold,
      onPrimary: AppColors.forestInk,
      primaryContainer: AppColors.forestBg2,
      onPrimaryContainer: AppColors.forestCream,
      secondary: AppColors.forestLeaf,
      onSecondary: AppColors.forestInk,
      secondaryContainer: AppColors.forestBg3,
      onSecondaryContainer: AppColors.forestCream,
      tertiary: AppColors.forestGoldLight,
      onTertiary: AppColors.forestInk,
      error: AppColors.forestBerry,
      onError: AppColors.forestCream,
      surface: AppColors.forestBg1,
      onSurface: AppColors.forestCream,
      surfaceContainerHighest: AppColors.forestBg2,
      outline: AppColors.line,
      outlineVariant: AppColors.line2,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.forestBg1,
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
        backgroundColor: AppColors.forestBg1,
        foregroundColor: AppColors.forestCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.titleSerif,
      ),
      // Bouton CTA doré
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGold,
          foregroundColor: AppColors.forestInk,
          minimumSize: const Size.fromHeight(AppSize.ctaMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.all(AppRadius.xl)),
          elevation: 0,
        ).copyWith(
          shadowColor: WidgetStateProperty.all(AppColors.shadowWarmStrong),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.forestCream,
          minimumSize: const Size.fromHeight(AppSize.ctaMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppText.button.copyWith(color: AppColors.forestCream),
          side: BorderSide(
              color: AppColors.forestCream.withValues(alpha: 0.35), width: 2),
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.all(AppRadius.xl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.forestBg2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.bodyLarge
            .copyWith(color: AppColors.forestCream.withValues(alpha: 0.4)),
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
          borderSide:
              const BorderSide(color: AppColors.forestGold, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.forestBg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.all(AppRadius.xl)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.line, thickness: 1),
      iconTheme: const IconThemeData(
          color: AppColors.forestCream, size: 22),
    );
  }
}
