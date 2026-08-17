import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import 'terms_and_condition_controller.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TermsAndConditionController());

    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primaryMaroon,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Obx(
            () => controller.hasError.value
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'Retry',
                    onPressed: controller.fetchTerms,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────────
      body: Obx(() {
        // Loading
        if (controller.isLoading.value) {
          return const _LoadingView();
        }

        // Error
        if (controller.hasError.value) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchTerms,
          );
        }

        // ── Show API HTML exactly as received ─────────────────────────────────
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Html(
            data: controller.htmlContent.value,
            style: {
              // Web HTML has margin:60px auto on .container — reset for mobile
              '.container': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.symmetric(horizontal: 16, vertical: 8),
              ),
            },
          ),
        );
      }),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Loading View
// ────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Terms & Conditions...',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Error View
// ────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 52, color: Colors.red.shade300),
            const SizedBox(height: 20),
            Text(
              'Oops! Something Went Wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: AppColors.primaryMaroon,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
