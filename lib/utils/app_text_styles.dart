// ─────────────────────────────────────────────────────────────────────────────
// app_text_styles.dart
// Typography system – pairs a display serif (Cormorant Garamond feel via
// system fallback) with a clean sans-serif body, creating the luxury-editorial
// tension typical of high-end jewellery brands.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display / Headings (serif character) ─────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Georgia', // fallback serif; replace with Cormorant Garamond via google_fonts
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
  );

  // ── AppBar title ─────────────────────────────────────────────────────────
  static  TextStyle appBarTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.5,
    color: AppColors.champagneGold,
  );

  // ── Body (sans-serif) ────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Navigation labels ────────────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  // ── Drawer items ─────────────────────────────────────────────────────────
  static final TextStyle drawerItem = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textOnDark,
  );

  static const TextStyle drawerItemSubtle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: AppColors.mutedStone,
  );

  static const TextStyle drawerSectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.8,
    color: AppColors.champagneGold,
  );
}
