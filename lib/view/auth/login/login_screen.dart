import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:unnati_jwelers/view/static_page/privecy_policy/privecy_policy_screen.dart';
import 'package:unnati_jwelers/view/static_page/terms_and_conditions/terms_and_condition_screen.dart';

import '../../../utils/app_colors.dart';
import '../register/register_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
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
      create: (_) => LoginController(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Consumer<LoginController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                // ────────── TOP BANNER IMAGE ──────────
                _BannerImage(),

                // ────────── SCROLLABLE CONTENT ──────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // ── Heading ──
                              _Heading(controller: controller),

                              const SizedBox(height: 28),

                              // ── Phase: Contact ──
                              if (controller.phase == LoginPhase.contact) ...[
                                _ContactPhase(controller: controller),
                              ],

                              // ── Phase: OTP ──
                              if (controller.phase == LoginPhase.otp) ...[
                                _OtpPhase(
                                  controller: controller,
                                  onBackToContact: () {
                                    controller.goBackToContact();
                                    _reAnimate();
                                  },
                                ),
                              ],

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// BANNER IMAGE
// ══════════════════════════════════════════════════════════
class _BannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-width image
        SizedBox(
          width: double.infinity,
          height: 240,
          child: Image.asset(
            'assets/images/login_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.maroonPrimary,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primaryGold,
                      size: 56,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Luxury Collection',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom gradient overlay for smooth fade
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.backgroundPrimary.withOpacity(0.15),
                  AppColors.backgroundPrimary.withOpacity(0.85),
                  AppColors.backgroundPrimary,
                ],
                stops: const [0.0, 0.55, 0.85, 1.0],
              ),
            ),
          ),
        ),

        // Top status bar safe area tint
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).padding.top,
            color: AppColors.maroonPrimary.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// HEADING SECTION
// ══════════════════════════════════════════════════════════
class _Heading extends StatelessWidget {
  final LoginController controller;
  const _Heading({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gold accent line
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGold, AppColors.lightGold],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.phase == LoginPhase.contact
              ? 'Welcome Back'
              : 'Verify OTP',
          style: TextStyle(
            color: AppColors.maroonPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.phase == LoginPhase.contact
              ? 'Sign in to continue your journey'
              : 'Enter the code we sent to your number',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// CONTACT PHASE
// ══════════════════════════════════════════════════════════
class _ContactPhase extends StatelessWidget {
  final LoginController controller;
  const _ContactPhase({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──
        Text(
          'Mobile Number',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),

        // ── Contact Input Field ──
        _ContactField(controller: controller),

        const SizedBox(height: 10),

        // ── Error ──
        if (controller.contactError != null)
          _ErrorText(controller.contactError!),

        const SizedBox(height: 28),

        // ── Terms & Privacy ──
        _TermsText(),

        const SizedBox(height: 20),

        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: "Don't have an account? "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      // OR
                      Get.to(() => const RegisterScreen());
                    },
                    child: Text(
                      "Register Here",
                      style: TextStyle(
                        color: AppColors.maroonPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Send OTP Button ──
        _PrimaryButton(
          label: 'Send OTP',
          isLoading: controller.isLoading,
          onTap: () => controller.sendOtp(),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final LoginController controller;
  const _ContactField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: controller.contactError != null
              ? AppColors.error
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.contactController,
        focusNode: controller.contactFocusNode,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: controller.onContactChanged,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          hintText: '98765 43210',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.contactController,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: controller.contactController.clear,
                child: Icon(
                  Icons.cancel_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// OTP PHASE
// ══════════════════════════════════════════════════════════
class _OtpPhase extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onBackToContact;
  const _OtpPhase({required this.controller, required this.onBackToContact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sent-to info card ──
        _SentToCard(
          contact: controller.sentToContact,
          otp: controller.loginModel?.otp,
          onEdit: onBackToContact,
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

        if (controller.otpError != null) _ErrorText(controller.otpError!),

        const SizedBox(height: 18),

        // ── Resend row ──
        _ResendRow(controller: controller),

        const SizedBox(height: 32),

        // ── Verify Button ──
        _PrimaryButton(
          label: 'Verify OTP',
          isLoading: controller.isLoading,
          onTap: () async {
            final success = await controller.verifyOtp();
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Login Successful!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              // TODO: Navigate to home screen
            }
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// SENT-TO CARD
// ══════════════════════════════════════════════════════════
class _SentToCard extends StatelessWidget {
  final String contact;
  final String? otp;
  final VoidCallback onEdit;
  const _SentToCard({required this.contact, this.otp, required this.onEdit});

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
                  'You have received OTP on +91 $contact',
                  style: TextStyle(
                    color: AppColors.maroonPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
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
  final LoginController controller;
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
  final LoginController controller;
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
            widget.controller.onOtpBackspace(widget.index);
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
}

// ══════════════════════════════════════════════════════════
// RESEND ROW
// ══════════════════════════════════════════════════════════
class _ResendRow extends StatelessWidget {
  final LoginController controller;
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

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.6,
            fontFamily: 'Roboto',
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our\n'),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const TermsAndConditionScreen());
                },
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: AppColors.maroonPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.maroonPrimary,
                  ),
                ),
              ),
            ),
            TextSpan(
              text: '  and  ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const PrivecyPolicyScreen());
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.maroonPrimary,
                    fontSize: 12,
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
    );
  }
}

// ══════════════════════════════════════════════════════════
// PRIMARY BUTTON
// ══════════════════════════════════════════════════════════
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,

    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
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
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: isLoading
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
                    label,
                    style: TextStyle(
                      color: AppColors.maroonDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ERROR TEXT
// ══════════════════════════════════════════════════════════
class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
