import 'package:flutter/material.dart';

class AppColors {
  // ================= CORE BRAND CONSTANTS (DO NOT CHANGE) =================
  static const Color primaryMaroon = Color(0xFF7A1B2E); // rich, deep wine maroon
  static const Color primaryGold   = Color(0xFFC8A44D); // refined, warm gold
  static const Color lightGold     = Color(0xFFF3E7C6);
  static const Color darkGold      = Color(0xFFA9822E);

  // ================= CORE SURFACE TONES (LIGHTER - fixed dark/coffee look) =================
  static const Color backgroundPrimary   = Color(0xFFFFFFFF); // pure white — clean, airy
  static const Color backgroundSecondary = Color(0xFFF8F8F8); // very light neutral grey
  static const Color backgroundDark      = Color(0xFF1C1414); // warm near-black (dark UI only)

  // ================= CORE TEXT TONES =================
  static const Color textPrimary   = Color(0xFF1A1A1A); // crisp dark — better contrast
  static const Color textSecondary = Color(0xFF5A5A5A); // neutral grey (not warm-brown)
  static const Color textTertiary  = Color(0xFF9E9E9E); // standard light grey

  // ================= SOLID NEUTRALS =================
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ================= CORE STATUS TONES =================
  static const Color success = Color(0xFF2E7D32);
  static const Color error   = Color(0xFFC62828);
  static const Color warning = Color(0xFFED8A00);
  static const Color info    = Color(0xFF1976D2);

  static const Color successLight = Color(0xFFE8F5E9);
  static const Color errorLight   = Color(0xFFFDECEA);
  static const Color warningLight = Color(0xFFFFF4E0);
  static const Color pendingLight = Color(0xFFE3F2FD);

  // ================= BORDERS & DIVIDERS (lighter, clean) =================
  static const Color border      = Color(0xFFE8E8E8); // neutral light grey
  static const Color divider     = Color(0xFFEEEEEE); // very light grey
  static const Color borderFocus = Color(0xFFC8A44D); // gold focus border (unchanged)

  // ================= SHADOWS =================
  static const Color shadow = Color(0xFF000000);

  // ================= INLINE APP ACCENTS =================
  static const Color blueAccent      = Color(0xFF1565C0);
  static const Color purpleAccent    = Color(0xFF6A1B9A);
  static const Color orangeAccent    = Color(0xFFE65100);
  static const Color dividerLight    = Color(0xFFF0F0F0); // clean light
  static const Color champagneLight  = Color(0xFFFDF8F0); // barely-tinted warm white
  static const Color champagneMedium = Color(0xFFF5EDD6); // lighter champagne
  static const Color yellowText      = Color(0xFFB8860B);
  static const Color yellowLight     = Color(0xFFFFFDE7);

  // ================= GOLD & MAROON VARIATIONS =================
  static const Color goldLight  = Color(0xFFFDF7EC); // very light, barely-gold white
  static const Color goldMedium = Color(0xFFD9B45C);
  static const Color goldDeep   = Color(0xFF9C7A1F);
  static const Color roseGold   = Color(0xFFE3B7B0);
  static const Color maroonLight = Color(0xFF9A3049);
  static const Color maroonDark  = Color(0xFF4E1220);
  static const Color maroonDeep  = Color(0xFF3A0D17);
  static const Color primaryDark = Color(0xFF4E0A16);

  // ================= GRAYSCALE PALETTE =================
  static const Color gray50  = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  static const Color lightGrey = gray100;
  static const Color darkGrey  = gray700;

  // ================= ALIASES FOR BACKWARD COMPATIBILITY =================
  static const Color maroonPrimary = primaryMaroon;
  static const Color goldRich      = primaryGold;
  static const Color scaffold      = backgroundPrimary;
  static const Color primary       = primaryMaroon;
  static const Color gold          = primaryGold;
  static const Color surface       = white;
  static const Color offWhite      = backgroundPrimary;
  static const Color grey          = textTertiary;
  static const Color textHint      = textTertiary;
  static const Color approved      = success;
  static const Color rejected      = error;
  static const Color reversed      = warning;
  static const Color pending       = info;
  static const Color goldSoft      = goldLight;
  static const Color goldDark      = darkGold;
  static const Color primaryLight  = maroonLight;
  static const Color obsidian      = Color(0xFF120C0C);
  static const Color champagneGold = Color(0xFFD9B57A);
  static const Color warmGold      = Color(0xFFBF9A55);
  static const Color paleGold      = Color(0xFFFDF7EC); // matches goldLight
  static const Color ivoryWhite    = backgroundPrimary;
  static const Color deepCharcoal  = backgroundDark;
  static const Color mutedStone    = textSecondary;
  static const Color warmCream     = backgroundSecondary;
  static const Color textOnDark    = white;
  static const Color background    = backgroundPrimary;
  static const Color textDark      = textPrimary;
  static const Color textMedium    = textSecondary;
  static const Color textLight     = textTertiary;

  // ================= TEXT STYLE ALIASES =================
  static const Color textWhite  = white;
  static const Color textGold   = primaryGold;
  static const Color textMaroon = primaryMaroon;

  // ================= BUTTON DESIGN ALIASES =================
  static const Color buttonPrimary      = primaryGold;
  static const Color buttonPrimaryText  = primaryMaroon;
  static const Color buttonSecondary    = primaryMaroon;
  static const Color buttonSecondaryText = primaryGold;
  static const Color buttonOutlinedBorder = primaryGold;
  static const Color buttonDisabled     = Color(0xFFE0E0E0); // neutral grey disabled

  // ================= CORE GRADIENTS =================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryMaroon, maroonDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGold, primaryGold, darkGold],
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF3A0D17), Color(0xFF7A1B2E), Color(0xFFA23349)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// import 'package:flutter/material.dart';
//
// class AppColors {
//   // ================= CORE BRAND CONSTANTS =================
//   static const Color primaryMaroon = Color(0xFF6B1D2E);
//   static const Color primaryGold = Color(0xFFD4AF37);
//   static const Color lightGold = Color(0xFFF3E5AB);
//   static const Color darkGold = Color(0xFFB8860B);
//
//   // ================= CORE SURFACE TONES =================
//   static const Color backgroundPrimary = Color(0xFFFDF9F0);
//   static const Color backgroundSecondary = Color(0xFFF5F0E6);
//   static const Color backgroundDark = Color(0xFF1A1A1A);
//
//   // ================= CORE TEXT TONES =================
//   static const Color textPrimary = Color(0xFF2C2C2C);
//   static const Color textSecondary = Color(0xFF6B6B6B);
//   static const Color textTertiary = Color(0xFF9E9E9E);
//
//   // ================= SOLID NEUTRALS =================
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color transparent = Color(0x00000000);
//
//   // ================= CORE STATUS TONES =================
//   static const Color success = Color(0xFF2E7D32);
//   static const Color error = Color(0xFFD32F2F);
//   static const Color warning = Color(0xFFFFA000);
//   static const Color info = Color(0xFF1976D2);
//
//   static const Color successLight = Color(0xFFE8F5E9);
//   static const Color errorLight = Color(0xFFFFEBEE);
//   static const Color warningLight = Color(0xFFFFF8E1);
//   static const Color pendingLight = Color(0xFFE3F2FD);
//
//   // ================= BORDERS & DIVIDERS =================
//   static const Color border = Color(0xFFE0D6C8);
//   static const Color divider = Color(0xFFE8E0D4);
//   static const Color borderFocus = Color(0xFFD4AF37);
//
//   // ================= SHADOWS =================
//   static const Color shadow = Color(0xFF000000);
//
//   // ================= INLINE APP ACCENTS =================
//   static const Color blueAccent = Color(0xFF1565C0);
//   static const Color purpleAccent = Color(0xFF6A1B9A);
//   static const Color orangeAccent = Color(0xFFE65100);
//   static const Color dividerLight = Color(0xFFE5DDD2);
//   static const Color champagneLight = Color(0xFFFDF7E7);
//   static const Color champagneMedium = Color(0xFFF5EAC2);
//   static const Color yellowText = Color(0xFFF57F17);
//   static const Color yellowLight = Color(0xFFFFF9C4);
//
//   // ================= ALIASES FOR BACKWARD COMPATIBILITY =================
//   static const Color maroonPrimary = primaryMaroon;
//   static const Color goldRich = primaryGold;
//   static const Color scaffold = backgroundPrimary;
//   static const Color primary = primaryMaroon;
//   static const Color gold = primaryGold;
//   static const Color surface = white;
//   static const Color offWhite = backgroundPrimary;
//   static const Color grey = textTertiary;
//   static const Color textHint = textTertiary;
//   static const Color approved = success;
//   static const Color rejected = error;
//   static const Color reversed = warning;
//   static const Color pending = info;
//   static const Color goldSoft = goldLight;
//   static const Color goldDark = darkGold;
//   static const Color primaryLight = maroonLight;
//   static const Color obsidian = Color(0xFF0D0D0D);
//   static const Color champagneGold = Color(0xFFD4AF72);
//   static const Color warmGold = Color(0xFFBF9A55);
//   static const Color paleGold = Color(0xFFF5EDD6);
//   static const Color ivoryWhite = backgroundPrimary;
//   static const Color deepCharcoal = backgroundDark;
//   static const Color mutedStone = textSecondary;
//   static const Color warmCream = backgroundSecondary;
//   static const Color textOnDark = backgroundPrimary;
//   static const Color background = backgroundPrimary;
//   static const Color textDark = textPrimary;
//   static const Color textMedium = textSecondary;
//   static const Color textLight = textTertiary;
//
//   // ================= TEXT STYLE ALIASES =================
//   static const Color textWhite = white;
//   static const Color textGold = primaryGold;
//   static const Color textMaroon = primaryMaroon;
//
//   // ================= BUTTON DESIGN ALIASES =================
//   static const Color buttonPrimary = primaryGold;
//   static const Color buttonPrimaryText = primaryMaroon;
//   static const Color buttonSecondary = primaryMaroon;
//   static const Color buttonSecondaryText = primaryGold;
//   static const Color buttonOutlinedBorder = primaryGold;
//   static const Color buttonDisabled = Color(0xFFD1C7B8);
//
//   // ================= GOLD & MAROON VARIATIONS =================
//   static const Color goldLight = Color(0xFFFFF8E7);
//   static const Color goldMedium = Color(0xFFE5C158);
//   static const Color goldDeep = Color(0xFFB4941E);
//   static const Color roseGold = Color(0xFFE8B4B8);
//   static const Color maroonLight = Color(0xFF8B3549);
//   static const Color maroonDark = Color(0xFF4A1420);
//   static const Color maroonDeep = Color(0xFF3D0E18);
//   static const Color primaryDark = Color(0xFF4A0009);
//
//   // ================= GRAYSCALE PALETTE =================
//   static const Color gray50 = Color(0xFFFAFAFA);
//   static const Color gray100 = Color(0xFFF5F5F5);
//   static const Color gray200 = Color(0xFFEEEEEE);
//   static const Color gray300 = Color(0xFFE0E0E0);
//   static const Color gray400 = Color(0xFFBDBDBD);
//   static const Color gray500 = Color(0xFF9E9E9E);
//   static const Color gray600 = Color(0xFF757575);
//   static const Color gray700 = Color(0xFF616161);
//   static const Color gray800 = Color(0xFF424242);
//   static const Color gray900 = Color(0xFF212121);
//   static const Color lightGrey = gray100;
//   static const Color darkGrey = gray700;
//
//   // ================= CORE GRADIENTS =================
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primaryMaroon, maroonDark],
//   );
//
//   static const LinearGradient goldGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [lightGold, primaryGold, darkGold],
//   );
//
//   static const LinearGradient bannerGradient = LinearGradient(
//     colors: [Color(0xFF3B0009), Color(0xFF7B0D1E), Color(0xFFAB2337)],
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//   );
// }
