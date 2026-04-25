import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static TextStyle _base(double size, FontWeight w,
      {double height = 1.4, Color? color}) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: w,
      height: height,
      color: color ?? AppColors.ink,
    );
  }

  static TextStyle displayLarge = _base(32, FontWeight.w800, height: 1.15);
  static TextStyle headlineLarge = _base(26, FontWeight.w700, height: 1.2);
  static TextStyle headlineMedium = _base(22, FontWeight.w700, height: 1.25);
  static TextStyle titleLarge = _base(18, FontWeight.w700, height: 1.3);
  static TextStyle titleMedium = _base(16, FontWeight.w600, height: 1.4);
  static TextStyle bodyLarge = _base(15, FontWeight.w500, height: 1.5);
  static TextStyle bodyMedium =
      _base(14, FontWeight.w500, height: 1.5, color: AppColors.inkSoft);
  static TextStyle bodySmall =
      _base(13, FontWeight.w500, height: 1.4, color: AppColors.inkSoft);
  static TextStyle labelLarge = _base(14, FontWeight.w600, height: 1.3);
  static TextStyle button =
      _base(16, FontWeight.w700, height: 1.2, color: AppColors.accentInk);
}
