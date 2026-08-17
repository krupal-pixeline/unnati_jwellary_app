import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/app_colors.dart';
import 'privecy_policy_controller.dart';

class PrivecyPolicyScreen extends StatefulWidget {
  const PrivecyPolicyScreen({super.key});

  @override
  State<PrivecyPolicyScreen> createState() => _PrivecyPolicyScreenState();
}

class _PrivecyPolicyScreenState extends State<PrivecyPolicyScreen> {
  late final PrivecyPolicyController _controller;
  late final WebViewController _webViewController;
  final RxBool _webPageLoaded = false.obs;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController in initState — NOT in build()
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _webPageLoaded.value = true,
        ),
      );

    // Put controller and listen for HTML content
    _controller = Get.put(PrivecyPolicyController());

    // When HTML arrives, load it into WebView
    ever(_controller.htmlContent, (String html) {
      if (html.isNotEmpty) {
        _webPageLoaded.value = false;
        _webViewController.loadHtmlString(html);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ─────────────────────────────────────────────────────────────
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
          'Privacy Policy',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Obx(
            () => _controller.hasError.value
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'Retry',
                    onPressed: _controller.fetchPrivacyPolicy,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: Obx(() {
        // Error State
        if (_controller.hasError.value) {
          return _ErrorView(
            message: _controller.errorMessage.value,
            onRetry: _controller.fetchPrivacyPolicy,
          );
        }

        return Stack(
          children: [
            // WebView — always mounted
            WebViewWidget(controller: _webViewController),

            // Loading overlay — shown while API fetching or WebView rendering
            Obx(() {
              final bool showLoading =
                  _controller.isLoading.value || !_webPageLoaded.value;
              if (!showLoading) return const SizedBox.shrink();
              return Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryMaroon,
                        ),
                        strokeWidth: 2.5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading Privacy Policy...',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
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
        padding: const EdgeInsets.symmetric(horizontal: 36),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
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
