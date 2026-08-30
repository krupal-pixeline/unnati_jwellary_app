import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_urls.dart';
import '../../utils/other_methods.dart';

/// Launch Play Store URL safely
Future<void> _launchPlayStore() async {
  final Uri uri = Uri.parse(AppUrls.playStoreUrl);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri);
    }
  } catch (e) {
    OtherMethods.customLog('❌ Could not launch Play Store link: $e');
    Get.snackbar(
      "Error",
      "Could not open Play Store.",
      backgroundColor: AppColors.errorLight,
      colorText: AppColors.error,
      snackPosition: SnackPosition.TOP,
    );
  }
}

/// Show Optional Soft UI Update Dialog (isUpdateRequired = false)
void showAppUpdateDialog({
  required String currentVersion,
  required String latestVersion,
  required VoidCallback onSkip,
}) {
  Get.dialog(
    PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
        onSkip();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Soft Icon Container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFDF6EC), // Soft Warm Cream Gold Tint
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.primaryMaroon,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'New Update Available',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Soft Version Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'v$currentVersion',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    Text(
                      'v$latestVersion',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Body Message
              Text(
                'A new version of Unnati Jewellers is available. Update now to explore new features and enhanced performance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Soft Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        onSkip();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Later',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryMaroon.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _launchPlayStore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Update Now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

// Soft UI Mandatory / Force App Update Screen (isUpdateRequired = true)
class AppUpdateScreen extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;

  const AppUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.snackbar(
          'Update Required',
          'Please update the app to continue using Unnati Jewellers.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryMaroon,
          colorText: AppColors.lightGold,
          duration: const Duration(seconds: 3),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2), // Soft Cream Ivory
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Brand Logo Header ──
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.diamond_rounded,
                      size: 42,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'UNNATI JEWELLERS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMaroon,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CRAFTED FOR ROYALTY',
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGold,
                    letterSpacing: 2.0,
                  ),
                ),

                const Spacer(flex: 2),

                // ── Soft Elevated Center Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Soft Update Icon Badge
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFDF6EC), // Soft Gold Glow Tint
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 34,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'App Update Required',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Soft 1-Line Version Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'v$currentVersion',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            Text(
                              'v$latestVersion',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Message Body
                      Text(
                        'A mandatory update is required to continue using Unnati Jewellers. Please update to the latest version on Play Store.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Soft Update Now Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryMaroon.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _launchPlayStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.system_update_alt_rounded,
                                size: 20,
                                color: AppColors.lightGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                  color: AppColors.lightGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Footer
                Text(
                  'Unnati Jewellers • Crafted for Royalty',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
