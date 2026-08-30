// splash_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../services/auth_api_services.dart';
import '../../../services/cms_api_service.dart';
import '../../../utils/app_key_names.dart';
import '../../../utils/other_methods.dart';
import '../../main_layout/main_layout.dart';
import '../../maintenance/under_maintenance_screen.dart';
import '../../update/app_update_screen.dart';
import '../login/login_screen.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  // ── Logo glow ring pulse ──
  late Animation<double> ringScale;
  late Animation<double> ringFade;

  // ── Logo icon ──
  late Animation<double> logoScale;
  late Animation<double> logoFade;

  // ── Shimmer bar under icon ──
  late Animation<double> shimmerWidth;
  late Animation<double> shimmerFade;

  // ── Brand name slide + fade ──
  late Animation<Offset> titleSlide;
  late Animation<double> titleFade;

  // ── Sub-brand ──
  late Animation<double> subtitleFade;

  // ── Tagline ──
  late Animation<Offset> taglineSlide;
  late Animation<double> taglineFade;

  // ── Bottom dots / loading indicator ──
  late Animation<double> dotsFade;

  @override
  void onInit() {
    super.onInit();
    _setupFirebaseMessaging();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Ring pulse
    ringScale = Tween<double>(begin: 0.6, end: 1.15).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
      ),
    );
    ringFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.30),
      ),
    );

    // Logo
    logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOutBack),
      ),
    );
    logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.05, 0.38),
      ),
    );

    // TODO Shimmer line
    shimmerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.38, 0.58, curve: Curves.easeOut),
      ),
    );
    shimmerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.35, 0.55),
      ),
    );

    // Brand name
    titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.42, 0.68),
      ),
    );

    // Sub-brand
    subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.54, 0.76),
      ),
    );

    // Tagline
    taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.62, 0.88, curve: Curves.easeOut),
      ),
    );
    taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.62, 0.86),
      ),
    );

    // Dots
    dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.80, 1.0),
      ),
    );

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 600), () async {
          // ── 1. Check Under Maintenance API first ───────────────────────────
          OtherMethods.customLog('🛠️ [SplashController] Checking maintenance status before session routing...');
          final isUnderMaintenance = await CmsApiService().checkUnderMaintenance();

          if (isUnderMaintenance) {
            OtherMethods.customLog('🚧 [SplashController] App IS under maintenance. Navigating to UnderMaintenanceScreen.');
            Get.offAll(() => const UnderMaintenanceScreen());
            return;
          }

          // ── 2. Check App Version API ────────────────────────────────────────
          OtherMethods.customLog('📱 [SplashController] Checking app version status...');
          try {
            final packageInfo = await PackageInfo.fromPlatform();
            final currentVersion = packageInfo.version;
            final versionInfo = await CmsApiService().getAppVersion();

            if (versionInfo != null && versionInfo.appVersion.isNotEmpty) {
              final latestVersion = versionInfo.appVersion;
              final isUpdateRequired = versionInfo.isUpdateRequired;

              OtherMethods.customLog('📱 [SplashController] Installed version: $currentVersion, API version: $latestVersion, isUpdateRequired: $isUpdateRequired');

              if (currentVersion.trim() != latestVersion.trim()) {
                if (isUpdateRequired) {
                  // 🔴 Mandatory Update: Stop routing & show non-dismissible Force Update Screen
                  OtherMethods.customLog('⛔ [SplashController] Mandatory Update Required! Navigating to AppUpdateScreen.');
                  Get.offAll(() => AppUpdateScreen(
                        currentVersion: currentVersion,
                        latestVersion: latestVersion,
                      ));
                  return;
                } else {
                  // 🟡 Optional Update: Show Dialog & proceed to app on skip
                  OtherMethods.customLog('⚠️ [SplashController] Optional Update Available. Showing Update Dialog.');
                  showAppUpdateDialog(
                    currentVersion: currentVersion,
                    latestVersion: latestVersion,
                    onSkip: () {
                      _routeUserAfterSplash();
                    },
                  );
                  return;
                }
              }
            }
          } catch (e) {
            OtherMethods.customLog('⚠️ [SplashController] Version check error: $e');
          }

          // ── 3. Normal Session Routing ──────────────────────────────────────
          _routeUserAfterSplash();
        });
      }
    });
  }

  Future<void> _routeUserAfterSplash() async {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    final refreshToken = OtherMethods.getStorage(AppKeyNames.refreshToken);
    final userModel = OtherMethods.getStorage(AppKeyNames.userModel);
    final userId = OtherMethods.getStorage(AppKeyNames.userId);

    OtherMethods.customLog('📱 [SplashController] === SESSION STORAGE DETAILS ===');
    OtherMethods.customLog('🔑 [SplashController] Access Token: $token');
    OtherMethods.customLog('🔄 [SplashController] Refresh Token: $refreshToken');
    OtherMethods.customLog('👤 [SplashController] User Model: $userModel');
    OtherMethods.customLog('🆔 [SplashController] User ID: $userId');
    OtherMethods.customLog('📱 [SplashController] =================================');

    if (userModel != null && refreshToken != null && refreshToken.toString().isNotEmpty) {
      OtherMethods.customLog('🔑 [SplashController] Session found! Refreshing Access Token on Splash...');
      try {
        await AuthApiService().refreshTokenApi(refreshToken: refreshToken.toString());
        OtherMethods.customLog('✅ [SplashController] Refresh token succeeded on Splash! Routing to MainLayoutScreen.');
        Get.offAll(() => MainLayoutScreen());
      } catch (e) {
        OtherMethods.customLog('❌ [SplashController] Token refresh failed on splash: $e. Clearing session & routing to LoginScreen.');
        await OtherMethods.clearStorage();
        Get.offAll(() => const LoginScreen());
      }
    } else if (userModel != null && token != null && token.toString().isNotEmpty) {
      // Fallback for legacy session without refresh token
      OtherMethods.customLog('🔑 [SplashController] Legacy Session found! Routing to MainLayoutScreen.');
      Get.offAll(() => MainLayoutScreen());
    } else {
      OtherMethods.customLog('🔑 [SplashController] No session found. Routing to LoginScreen.');
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // ── 1. Request permission (covers Android 13+ and iOS) ───────────────────
      // On Android < 13, permission is granted automatically at install time.
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      OtherMethods.customLog('🔔 [SplashController] Permission status: ${settings.authorizationStatus}');

      // ── 2. Foreground presentation options (iOS + Android heads-up) ──────────
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // ── 3. Get & print FCM Token ─────────────────────────────────────────────
      String? fcmToken = await messaging.getToken();
      OtherMethods.customLog('🔥 ==================================================');
      OtherMethods.customLog('🔥 [SplashController] FIREBASE FCM TOKEN:');
      OtherMethods.customLog('🔥 $fcmToken');
      OtherMethods.customLog('🔥 ==================================================');

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await OtherMethods.setStorage(key: AppKeyNames.fcmToken, value: fcmToken);

        // Sync FCM token with backend API every time splash screen opens
        final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
        if (token != null && token.toString().isNotEmpty) {
          try {
            await AuthApiService().updateFcmToken(fcmToken: fcmToken);
          } catch (e) {
            OtherMethods.customLog('⚠️ [SplashController] Failed to sync FCM token with backend on splash: $e');
          }
        }
      }

      // Listen for token refresh and sync automatically
      messaging.onTokenRefresh.listen((newToken) async {
        OtherMethods.customLog('🔥 [SplashController] FCM Token Refreshed: $newToken');
        await OtherMethods.setStorage(key: AppKeyNames.fcmToken, value: newToken);
        final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
        if (token != null && token.toString().isNotEmpty) {
          try {
            await AuthApiService().updateFcmToken(fcmToken: newToken);
          } catch (e) {
            OtherMethods.customLog('⚠️ [SplashController] Failed to sync refreshed FCM token with backend: $e');
          }
        }
      });

      // ── 4. Foreground listener — show custom GetX snackbar ───────────────────
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        OtherMethods.customLog('📨 [FCM Foreground] Received: ${message.notification?.title}');
        final title = message.notification?.title ?? 'Unnati Jewellers';
        final body = message.notification?.body ?? '';
        if (body.isNotEmpty) {
          Get.snackbar(
            title,
            body,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF3D0A0A),
            colorText: Colors.white,
            borderRadius: 14,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            icon: const Icon(Icons.notifications_active_rounded, color: Colors.amber),
            shouldIconPulse: false,
            boxShadows: [
              BoxShadow(
                color: Colors.black.withAlpha(61),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          );
        }
      });

      // ── 5. Background tap listener — app opened from notification ────────────
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        OtherMethods.customLog('📲 [FCM Tap] App opened from notification: ${message.notification?.title}');
        // TODO: Add navigation logic here based on message.data['type'] if needed
      });

      // ── 6. Terminated state — app cold-started from notification ────────────
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        OtherMethods.customLog('🚀 [FCM Cold Start] App started from notification: ${initialMessage.notification?.title}');
        // TODO: Add navigation logic here based on initialMessage.data['type'] if needed
      }

    } catch (e) {
      OtherMethods.customLog('❌ [SplashController] Firebase messaging setup failed: $e');
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
