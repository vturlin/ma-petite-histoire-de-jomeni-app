// Jomeni — radius, espacements, tailles cibles
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();
  static const xs = 10.0;
  static const sm = 14.0;
  static const md = 18.0;
  static const lg = 22.0;
  static const xl = 26.0;
  static const xxl = 28.0;
  static const pill = 999.0;

  static BorderRadius all(double r) => BorderRadius.circular(r);
}

class AppSpacing {
  AppSpacing._();
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s56 = 56.0;

  /// Padding horizontal standard d'écran
  static const screenH = EdgeInsets.symmetric(horizontal: 20);
}

class AppSize {
  AppSize._();
  static const ctaMinHeight = 56.0;
  static const hitMin = 44.0;
  static const avatarLg = 88.0;
  static const avatarMd = 56.0;
  static const avatarSm = 40.0;
  static const iconBtnTopbar = 38.0;
  static const iconBtnPlay = 78.0;
}

class AppShadows {
  AppShadows._();

  /// Ombre douce sur cards
  static const soft = [
    BoxShadow(
      color: Color(0x14463728),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Ombre marquée sur boutons primaires CTA
  static const cta = [
    BoxShadow(
      color: Color(0x40463728),
      blurRadius: 30,
      spreadRadius: -14,
      offset: Offset(0, 14),
    ),
  ];
}
