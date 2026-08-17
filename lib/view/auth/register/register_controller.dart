import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../model/auth/register_model.dart';
import '../../../model/auth/verify_otp_model.dart';
import '../../../services/auth_api_services.dart';
import '../../../utils/app_key_names.dart';
import '../../../utils/other_methods.dart';
import '../../main_layout/main_layout.dart';

// ══════════════════════════════════════════
// REGISTRATION PHASE ENUM
// ══════════════════════════════════════════
enum RegisterPhase { form, otp }

class RegisterController extends ChangeNotifier {
  // ─────────────────────────────────────────
  //  Dependencies
  // ─────────────────────────────────────────
  final AuthApiService _authApiService = AuthApiService();
  // ══════════════════════════════════════════
  // TEXT CONTROLLERS
  // ══════════════════════════════════════════
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController anniversaryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  // ── OTP Controllers (6 boxes) ──
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // ══════════════════════════════════════════
  // FOCUS NODES
  // ══════════════════════════════════════════
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode mobileFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode referralCodeFocus = FocusNode();

  // ── OTP Focus Nodes (6 boxes) ──
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  // ══════════════════════════════════════════
  // PHASE & STATE
  // ══════════════════════════════════════════
  RegisterPhase _phase = RegisterPhase.form;
  RegisterPhase get phase => _phase;

  DateTime? _selectedDob;
  DateTime? _selectedAnniversary;
  String? _selectedState;
  bool _isLoading = false;
  bool _anniversarySkipped = false;

  // ── OTP State ──
  String _sentToMobile = '';
  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  // ── Cached API response models ──
  RegisterModel? _registerModel;
  VerifyOtpModel? _verifyOtpModel;

  // ── Referral Code State ──
  bool _isVerifyingReferral = false;
  String? _referralOwnerName; // set once a valid code is verified

  // ── Errors ──
  String? _fullNameError;
  String? _mobileError;
  String? _emailError;
  String? _dobError;
  String? _cityError;
  String? _stateError;
  String? _otpError;
  String? _referralCodeError;

  // ══════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════
  DateTime? get selectedDob => _selectedDob;
  DateTime? get selectedAnniversary => _selectedAnniversary;
  String? get selectedState => _selectedState;
  bool get isLoading => _isLoading;
  bool get anniversarySkipped => _anniversarySkipped;

  String get sentToMobile => _sentToMobile;
  int get resendTimer => _resendTimer;
  bool get canResend => _canResend;

  bool get isVerifyingReferral => _isVerifyingReferral;
  String? get referralOwnerName => _referralOwnerName;

  RegisterModel? get registerModel => _registerModel;
  VerifyOtpModel? get verifyOtpModel => _verifyOtpModel;

  String? get fullNameError => _fullNameError;
  String? get mobileError => _mobileError;
  String? get emailError => _emailError;
  String? get dobError => _dobError;
  String? get cityError => _cityError;
  String? get stateError => _stateError;
  String? get otpError => _otpError;
  String? get referralCodeError => _referralCodeError;

  // ══════════════════════════════════════════
  // INDIAN STATES LIST
  // ══════════════════════════════════════════
  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  // ══════════════════════════════════════════
  // MOCK REFERRAL CODE DATABASE
  // TODO: Replace with real "verify referral code" API call
  // ══════════════════════════════════════════
  static const Map<String, String> _mockReferralCodes = {
    'KRUPAL100': '',
    'DABI50': '',
    'GOLD25': '',
  };

  // ══════════════════════════════════════════
  // DATE PICKERS
  // ══════════════════════════════════════════
  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1930),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      helpText: 'SELECT DATE OF BIRTH',
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      _selectedDob = picked;
      dobController.text = _formatDate(picked);
      _dobError = null;
      notifyListeners();
    }
  }

  Future<void> pickAnniversaryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversary ?? DateTime(now.year - 1),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'SELECT ANNIVERSARY DATE',
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      _selectedAnniversary = picked;
      anniversaryController.text = _formatDate(picked);
      _anniversarySkipped = false;
      notifyListeners();
    }
  }

  void toggleAnniversarySkip() {
    _anniversarySkipped = !_anniversarySkipped;
    if (_anniversarySkipped) {
      _selectedAnniversary = null;
      anniversaryController.clear();
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════
  // STATE SELECTION
  // ══════════════════════════════════════════
  void selectState(String state) {
    _selectedState = state;
    _stateError = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════
  // CLEAR ERRORS ON CHANGE
  // ══════════════════════════════════════════
  void onFullNameChanged(String _) {
    if (_fullNameError != null) {
      _fullNameError = null;
      notifyListeners();
    }
  }

  void onMobileChanged(String _) {
    if (_mobileError != null) {
      _mobileError = null;
      notifyListeners();
    }
  }

  void onEmailChanged(String _) {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  void onCityChanged(String _) {
    if (_cityError != null) {
      _cityError = null;
      notifyListeners();
    }
  }

  void onReferralCodeChanged(String _) {
    // Any edit invalidates a previously verified code / error
    if (_referralCodeError != null || _referralOwnerName != null) {
      _referralCodeError = null;
      _referralOwnerName = null;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════
  // OTP INPUT HANDLER
  // ══════════════════════════════════════════
  void onOtpChanged(int index, String value) {
    // Clear error on any input
    if (_otpError != null) {
      _otpError = null;
      notifyListeners();
    }

    if (value.isNotEmpty && index < 5) {
      // Move focus to next box
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move focus back on delete
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  String get _enteredOtp => otpControllers.map((c) => c.text).join();

  // ══════════════════════════════════════════
  // RESEND TIMER
  // ══════════════════════════════════════════
  void _startResendTimer() {
    _resendTimer = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        _canResend = true;
        t.cancel();
        notifyListeners();
      }
    });
  }

  // ══════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════
  bool _validateAll() {
    bool valid = true;

    // Full Name
    final name = fullNameController.text.trim();
    if (name.isEmpty) {
      _fullNameError = 'Full name is required';
      valid = false;
    } else if (name.length < 3) {
      _fullNameError = 'Name must be at least 3 characters';
      valid = false;
    } else if (!RegExp(r"^[a-zA-Z\s']+$").hasMatch(name)) {
      _fullNameError = 'Enter a valid name (letters only)';
      valid = false;
    } else {
      _fullNameError = null;
    }

    // Mobile
    final mobile = mobileController.text.trim();
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (mobile.isEmpty) {
      _mobileError = 'Mobile number is required';
      valid = false;
    } else if (digits.length != 10) {
      _mobileError = 'Enter a valid 10-digit mobile number';
      valid = false;
    } else {
      _mobileError = null;
    }

    // Email
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Email address is required';
      valid = false;
    } else if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(email)) {
      _emailError = 'Enter a valid email address';
      valid = false;
    } else {
      _emailError = null;
    }

    // Date of Birth
    if (_selectedDob == null) {
      _dobError = 'Date of birth is required';
      valid = false;
    } else {
      _dobError = null;
    }

    // City
    final city = cityController.text.trim();
    if (city.isEmpty) {
      _cityError = 'City is required';
      valid = false;
    } else if (city.length < 2) {
      _cityError = 'Enter a valid city name';
      valid = false;
    } else {
      _cityError = null;
    }

    // State
    if (_selectedState == null || _selectedState!.isEmpty) {
      _stateError = 'Please select your state';
      valid = false;
    } else {
      _stateError = null;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> _verifyReferralCodeIfProvided() async {
    final code = referralCodeController.text.trim();

    // Field is optional — nothing entered means nothing to verify.
    if (code.isEmpty) {
      _referralCodeError = null;
      _referralOwnerName = null;
      return true;
    }

    _isVerifyingReferral = true;
    _referralCodeError = null;
    notifyListeners();

    // TODO: Replace with real API call, e.g.
    // final result = await ApiService.verifyReferralCode(code);
    await Future.delayed(const Duration(milliseconds: 900));

    final normalized = code.toUpperCase();
    final ownerName = _mockReferralCodes[normalized];

    _isVerifyingReferral = false;

    if (ownerName == null) {
      _referralCodeError = 'Invalid referral code. Please check and try again.';
      _referralOwnerName = null;
      notifyListeners();
      return false;
    }

    _referralOwnerName = ownerName; // e.g. "Krupal Dabi"
    _referralCodeError = null;
    notifyListeners();
    return true;
  }

  // ══════════════════════════════════════════
  // SUBMIT FORM → VERIFY REFERRAL (IF ANY) → SEND OTP (REGISTER API)
  // ══════════════════════════════════════════
  Future<bool> submitFormAndSendOtp() async {
    if (!_validateAll()) return false;

    _isLoading = true;
    notifyListeners();

    // Verify referral code first (only runs the check if user typed one).
    final referralOk = await _verifyReferralCodeIfProvided();
    if (!referralOk) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      OtherMethods.customLog(
        '📝 [RegisterController] submitFormAndSendOtp() → calling register API',
      );

      // Call POST /customers/register – dates are formatted YYYY-MM-DD inside the service.
      final RegisterModel result = await _authApiService.register(
        fullName: fullNameController.text.trim(),
        mobileNumber: mobileController.text.trim(),
        emailAddress: emailController.text.trim(),
        dob: _selectedDob!,
        anniversaryDate: _anniversarySkipped ? null : _selectedAnniversary,
        city: cityController.text.trim(),
        state: _selectedState!,
        referralCode: referralCodeController.text.trim().isEmpty
            ? null
            : referralCodeController.text.trim(),
      );

      _registerModel = result;
      _sentToMobile = mobileController.text.trim();

      // Clear any previous OTP inputs.
      for (final c in otpControllers) {
        c.clear();
      }
      _otpError = null;

      // Switch to OTP phase.
      _phase = RegisterPhase.otp;
      _startResendTimer();

      OtherMethods.customLog(
        '✅ [RegisterController] Register success → OTP phase started',
      );

      // Auto-focus first OTP field after a short delay.
      Future.delayed(const Duration(milliseconds: 300), () {
        otpFocusNodes[0].requestFocus();
      });

      return true;
    } catch (e) {
      OtherMethods.customLog(
        '❌ [RegisterController] submitFormAndSendOtp() error → $e',
      );
      // Show server error on the mobile field as a generic form-level error.
      _mobileError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════
  // RESEND OTP  →  POST /customers/resend-otp
  // ══════════════════════════════════════════
  Future<void> resendOtp() async {
    if (!_canResend) return;

    _canResend = false;
    _isLoading = true;
    notifyListeners();

    try {
      OtherMethods.customLog(
        '🔄 [RegisterController] resendOtp() → calling resend-otp API for $_sentToMobile',
      );

      // Call dedicated POST /customers/resend-otp – only needs mobile number.
      await _authApiService.resendOtp(mobileNumber: _sentToMobile);

      OtherMethods.customLog(
        '✅ [RegisterController] OTP resent successfully for $_sentToMobile',
      );

      for (final c in otpControllers) {
        c.clear();
      }
      _otpError = null;
      _startResendTimer();

      Future.delayed(const Duration(milliseconds: 300), () {
        otpFocusNodes[0].requestFocus();
      });
    } catch (e) {
      OtherMethods.customLog('❌ [RegisterController] resendOtp() error → $e');
      _otpError = e.toString().replaceFirst('Exception: ', '');
      _canResend = true; // Let user retry on failure.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════
  // VERIFY OTP → COMPLETE REGISTRATION
  // Calls POST /customers/verify-otp
  // ══════════════════════════════════════════
  Future<bool> verifyOtpAndRegister() async {
    final String entered = _enteredOtp;

    if (entered.length < 6) {
      _otpError = 'Please enter the complete 6-digit OTP';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _otpError = null;
    notifyListeners();

    try {
      OtherMethods.customLog(
        '🔑 [RegisterController] verifyOtpAndRegister() → OTP: $entered',
      );

      String? fcmToken =
          OtherMethods.getStorage(AppKeyNames.fcmToken) ??
          OtherMethods.getStorage('fcmToken');
      if (fcmToken == null || fcmToken.isEmpty) {
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && fcmToken.isNotEmpty) {
            await OtherMethods.setStorage(
              key: AppKeyNames.fcmToken,
              value: fcmToken,
            );
          }
        } catch (e) {
          OtherMethods.customLog(
            '⚠️ [RegisterController] Could not fetch FCM token from Firebase: $e',
          );
        }
      }

      // Verify the OTP using the shared auth verify-otp endpoint.
      final VerifyOtpModel result = await _authApiService.verifyOtp(
        mobileNumber: _sentToMobile,
        otp: entered,
        fcmToken: fcmToken ?? '',
      );

      _verifyOtpModel = result;

      // Persist the auth token for subsequent authenticated requests.
      if (result.token != null && result.token!.isNotEmpty) {
        await OtherMethods.setStorage(
          key: AppKeyNames.bearerToken,
          value: result.token,
        );
        OtherMethods.customLog(
          '💾 [RegisterController] Auth token saved to storage.',
        );
      }

      // Persist the refresh token.
      if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
        await OtherMethods.setStorage(
          key: AppKeyNames.refreshToken,
          value: result.refreshToken,
        );
        OtherMethods.customLog(
          '💾 [RegisterController] Refresh token saved to storage.',
        );
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
        OtherMethods.customLog(
          '💾 [RegisterController] Customer data & User ID saved to storage.',
        );
      }

      OtherMethods.customLog(
        '✅ [RegisterController] Registration complete → ${result.message}',
      );

      _isLoading = false;
      notifyListeners();

      // Navigate to main layout after successful registration.
      Get.offAll(() => MainLayoutScreen());

      return true;
    } catch (e) {
      OtherMethods.customLog(
        '❌ [RegisterController] verifyOtpAndRegister() error → $e',
      );
      _otpError = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════
  // GO BACK TO FORM
  // ══════════════════════════════════════════
  void goBackToForm() {
    _phase = RegisterPhase.form;
    _timer?.cancel();
    for (final c in otpControllers) {
      c.clear();
    }
    _otpError = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day / $month / ${date.year}';
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6B1D2E),
          onPrimary: Color(0xFFD4AF37),
          surface: Color(0xFFFDF9F0),
          onSurface: Color(0xFF2C2C2C),
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      child: child!,
    );
  }

  // ══════════════════════════════════════════
  // DISPOSE
  // ══════════════════════════════════════════
  @override
  void dispose() {
    _timer?.cancel();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    dobController.dispose();
    anniversaryController.dispose();
    cityController.dispose();
    referralCodeController.dispose();
    fullNameFocus.dispose();
    mobileFocus.dispose();
    emailFocus.dispose();
    cityFocus.dispose();
    referralCodeFocus.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════
// (End of RegisterController)
// ════════════════════════════════════════════════════════════
