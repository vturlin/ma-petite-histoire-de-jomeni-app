import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  // ── Fraunces — titres narratifs / labels ──────────────────────────────────
  static TextStyle _f(double size, FontWeight w,
      {bool italic = false, double height = 1.3, Color? color}) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: w,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      color: color ?? AppColors.forestCream,
    );
  }

  // ── Nunito — UI / corps ───────────────────────────────────────────────────
  static TextStyle _n(double size, FontWeight w,
      {double height = 1.4, Color? color}) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: w,
      height: height,
      color: color ?? AppColors.forestCream,
    );
  }

  // Fraunces
  static TextStyle displayLarge  = _f(30, FontWeight.w800, height: 1.15);
  static TextStyle headlineLarge = _f(26, FontWeight.w700, height: 1.2);
  static TextStyle headlineMedium= _f(23, FontWeight.w700, height: 1.25);
  static TextStyle titleSerif    = _f(19, FontWeight.w700, height: 1.3);
  static TextStyle microLabel    = _f(15, FontWeight.w700, italic: true,
      height: 1.2, color: AppColors.forestCream.withValues(alpha: 0.85));

  // Nunito
  static TextStyle titleLarge    = _n(19, FontWeight.w800, height: 1.3);
  static TextStyle titleMedium   = _n(17, FontWeight.w700, height: 1.4);
  static TextStyle bodyLarge     = _n(16, FontWeight.w600, height: 1.55);
  static TextStyle bodyMedium    = _n(15, FontWeight.w600, height: 1.5,
      color: AppColors.inkSoft);
  static TextStyle bodySmall     = _n(14, FontWeight.w600, height: 1.4,
      color: AppColors.inkSoft);
  static TextStyle labelLarge    = _n(15, FontWeight.w700, height: 1.3);
  static TextStyle button        = _n(18, FontWeight.w800, height: 1.2,
      color: AppColors.forestInk);
}
