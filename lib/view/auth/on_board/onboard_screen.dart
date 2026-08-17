import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import 'onboard_controller.dart';

class OnBoardScreen extends StatelessWidget {
  OnBoardScreen({super.key});

  final OnBoardController controller = Get.put(OnBoardController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: controller.skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.buttonOutlinedBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Skip",
                        style: GoogleFonts.poppins(
                          color: AppColors.textGold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onBoardData.length,
                onPageChanged: controller.onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = controller.onBoardData[index];
                  return AnimatedBuilder(
                    animation: controller.animationController,
                    builder: (context, _) {
                      return FadeTransition(
                        opacity: controller.fadeAnimation,
                        child: ScaleTransition(
                          scale: controller.scaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [

                                const SizedBox(height: 20),

                                /// Image Card
                                Container(
                                  height: size.height * 0.36,
                                  width: double.infinity,
                                  child: Image.asset(
                                    data["image"]!,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                const SizedBox(height: 40),

                                /// Title
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          AppColors.lightGold,
                                          AppColors.primaryGold,
                                          AppColors.darkGold,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    data["title"]!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                /// Description
                                Text(
                                  data["description"]!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryMaroon,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
              child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onBoardData.length,
                          (index) {
                        final isActive =
                            controller.currentIndex.value == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 8,
                          width: isActive ? 32 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isActive
                                ? const LinearGradient(
                              colors: [
                                AppColors.lightGold,
                                AppColors.primaryGold,
                              ],
                            )
                                : null,
                            color: isActive
                                ? null
                                : AppColors.gray400,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (controller.currentIndex.value != 0) ...[
                        SizedBox(
                          height: 56,
                          width: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.backgroundSecondary,
                                  AppColors.goldLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.buttonOutlinedBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: controller.previousPage,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textGold,
                              ),
                            ),
                          ),
                        ),                        const SizedBox(width: 14),
                      ],

                      /// Next / Continue
                      Expanded(
                      child: SizedBox(
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.goldMedium,
                                AppColors.primaryGold,
                                AppColors.darkGold,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withOpacity(0.30),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: controller.nextPage,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.isLastPage
                                          ? "Continue"
                                          : "Next",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.buttonPrimaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.buttonPrimaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ],
                  )
                ],
              )),
            ),

          ],
        ),
      ),
    );
  }
}
