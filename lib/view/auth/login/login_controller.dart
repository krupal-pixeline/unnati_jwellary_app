import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../model/auth/login_model.dart';
import '../../../model/auth/verify_otp_model.dart';
import '../../../services/auth_api_services.dart';
import '../../../utils/app_key_names.dart';
import '../../../utils/other_methods.dart';
import '../../main_layout/main_layout.dart';

// =====================================================================
//  Login Phase Enum
// =====================================================================
enum LoginPhase { contact, otp }

// =====================================================================
//  LoginController
//  ────────────────────────────────────────────────────────────────────
//  Manages all state for the Login screen (Contact + OTP phases).
//  All API calls are routed through [AuthApiService] → [BaseApiService].
// =====================================================================
class LoginController extends ChangeNotifier {
  // ─────────────────────────────────────────
  //  Dependencies
  // ─────────────────────────────────────────
  final AuthApiService _authApiService = AuthApiService();

  // ─────────────────────────────────────────
  //  Text Controllers & Focus Nodes
  // ─────────────────────────────────────────
  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final FocusNode contactFocusNode = FocusNode();

  // ─────────────────────────────────────────
  //  State
  // ─────────────────────────────────────────
  LoginPhase _phase = LoginPhase.contact;
  bool _isLoading = false;
  String? _contactError;
  String? _otpError;
  String _sentToContact = '';
  int _resendTimer = 30;
  bool _canResend = false;

  // Cached models from API responses
  LoginModel? _loginModel;
  VerifyOtpModel? _verifyOtpModel;

  // ─────────────────────────────────────────
  //  Getters
  // ─────────────────────────────────────────
  LoginPhase get phase => _phase;
  bool get isLoading => _isLoading;
  String? get contactError => _contactError;
  String? get otpError => _otpError;
  String get sentToContact => _sentToContact;
  int get resendTimer => _resendTimer;
  bool get canResend => _canResend;
  LoginModel? get loginModel => _loginModel;
  VerifyOtpModel? get verifyOtpModel => _verifyOtpModel;

  // =====================================================================
  //  Contact Validation
  // =====================================================================
  bool _validateContact() {
    final raw = contactController.text.trim();

    if (raw.isEmpty) {
      _contactError = 'Please enter your mobile number';
      notifyListeners();
      return false;
    }

    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 13) {
      _contactError = 'Enter a valid mobile number';
      notifyListeners();
      return false;
    }

    _contactError = null;
    notifyListeners();
    return true;
  }

  // =====================================================================
  //  Send OTP  →  POST /customers/login
  // =====================================================================
  Future<void> sendOtp() async {
    if (!_validateContact()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final String mobileNumber = contactController.text.trim();

      OtherMethods.customLog('📲 [LoginController] sendOtp() called for → $mobileNumber');

      final LoginModel result = await _authApiService.login(
        mobileNumber: mobileNumber,
      );

      _loginModel = result;
      _sentToContact = mobileNumber;
      _phase = LoginPhase.otp;
      _startResendTimer();

      OtherMethods.customLog('✅ [LoginController] OTP sent successfully → ${result.message}');

      // Auto-focus first OTP field after a short delay.
      Future.delayed(const Duration(milliseconds: 300), () {
        otpFocusNodes[0].requestFocus();
      });
    } catch (e) {
      OtherMethods.customLog('❌ [LoginController] sendOtp() error → $e');
      _contactError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================================================================
  //  Resend OTP  →  POST /customers/resend-otp
  // =====================================================================

  Future<void> resendOtp() async {
    if (!_canResend) return;
    _canResend = false;
    notifyListeners();
    try {
      OtherMethods.customLog('[LoginController] resendOtp() → calling resend-otp API for $_sentToContact');
      // Call dedicated POST /customers/resend-otp – only needs mobile number.
      await _authApiService.resendOtp(mobileNumber: _sentToContact);
      OtherMethods.customLog('✅ [LoginController] OTP resent successfully for $_sentToContact');
      _clearOtpFields();
      _startResendTimer();
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 300), () {
        otpFocusNodes[0].requestFocus();
      });
    } catch (e) {
      OtherMethods.customLog('❌ [LoginController] resendOtp() error → $e');
      _otpError = e.toString().replaceFirst('Exception: ', '');
      _canResend = true; // Let user retry on failure.
      notifyListeners();
    }
  }

  // =====================================================================
  //  Verify OTP  →  POST /customers/verify-otp
  // =====================================================================
  Future<bool> verifyOtp() async {
    final String otp = otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      _otpError = 'Please enter the complete 6-digit OTP';
      notifyListeners();
      return false;
    }

    _otpError = null;
    _isLoading = true;
    notifyListeners();

    try {
      OtherMethods.customLog('🔑 [LoginController] verifyOtp() called → OTP: $otp');

      String? fcmToken = OtherMethods.getStorage(AppKeyNames.fcmToken) ?? OtherMethods.getStorage('fcmToken');
      if (fcmToken == null || fcmToken.isEmpty) {
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && fcmToken.isNotEmpty) {
            await OtherMethods.setStorage(key: AppKeyNames.fcmToken, value: fcmToken);
          }
        } catch (e) {
          OtherMethods.customLog('⚠️ [LoginController] Could not fetch FCM token from Firebase: $e');
        }
      }

      final VerifyOtpModel result = await _authApiService.verifyOtp(
        mobileNumber: _sentToContact,
        otp: otp,
        fcmToken: fcmToken ?? '', 
      );

      _verifyOtpModel = result;

      // Persist the auth token for subsequent authenticated requests.
      if (result.token != null && result.token!.isNotEmpty) {
        await OtherMethods.setStorage(
          key: AppKeyNames.bearerToken,
          value: result.token,
        );
        OtherMethods.customLog('💾 [LoginController] Auth token saved to storage.');
      }

      // Persist the refresh token.
      if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
        await OtherMethods.setStorage(
          key: AppKeyNames.refreshToken,
          value: result.refreshToken,
        );
        OtherMethods.customLog('💾 [LoginController] Refresh token saved to storage.');
      }

      // Persist customer profile and user ID.
      if (result.customer != null) {
        await OtherMethods.setStorage(
          key: AppKeyNames.userModel,
          value: result.customer!.toJson(),
        );
        await OtherMethods.setStorage(
          key: AppKeyNames.userId,
          value: result.customer!.id,
        );
        OtherMethods.customLog('💾 [LoginController] Customer data & User ID saved to storage.');
      }

      OtherMethods.customLog('✅ [LoginController] OTP verified → ${result.message}');

      _isLoading = false;
      notifyListeners();

      // Navigate to main layout.
      Get.offAll(() => MainLayoutScreen());

      return true;
    } catch (e) {
      OtherMethods.customLog('❌ [LoginController] verifyOtp() error → $e');

      _otpError = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // =====================================================================
  //  OTP Input Handling
  // =====================================================================
  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
    }
    _otpError = null;
    notifyListeners();
  }

  void onOtpBackspace(int index) {
    final ctrl = otpControllers[index];
    if (ctrl.text.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
      otpControllers[index - 1].clear();
    } else {
      ctrl.clear();
    }
    _otpError = null;
    notifyListeners();
  }

  // =====================================================================
  //  Go Back to Contact Phase
  // =====================================================================
  void goBackToContact() {
    _phase = LoginPhase.contact;
    _otpError = null;
    _clearOtpFields();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 200), () {
      contactFocusNode.requestFocus();
    });
  }

  // =====================================================================
  //  Clear Contact Error on Type
  // =====================================================================
  void onContactChanged(String _) {
    if (_contactError != null) {
      _contactError = null;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────
  //  Private Helpers
  // ─────────────────────────────────────────
  void _clearOtpFields() {
    for (final c in otpControllers) {
      c.clear();
    }
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _canResend = false;
    _tickResend();
  }

  void _tickResend() async {
    while (_resendTimer > 0) {
      await Future.delayed(const Duration(seconds: 1));
      _resendTimer--;
      notifyListeners();
    }
    _canResend = true;
    notifyListeners();
  }

  // =====================================================================
  //  Dispose
  // =====================================================================
  @override
  void dispose() {
    contactController.dispose();
    contactFocusNode.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
