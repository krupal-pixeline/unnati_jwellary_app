// onboard_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../login/login_screen.dart';

class OnBoardController extends GetxController
    with GetSingleTickerProviderStateMixin {

  /// OnBoard Data
  final List<Map<String, String>> onBoardData = [
    {
      "image": "assets/images/onboard_1.png",
      "title": "Unnati Suvarna Scheme",
      "description":
      "Start your golden journey with our Unnati Suvarna Scheme. Save regularly and turn your dream of owning beautiful gold jewellery into reality.",
    },
    {
      "image": "assets/images/onboard_2.png",
      "title": "Smart Gold Price Tracking",
      "description":
      "Stay updated with daily gold price movements and make informed buying decisions at the perfect time.",
    },
    {
      "image": "assets/images/onboard_3.png",
      "title": "Smart Customer Support",
      "description":
      "Get instant assistance from our dedicated support team for scheme details, orders, payments, and all your jewellery needs.",
    },
  ];

  /// Page Controller
  final PageController pageController = PageController();

  /// Current Page Index
  final RxInt currentIndex = 0.obs;

  /// Background Animation Controller
  late AnimationController animationController;

  /// Fade Animation
  late Animation<double> fadeAnimation;

  /// Scale Animation
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    animationController.forward();
  }

  /// Page Changed
  void onPageChanged(int index) {
    currentIndex.value = index;

    animationController.reset();
    animationController.forward();
  }

  /// Next Page
  void nextPage() {
    if (currentIndex.value < onBoardData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      continueToApp();
    }
  }

  /// Previous Page
  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Skip OnBoard
  void skip() {
    continueToApp();
  }

  /// Continue To App
  void continueToApp() {
    /// Replace with your navigation
    ///
    /// Example:
    /// Get.offAll(() => LoginScreen());
    ///
    /// For now:
    Get.offAll(()=> LoginScreen());
  }

  /// Is Last Page
  bool get isLastPage =>
      currentIndex.value == onBoardData.length - 1;

  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
