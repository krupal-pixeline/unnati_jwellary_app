import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_api_services.dart';
import '../../services/cms_api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_key_names.dart';
import '../../utils/other_methods.dart';
import '../auth/login/login_screen.dart';
import '../main_layout/main_layout.dart';

class UnderMaintenanceScreen extends StatefulWidget {
  const UnderMaintenanceScreen({super.key});

  @override
  State<UnderMaintenanceScreen> createState() => _UnderMaintenanceScreenState();
}

class _UnderMaintenanceScreenState extends State<UnderMaintenanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;
  final RxBool _isCheckingStatus = false.obs;

  @override
  void initState() {
    super.initState();
    // Breathing pulse for central icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Continuous rotation for outer gold ring
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _checkStatusAndProceed() async {
    if (_isCheckingStatus.value) return;

    try {
      _isCheckingStatus.value = true;
      final isMaintenance = await CmsApiService().checkUnderMaintenance();

      if (isMaintenance) {
        Get.snackbar(
          'Under Maintenance',
          'App is still undergoing maintenance. We will be back online shortly!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryMaroon,
          colorText: AppColors.lightGold,
          borderRadius: 14,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.build_rounded, color: AppColors.primaryGold),
        );
      } else {
        Get.snackbar(
          'Welcome Back!',
          'Maintenance complete! Redirecting to Unnati Jewellers...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          borderRadius: 14,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        _routeUserAfterMaintenance();
      }
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Unable to check server status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryMaroon,
        colorText: Colors.white,
        borderRadius: 14,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isCheckingStatus.value = false;
    }
  }

  Future<void> _routeUserAfterMaintenance() async {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    final refreshToken = OtherMethods.getStorage(AppKeyNames.refreshToken);
    final userModel = OtherMethods.getStorage(AppKeyNames.userModel);

    if (userModel != null && refreshToken != null && refreshToken.toString().isNotEmpty) {
      try {
        await AuthApiService().refreshTokenApi(refreshToken: refreshToken.toString());
        Get.offAll(() => MainLayoutScreen());
      } catch (_) {
        await OtherMethods.clearStorage();
        Get.offAll(() => const LoginScreen());
      }
    } else if (userModel != null && token != null && token.toString().isNotEmpty) {
      Get.offAll(() => MainLayoutScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.snackbar(
          'Scheduled Maintenance',
          'App is currently under maintenance. Please check back later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryMaroon,
          colorText: AppColors.lightGold,
          duration: const Duration(seconds: 2),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFDF9), // Warm Light Ivory
                Color(0xFFF8F2E6), // Soft Champagne Cream
                Color(0xFFF1E6D3), // Luxury Silk Gold Tint
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                 
                  const SizedBox(height: 12),
                  Text(
                    'UNNATI JEWELLERS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMaroon, // Brand Wine Maroon
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'CRAFTED FOR ROYALTY',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGold,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const Spacer(),

                  // ── Animated Luxury Gold Medallion ─────────────────────
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Gold Glow Halo
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(alpha: 0.25),
                                blurRadius: 36,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // Rotating Ornate Outer Ring
                        RotationTransition(
                          turns: _rotateController,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              children: List.generate(8, (i) {
                                final double angle = (i * 45) * (math.pi / 180);
                                return Transform.translate(
                                  offset: Offset(
                                    68 * math.cos(angle),
                                    68 * math.sin(angle),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),

                        // Double Gold Ring Container
                        Container(
                          width: 130,
                          height: 130,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.lightGold,
                                AppColors.primaryGold,
                                AppColors.darkGold,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryMaroon.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.champagneGold,
                                width: 1.5,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryMaroon,
                                  AppColors.maroonDark,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.handyman_rounded,
                                size: 52,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Main Heading with Filigree Underline ────────────────
                  Text(
                    'Under Maintenance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMaroon,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Decorative Gold Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 1,
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.diamond_outlined,
                        size: 14,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 1,
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Subtitle Message ─────────────────────────────────
                  Text(
                    'We are currently undergoing scheduled maintenance to upgrade your royal jewelry shopping experience. Please check back shortly.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.55,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const Spacer(),

                  // ── Royal Action Button ───────────────────────────────
                  Obx(
                    () => Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.primaryGold,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryMaroon.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isCheckingStatus.value
                            ? null
                            : _checkStatusAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isCheckingStatus.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.lightGold,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.refresh_rounded,
                                    size: 20,
                                    color: AppColors.lightGold,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Check Status',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: AppColors.lightGold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Footer Note ──────────────────────────────────────
                  Text(
                    'Unnati Jewellers • Thank you for your patience',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
