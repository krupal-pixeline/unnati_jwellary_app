import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import '../../../utils/app_colors.dart';
import '../../../services/live_rate_service.dart';
import '../../../services/swarnim_scheme_api_service.dart';
import '../../home/live_rate_controller.dart';
import '../activated_scheme/activated_scheme_screen.dart';

class AddSchemeController extends GetxController {
  final RxInt currentStep = 0.obs;

  // ── Plan Duration ─────────────────────────────────────────

  final List<int> durationOptions = [10, 20];

  final RxInt selectedDuration = 10.obs;

  // Installment Date

  final List<int> installmentDates = List.generate(31, (index) => index + 1);

  final RxInt selectedInstallmentDate = 1.obs;

  void onDurationChanged(int? value) {
    if (value == null) return;
    selectedDuration.value = value;
  }

  void onInstallmentDateChanged(int? value) {
    if (value == null) return;
    selectedInstallmentDate.value = value;
  }

  // 0 = Invest On Money, 1 = Invest On Gold

  final RxInt investmentTypeIndex = 0.obs;

  bool get isMoneyInvestment => investmentTypeIndex.value == 0;

  bool get isGoldInvestment => investmentTypeIndex.value == 1;

  // Live gold rate (₹ per gram, 24K) – in production this comes from an API

  final RxDouble liveGoldRate = 7245.50.obs;

  // ── Step 2 – Customer Details ─────────────────────────────────────────────

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final addressController = TextEditingController();

  final aadharController = TextEditingController();

  String rawAadhar = '';

  final panController = TextEditingController();

  String rawPan = '';

  final mobileController = TextEditingController();

  final otpController = TextEditingController();

  final RxBool otpSent = false.obs;

  final RxBool otpVerified = false.obs;

  final RxBool isOtpLoading = false.obs;

  final RxInt otpCountdown = 0.obs;

  final Rx<File?> capturedImage = Rx<File?>(null);

  final RxBool isCapturing = false.obs;

  // Form key for step 2

  final step2FormKey = GlobalKey<FormState>();

  // ── Step 3 – Plan Details ─────────────────────────────────────────────────

  // Gold caret options

  final List<String> caretOptions = ['24K', '22K', '18K', '14K'];

  final RxString selectedCaret = '24K'.obs;

  // Gold caret multipliers (relative purity)

  final Map<String, double> caretMultiplier = {
    '24K': 1.0,

    '22K': 0.9167,

    '18K': 0.75,

    '14K': 0.5833,
  };

  // Money investment

  final amountController = TextEditingController();

  final RxDouble estimatedGrams = 0.0.obs;

  // Gold investment

  final gramController = TextEditingController();

  final RxDouble estimatedAmount = 0.0.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    amountController.addListener(_recalculateFromMoney);
    gramController.addListener(_recalculateFromGold);

    _initSocketRate();
  }

  void _initSocketRate() {
    try {
      final liveRateCtrl = Get.isRegistered<LiveRateController>()
          ? Get.find<LiveRateController>()
          : Get.put(LiveRateController());

      if (liveRateCtrl.gold24kPrice > 0) {
        liveGoldRate.value = liveRateCtrl.gold24kPrice;
      }

      ever(liveRateCtrl.rates, (MetalRates? r) {
        if (r != null && r.gold24k > 0) {
          liveGoldRate.value = r.gold24k;
          _recalculateFromMoney();
          _recalculateFromGold();
        }
      });
    } catch (e) {
      debugPrint("❌ Socket init error in AddSchemeController: $e");
    }
  }

  @override
  void onClose() {
    nameController.dispose();

    emailController.dispose();

    addressController.dispose();

    aadharController.dispose();

    panController.dispose();

    mobileController.dispose();

    otpController.dispose();

    amountController.dispose();

    gramController.dispose();

    super.onClose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void nextStep() {
    if (currentStep.value == 1) {
      if (step2FormKey.currentState != null && !step2FormKey.currentState!.validate()) {
        Get.snackbar(
          'Required Fields',
          'Please fill all required KYC fields correctly',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (!otpVerified.value) {
        Get.snackbar(
          'Verification Required',
          'Please verify your mobile number with OTP',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (capturedImage.value == null) {
        Get.snackbar(
          'Photo Required',
          'Please capture a customer selfie',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    if (currentStep.value < 2) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) => currentStep.value = step;

  bool canProceedFromStep1() => true;

  bool canProceedFromStep2() {
    final panRegex = RegExp(r'^[A-Z0-9]{4}$');
    return nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        rawAadhar.length == 4 &&
        panRegex.hasMatch(rawPan.trim().toUpperCase()) &&
        mobileController.text.trim().isNotEmpty &&
        otpVerified.value &&
        capturedImage.value != null;
  }

  // ── Investment Type ───────────────────────────────────────────────────────

  void setInvestmentType(int index) {
    investmentTypeIndex.value = index;

    // Reset step-3 fields

    amountController.clear();

    gramController.clear();

    estimatedGrams.value = 0;

    estimatedAmount.value = 0;
  }

  final SwarnimSchemeApiService _swarnimApiService = SwarnimSchemeApiService();

  // ── OTP Flow ──────────────────────────────────────────────────────────────

  Future<void> sendOtp() async {
    final mobile = mobileController.text.trim();
    if (mobile.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Enter a valid 10-digit mobile number',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isOtpLoading.value = true;

    try {
      final response = await _swarnimApiService.sendOtp(mobile);
      isOtpLoading.value = false;

      if (response['success'] == true) {
        otpSent.value = true;
        _startOtpCountdown();

        Get.snackbar(
          'OTP Sent',
          response['message'] ?? 'OTP sent successfully via WhatsApp.',
          backgroundColor: AppColors.successLight,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        otpSent.value = false;
        Get.snackbar(
          'Request Failed',
          response['message'] ?? 'Failed to send OTP.',
          backgroundColor: AppColors.errorLight,
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isOtpLoading.value = false;
      otpSent.value = false;
      final errMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Request Failed',
        errMsg,
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> verifyOtp() async {
    final mobile = mobileController.text.trim();
    final otpCode = otpController.text.trim();
    if (otpCode.length < 4) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the full OTP code',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isOtpLoading.value = true;

    try {
      final response = await _swarnimApiService.verifyOtp(mobile, otpCode);
      isOtpLoading.value = false;

      if (response['success'] == true) {
        otpVerified.value = true;
        Get.snackbar(
          'Verified ✓',
          response['message'] ?? 'OTP verified successfully.',
          backgroundColor: AppColors.successLight,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        otpVerified.value = false;
        Get.snackbar(
          'Verification Failed',
          response['message'] ?? 'The OTP you entered is incorrect.',
          backgroundColor: AppColors.errorLight,
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isOtpLoading.value = false;
      otpVerified.value = false;
      final errMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Verification Failed',
        errMsg,
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void resendOtp() {
    if (otpCountdown.value > 0) return;

    otpController.clear();

    sendOtp();
  }

  void _startOtpCountdown() {
    otpCountdown.value = 30;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (otpCountdown.value > 0) {
        otpCountdown.value--;

        return true;
      }

      return false;
    });
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  Future<void> capturePhoto() async {
    isCapturing.value = true;

    try {
      final picker = ImagePicker();

      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null) capturedImage.value = File(photo.path);
    } catch (e) {
      Get.snackbar(
        'Camera Error',
        'Could not access camera. $e',

        backgroundColor: AppColors.errorLight,

        colorText: AppColors.error,

        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCapturing.value = false;
    }
  }

  void retakePhoto() => capturedImage.value = null;

  // ── Calculations ──────────────────────────────────────────────────────────

  void _recalculateFromMoney() {
    final text = amountController.text.replaceAll(',', '').trim();

    final amount = double.tryParse(text) ?? 0;

    final rate =
        liveGoldRate.value * (caretMultiplier[selectedCaret.value] ?? 1.0);

    estimatedGrams.value = rate > 0 ? amount / rate : 0;
  }

  void _recalculateFromGold() {
    final text = gramController.text.trim();

    final grams = double.tryParse(text) ?? 0;

    final rate =
        liveGoldRate.value * (caretMultiplier[selectedCaret.value] ?? 1.0);

    estimatedAmount.value = grams * rate;
  }

  void onCaretChanged(String? caret) {
    if (caret == null) return;

    selectedCaret.value = caret;

    _recalculateFromMoney();

    _recalculateFromGold();
  }

  double get effectiveRate =>
      liveGoldRate.value * (caretMultiplier[selectedCaret.value] ?? 1.0);



  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> submitScheme() async {
    if (capturedImage.value == null) {
      Get.snackbar(
        'Photo Required',
        'Please capture a customer selfie image before submitting',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final planType = isMoneyInvestment ? 'amount-based' : 'gold-based';
    final accountHolderName = nameController.text.trim();
    final emailId = emailController.text.trim();
    final mobileNumber = mobileController.text.trim();
    final livePhoto = capturedImage.value!;
    final aadhaarNumber = 'XXXX-XXXX-${rawAadhar.trim()}';
    final panCardNumber = 'XXXXX${rawPan.trim().toUpperCase()}';
    
    final rawAmountText = amountController.text.replaceAll(',', '').trim();
    final double parsedAmount = double.tryParse(rawAmountText) ?? 0;
    final monthlyAmountStr = isMoneyInvestment
        ? (parsedAmount > 0 ? parsedAmount.toStringAsFixed(0) : '10000')
        : (estimatedAmount.value > 0 ? estimatedAmount.value.toStringAsFixed(0) : (parsedAmount > 0 ? parsedAmount.toStringAsFixed(0) : '10000'));

    final durationMonthsStr = selectedDuration.value.toString();
    final addressStr = addressController.text.trim();
    final goldTypeStr = isGoldInvestment ? selectedCaret.value : null;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _swarnimApiService.registerScheme(
        planType: planType,
        accountHolderName: accountHolderName,
        emailId: emailId,
        mobileNumber: mobileNumber,
        livePhoto: livePhoto,
        aadhaarNumber: aadhaarNumber,
        panCardNumber: panCardNumber,
        monthlyAmount: monthlyAmountStr,
        durationMonths: durationMonthsStr,
        address: addressStr,
        goldType: goldTypeStr,
      );

      Get.back();

      if (response['success'] == true || response['data'] != null) {
        Get.off(() => const ActivatedSchemeScreen());

        Get.snackbar(
          'Scheme Added ✓',
          response['message'] ?? 'Suvarna Unnati scheme has been successfully created.',
          backgroundColor: AppColors.successLight,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Registration Failed',
          response['message'] ?? 'Failed to register scheme.',
          backgroundColor: AppColors.errorLight,
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back();
      final errMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Failed',
        errMsg,
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ── Formatters ────────────────────────────────────────────────────────────

  String formatAmount(double v) =>
      '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String formatGrams(double v) => '${v.toStringAsFixed(4)} g';
}
