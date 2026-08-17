import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unnati_jwelers/view/auth/register/register_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reAnimate() {
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.backgroundPrimary,
            appBar: CustomAppBar(
              title: controller.phase == RegisterPhase.form
                  ? 'Create Account'
                  : 'Verify Mobile',
              onBackPressed: controller.phase == RegisterPhase.otp
                  ? () {
                      controller.goBackToForm();
                      _reAnimate();
                    }
                  : () => Navigator.pop(context),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: controller.phase == RegisterPhase.form
                        ? _FormPhaseBody(
                            controller: controller,
                            onOtpSent: _reAnimate,
                          )
                        : _OtpPhaseBody(
                            controller: controller,
                            onBackToForm: () {
                              controller.goBackToForm();
                              _reAnimate();
                            },
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// FORM PHASE BODY
// ══════════════════════════════════════════════════════════
class _FormPhaseBody extends StatelessWidget {
  final RegisterController controller;
  final VoidCallback onOtpSent;

  const _FormPhaseBody({required this.controller, required this.onOtpSent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Section: Personal Info ──
        _SectionLabel(
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
        ),
        const SizedBox(height: 16),

        _FieldLabel(label: 'Full Name', required: true),
        const SizedBox(height: 8),
        _BuildTextField(
          controller: controller.fullNameController,
          focusNode: controller.fullNameFocus,
          hint: 'e.g. Priya Sharma',
          icon: Icons.badge_outlined,
          error: controller.fullNameError,
          onChanged: controller.onFullNameChanged,
          textCapitalization: TextCapitalization.words,
          nextFocus: controller.mobileFocus,
        ),

        const SizedBox(height: 20),

        _FieldLabel(label: 'Mobile Number', required: true),
        const SizedBox(height: 8),
        _MobileField(controller: controller),

        const SizedBox(height: 20),

        _FieldLabel(label: 'Email Address', required: true),
        const SizedBox(height: 8),
        _BuildTextField(
          controller: controller.emailController,
          focusNode: controller.emailFocus,
          hint: 'e.g. priya@example.com',
          icon: Icons.mail_outline_rounded,
          error: controller.emailError,
          onChanged: controller.onEmailChanged,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 32),

        // ── Section: Important Dates ──
        _SectionLabel(icon: Icons.cake_outlined, title: 'Important Dates'),
        const SizedBox(height: 16),

        _FieldLabel(label: 'Date of Birth', required: true),
        const SizedBox(height: 8),
        _DateField(
          controller: controller.dobController,
          hint: 'DD / MM / YYYY',
          icon: Icons.cake_outlined,
          error: controller.dobError,
          onTap: () => controller.pickDateOfBirth(context),
        ),

        const SizedBox(height: 20),

        _AnniversaryField(controller: controller),

        const SizedBox(height: 32),

        // ── Section: Location ──
        _SectionLabel(icon: Icons.location_on_outlined, title: 'Location'),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'City', required: true),
                  const SizedBox(height: 8),
                  _BuildTextField(
                    controller: controller.cityController,
                    focusNode: controller.cityFocus,
                    hint: 'e.g. Surat',
                    icon: Icons.location_city_outlined,
                    error: controller.cityError,
                    onChanged: controller.onCityChanged,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'State', required: true),
                  const SizedBox(height: 8),
                  _StateDropdown(controller: controller),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // ── Section: Referral (Optional) ──
        _SectionLabel(
          icon: Icons.card_giftcard_outlined,
          title: 'Referral (Optional)',
        ),
        const SizedBox(height: 16),

        _FieldLabel(label: 'Referral Code'),
        const SizedBox(height: 8),
        _ReferralCodeField(controller: controller),

        const SizedBox(height: 40),

        // ── Submit Button → Sends OTP ──
        _RegisterButton(controller: controller, onOtpSent: onOtpSent),

        const SizedBox(height: 16),

        Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              children: [
                const TextSpan(text: 'Already have an account? '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.maroonPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.maroonPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// OTP PHASE BODY
// ══════════════════════════════════════════════════════════
class _OtpPhaseBody extends StatelessWidget {
  final RegisterController controller;
  final VoidCallback onBackToForm;

  const _OtpPhaseBody({required this.controller, required this.onBackToForm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),

        // ── Sent-to info card ──
        _OtpSentCard(
          mobile: controller.sentToMobile,
          otp: controller.registerModel?.otp,
          onEdit: onBackToForm,
        ),

        const SizedBox(height: 28),

        // ── OTP label ──
        Text(
          'Enter 6-Digit OTP',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 14),

        // ── OTP Boxes ──
        _OtpBoxRow(controller: controller),

        const SizedBox(height: 10),

        if (controller.otpError != null) _ErrorWidget(controller.otpError!),

        const SizedBox(height: 18),

        // ── Resend row ──
        _ResendRow(controller: controller),

        const SizedBox(height: 32),

        // ── Verify & Complete Registration Button ──
        GestureDetector(
          onTap: controller.isLoading
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  final success = await controller.verifyOtpAndRegister();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Registration successful! Welcome aboard 🎉',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    // TODO: Navigate to home screen
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: controller.isLoading
                  ? LinearGradient(
                      colors: [
                        AppColors.buttonDisabled,
                        AppColors.buttonDisabled,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.darkGold,
                        AppColors.primaryGold,
                        AppColors.lightGold,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: controller.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
            ),
            child: controller.isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.maroonPrimary,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify & Create Account',
                        style: TextStyle(
                          color: AppColors.maroonDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.maroonPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: AppColors.maroonDark,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// OTP SENT CARD
// ══════════════════════════════════════════════════════════
class _OtpSentCard extends StatelessWidget {
  final String mobile;
  final String? otp;
  final VoidCallback onEdit;

  const _OtpSentCard({required this.mobile, this.otp, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.goldLight, AppColors.backgroundSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.maroonPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.maroonPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OTP sent successfully',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You have received OTP on +91 $mobile',
                  style: TextStyle(
                    color: AppColors.maroonPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                if (otp != null && otp!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.maroonPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'OTP: $otp',
                      style: TextStyle(
                        color: AppColors.maroonPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.maroonPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// OTP BOX ROW
// ══════════════════════════════════════════════════════════
class _OtpBoxRow extends StatelessWidget {
  final RegisterController controller;
  const _OtpBoxRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => _OtpBox(index: index, controller: controller),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final int index;
  final RegisterController controller;
  const _OtpBox({required this.index, required this.controller});

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.otpFocusNodes[widget.index].addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.controller.otpFocusNodes[widget.index].hasFocus;
    });
  }

  @override
  void dispose() {
    widget.controller.otpFocusNodes[widget.index].removeListener(
      _onFocusChange,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.controller.otpError != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 54,
      decoration: BoxDecoration(
        color: _isFocused ? AppColors.goldLight : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : _isFocused
              ? AppColors.primaryGold
              : AppColors.border,
          width: _isFocused ? 2 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace();
          }
        },
        child: TextField(
          controller: widget.controller.otpControllers[widget.index],
          focusNode: widget.controller.otpFocusNodes[widget.index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: AppColors.maroonPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            widget.controller.onOtpChanged(widget.index, value);
          },
          onTap: () {
            // Select all text so next digit replaces existing value
            final ctrl = widget.controller.otpControllers[widget.index];
            ctrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: ctrl.text.length,
            );
          },
        ),
      ),
    );
  }

  void _onBackspace() {
    final ctrl = widget.controller.otpControllers[widget.index];
    if (ctrl.text.isEmpty && widget.index > 0) {
      // Field is already empty — move focus back and clear the previous box
      widget.controller.otpFocusNodes[widget.index - 1].requestFocus();
      widget.controller.otpControllers[widget.index - 1].clear();
    } else {
      // Field has a value — clear it (the TextField handles this natively too,
      // but we also call onOtpChanged with empty string so state updates)
      ctrl.clear();
      widget.controller.onOtpChanged(widget.index, '');
    }
  }
}

// ══════════════════════════════════════════════════════════
// RESEND ROW
// ══════════════════════════════════════════════════════════
class _ResendRow extends StatelessWidget {
  final RegisterController controller;
  const _ResendRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the OTP? ",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        GestureDetector(
          onTap: controller.canResend ? controller.resendOtp : null,
          child: Text(
            controller.canResend
                ? 'Resend OTP'
                : 'Resend in ${controller.resendTimer}s',
            style: TextStyle(
              color: controller.canResend
                  ? AppColors.maroonPrimary
                  : AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: controller.canResend
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: AppColors.maroonPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// REGISTER BUTTON (Form Phase → Verifies Referral Code (if any) → Sends OTP)
// ══════════════════════════════════════════════════════════
class _RegisterButton extends StatelessWidget {
  final RegisterController controller;
  final VoidCallback onOtpSent;

  const _RegisterButton({required this.controller, required this.onOtpSent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.isLoading
          ? null
          : () async {
              FocusScope.of(context).unfocus();
              final sent = await controller.submitFormAndSendOtp();
              if (sent) onOtpSent();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: controller.isLoading
              ? LinearGradient(
                  colors: [AppColors.buttonDisabled, AppColors.buttonDisabled],
                )
              : LinearGradient(
                  colors: [
                    AppColors.darkGold,
                    AppColors.primaryGold,
                    AppColors.lightGold,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: controller.isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: controller.isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.maroonPrimary,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColors.maroonDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.maroonPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.maroonDark,
                      size: 18,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════
// SECTION LABEL
// ══════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.maroonPrimary, AppColors.maroonLight],
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.maroonPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withOpacity(0.5),
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

// ══════════════════════════════════════════════════════════
// FIELD LABEL
// ══════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '(optional)',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// GENERIC TEXT FIELD
// ══════════════════════════════════════════════════════════
class _BuildTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final String? error;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final FocusNode? nextFocus;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const _BuildTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.error,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.nextFocus,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<_BuildTextField> createState() => _BuildTextFieldState();
}

class _BuildTextFieldState extends State<_BuildTextField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _focused
                  ? AppColors.primaryGold
                  : AppColors.border,
              width: _focused ? 2 : 1.5,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onSubmitted: (_) {
              if (widget.nextFocus != null) {
                widget.nextFocus!.requestFocus();
              }
            },
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  widget.icon,
                  color: _focused
                      ? AppColors.maroonPrimary
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) _ErrorWidget(widget.error!),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// MOBILE FIELD (with +91 prefix)
// ══════════════════════════════════════════════════════════
class _MobileField extends StatefulWidget {
  final RegisterController controller;
  const _MobileField({required this.controller});

  @override
  State<_MobileField> createState() => _MobileFieldState();
}

class _MobileFieldState extends State<_MobileField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.mobileFocus.addListener(() {
      if (mounted) {
        setState(() => _focused = widget.controller.mobileFocus.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.controller.mobileError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _focused
                  ? AppColors.primaryGold
                  : AppColors.border,
              width: _focused ? 2 : 1.5,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: widget.controller.mobileController,
            focusNode: widget.controller.mobileFocus,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: widget.controller.onMobileChanged,
            onSubmitted: (_) => widget.controller.emailFocus.requestFocus(),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
            decoration: InputDecoration(
              hintText: '98765 43210',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) _ErrorWidget(widget.controller.mobileError!),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// REFERRAL CODE FIELD (Optional — verified on submit)
// ══════════════════════════════════════════════════════════
class _ReferralCodeField extends StatefulWidget {
  final RegisterController controller;
  const _ReferralCodeField({required this.controller});

  @override
  State<_ReferralCodeField> createState() => _ReferralCodeFieldState();
}

class _ReferralCodeFieldState extends State<_ReferralCodeField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.referralCodeFocus.addListener(() {
      if (mounted) {
        setState(() => _focused = widget.controller.referralCodeFocus.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final bool hasError = controller.referralCodeError != null;
    final bool isVerified = controller.referralOwnerName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isVerified
                  ? AppColors.success
                  : _focused
                  ? AppColors.primaryGold
                  : AppColors.border,
              width: _focused || isVerified ? 2 : 1.5,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: controller.referralCodeController,
            focusNode: controller.referralCodeFocus,
            textCapitalization: TextCapitalization.characters,
            onChanged: controller.onReferralCodeChanged,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
            decoration: InputDecoration(
              // Demo hint shows an example referral, e.g. from Krupal Dabi
              hintText: 'e.g. KRUPAL100 (referral from Krupal Dabi)',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.card_giftcard_outlined,
                  color: isVerified
                      ? AppColors.success
                      : _focused
                      ? AppColors.maroonPrimary
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
              suffixIcon: controller.isVerifyingReferral
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGold,
                          ),
                        ),
                      ),
                    )
                  : isVerified
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) _ErrorWidget(controller.referralCodeError!),
        if (isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Referral applied — referred by ${controller.referralOwnerName}',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// DATE FIELD
// ══════════════════════════════════════════════════════════
class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? error;
  final VoidCallback onTap;

  const _DateField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = controller.text.isNotEmpty;
    final bool hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : hasValue
                    ? AppColors.primaryGold.withOpacity(0.6)
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    icon,
                    color: hasValue
                        ? AppColors.maroonPrimary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontSize: controller.text.isEmpty ? 14 : 15,
                      fontWeight: controller.text.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: hasValue
                        ? AppColors.primaryGold
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) _ErrorWidget(error!),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// ANNIVERSARY FIELD
// ══════════════════════════════════════════════════════════
class _AnniversaryField extends StatelessWidget {
  final RegisterController controller;
  const _AnniversaryField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Anniversary Date'),
        const SizedBox(height: 8),
        AnimatedOpacity(
          opacity: controller.anniversarySkipped ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: controller.anniversarySkipped,
            child: _DateField(
              controller: controller.anniversaryController,
              hint: 'DD / MM / YYYY',
              icon: Icons.favorite_border_rounded,
              onTap: () => controller.pickAnniversaryDate(context),
            ),
          ),
        ),
        if (controller.anniversarySkipped)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Anniversary date will not be saved.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// STATE DROPDOWN
// ══════════════════════════════════════════════════════════
class _StateDropdown extends StatelessWidget {
  final RegisterController controller;
  const _StateDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool hasError = controller.stateError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showStateSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : controller.selectedState != null
                    ? AppColors.primaryGold.withOpacity(0.6)
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: controller.selectedState != null
                      ? AppColors.maroonPrimary
                      : AppColors.textTertiary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.selectedState ?? 'Select State',
                    style: TextStyle(
                      color: controller.selectedState != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontSize: 14,
                      fontWeight: controller.selectedState != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: controller.selectedState != null
                      ? AppColors.primaryGold
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (hasError) _ErrorWidget(controller.stateError!),
      ],
    );
  }

  void _showStateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatePickerSheet(
        selectedState: controller.selectedState,
        onSelected: (state) {
          controller.selectState(state);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// STATE PICKER BOTTOM SHEET
// ══════════════════════════════════════════════════════════
class _StatePickerSheet extends StatefulWidget {
  final String? selectedState;
  final void Function(String) onSelected;

  const _StatePickerSheet({
    required this.selectedState,
    required this.onSelected,
  });

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  String _query = '';

  List<String> get _filtered => RegisterController.indianStates
      .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: AppColors.maroonPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Select State',
                    style: TextStyle(
                      color: AppColors.maroonPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search state...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final state = _filtered[i];
                  final bool isSelected = state == widget.selectedState;
                  return InkWell(
                    onTap: () => widget.onSelected(state),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.goldLight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primaryGold.withOpacity(0.4),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.maroonPrimary
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              state,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.maroonPrimary
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ERROR WIDGET
// ══════════════════════════════════════════════════════════
class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
