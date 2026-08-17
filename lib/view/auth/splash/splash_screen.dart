// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.maroonDeep,
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.maroonDeep,
                  AppColors.primaryMaroon,
                  Color(0xFF5E1020),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // ── Decorative background circles ──
                _BackgroundOrbs(size: size),

                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // ── App Logo Image ──
                        ScaleTransition(
                          scale: controller.logoScale,
                          child: FadeTransition(
                            opacity: controller.logoFade,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Image.asset(
                                "assets/images/app_logo.png",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.diamond_rounded,
                                  size: 80,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Splash Text Image ──
                        SlideTransition(
                          position: controller.titleSlide,
                          child: FadeTransition(
                            opacity: controller.titleFade,
                            child: SizedBox(
                              width: 220,
                              height: 80,
                              child: Image.asset(
                                "assets/images/splash_text.png",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 4),


                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background decorative orbs
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundOrbs extends StatelessWidget {
  final Size size;
  const _BackgroundOrbs({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right large orb
        Positioned(
          top: -size.width * 0.25,
          right: -size.width * 0.20,
          child: Container(
            width: size.width * 0.70,
            height: size.width * 0.70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left orb
        Positioned(
          bottom: -size.width * 0.15,
          left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.maroonLight.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Center subtle glow
        Positioned(
          top: size.height * 0.28,
          left: size.width * 0.10,
          right: size.width * 0.10,
          child: Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Loading dots
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  final double opacity;
  const _LoadingDots({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == 1 ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == 1
                  ? AppColors.primaryGold
                  : AppColors.primaryGold.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
