// Jomeni — palette "Forêt enchantée"
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Forêt enchantée ───────────────────────────────────────────────────────
  static const forestBg1      = Color(0xFF1F3A2C); // vert mousse profond — fond
  static const forestBg2      = Color(0xFF2D5240); // vert mousse moyen
  static const forestBg3      = Color(0xFF406854); // vert mousse clair
  static const forestCream    = Color(0xFFF4EBD3); // parchemin
  static const forestGold     = Color(0xFFE8B04A); // or luciole — CTA
  static const forestGoldLight= Color(0xFFF5D287); // or clair — halo
  static const forestBark     = Color(0xFF5A3A22); // écorce
  static const forestLeaf     = Color(0xFF7FB069); // feuille
  static const forestBerry    = Color(0xFFC44536); // baie
  static const forestInk      = Color(0xFF0D1F15); // encre

  // ── Aliases thème Flutter (utilisés par AppTheme) ─────────────────────────
  static const paper      = forestBg1;
  static const paper2     = forestBg2;
  static const ink        = forestCream;
  static const inkSoft    = Color(0xFFBBA98A); // crème atténué
  static const inkMute    = Color(0xFF7A6B52); // crème muted
  static const line       = Color(0xFF3D5E48); // bordure subtile
  static const line2      = Color(0xFF2D4A38); // bordure marquée
  static const accent1    = forestGold;
  static const accent2    = forestGoldLight;
  static const accentSoft = Color(0x33E8B04A); // or 20 % — fonds doux
  static const accentInk  = forestInk;

  // ── Couleurs catégorielles (orbes) ────────────────────────────────────────
  static const rose   = Color(0xFFC97B7B); // rouge-rose doux
  static const sky    = Color(0xFF6B9FC4); // bleu ciel forêt
  static const lilac  = Color(0xFF9B7EC8); // lilas enchanté
  static const butter = Color(0xFFD4A847); // jaune doré
  static const mint   = Color(0xFF5EA87A); // vert menthe profond
  static const moss   = Color(0xFF4A7A5E); // mousse
  static const coral  = Color(0xFFB86A4A); // terre cuite
  static const peach  = Color(0xFFCC8855); // pêche automne

  // ── Ombres ────────────────────────────────────────────────────────────────
  static const shadowWarm       = Color(0x330D1F15);
  static const shadowWarmStrong = Color(0x660D1F15);
}
