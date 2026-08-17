import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import 'add_scheme_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddSchemeScreen extends StatelessWidget {
  AddSchemeScreen({super.key});

  final AddSchemeController addSchemeController = Get.put(
    AddSchemeController(),
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryMaroon,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _HorizontalStepper(controller: addSchemeController),
            Expanded(child: Obx(() => _stepContent())),
            _BottomBar(controller: addSchemeController),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
    ),
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: AppColors.textWhite,
        size: 20,
      ),
      onPressed: () => Get.back(),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Suvarna Unnati',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
        ),
        Text(
          'Premium Gold Investment Scheme',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.lightGold.withOpacity(0.85),
          ),
        ),
      ],
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.show_chart_rounded,
              color: AppColors.primaryGold,
              size: 14,
            ),
            const SizedBox(width: 4),
            Obx(
              () => Text(
                '₹${addSchemeController.liveGoldRate.value.toStringAsFixed(2)}/g',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _stepContent() {
    switch (addSchemeController.currentStep.value) {
      case 0:
        return _Step1(controller: addSchemeController);
      case 1:
        return _Step2(controller: addSchemeController);
      case 2:
        return _Step3(controller: addSchemeController);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal Stepper
// ─────────────────────────────────────────────────────────────────────────────
class _HorizontalStepper extends StatelessWidget {
  final AddSchemeController controller;

  const _HorizontalStepper({required this.controller});

  static const List<String> _labels = [
    "Investment\nType",
    "Customer\nDetails",
    "Plan\nDetails",
  ];

  static const List<IconData> _icons = [
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
    Icons.auto_graph_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStep = controller.currentStep.value;

      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            /// Connector Line
            Positioned(
              top: 22,
              left: 45,
              right: 45,
              child: Container(height: 2, color: AppColors.dividerLight),
            ),

            /// Steps
            Row(
              children: List.generate(_labels.length, (index) {
                final isActive = index == currentStep;
                final isCompleted = index < currentStep;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (index <= currentStep) {
                        controller.goToStep(index);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: (isActive || isCompleted)
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.primaryGold,
                                      AppColors.darkGold,
                                    ],
                                  )
                                : null,
                            color: !(isActive || isCompleted)
                                ? AppColors.buttonDisabled
                                : null,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryGold.withOpacity(
                                        .30,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : Icon(
                                    _icons[index],
                                    size: 20,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Label
                        Text(
                          _labels[index],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.darkGold
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Investment Type
// ─────────────────────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final AddSchemeController controller;
  const _Step1({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Choose Investment Type',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryMaroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select how you wish to invest in Suvarna Unnati',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Segmented Toggle
          _SegmentedToggle(controller: controller),
          const SizedBox(height: 20),

          // Plan Tenure Toggle (10 Months vs 20 Months)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryMaroon.withValues(alpha: 0.1),
              ),
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.onDurationChanged(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.selectedDuration.value == 10
                            ? AppColors.primaryMaroon
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '10 Months Tenure',
                        style: GoogleFonts.poppins(
                          color: controller.selectedDuration.value == 10
                              ? Colors.white
                              : AppColors.primaryMaroon,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.onDurationChanged(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.selectedDuration.value == 20
                            ? AppColors.primaryMaroon
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '20 Months Tenure',
                        style: GoogleFonts.poppins(
                          color: controller.selectedDuration.value == 20
                              ? Colors.white
                              : AppColors.primaryMaroon,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
          const SizedBox(height: 20),

          // Info card switches based on selection
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: a, child: c),
              ),
              child: controller.isMoneyInvestment
                  ? _MoneyInfoCard(key: const ValueKey('money'), controller: controller)
                  : _GoldInfoCard(key: const ValueKey('gold'), controller: controller),
            ),
          ),

          const SizedBox(height: 20),

          // Live rate chip
          Obx(() => _LiveRateBanner(rate: controller.liveGoldRate.value)),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final AddSchemeController controller;
  const _SegmentedToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Obx(
        () => Row(
          children: [
            _ToggleOption(
              label: 'Invest On Money',
              icon: Icons.currency_rupee_rounded,
              selected: controller.investmentTypeIndex.value == 0,
              onTap: () => controller.setInvestmentType(0),
            ),
            _ToggleOption(
              label: 'Invest On Gold',
              icon: Icons.local_atm_rounded,
              selected: controller.investmentTypeIndex.value == 1,
              onTap: () => controller.setInvestmentType(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.goldGradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? AppColors.maroonDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.maroonDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyInfoCard extends StatelessWidget {
  final AddSchemeController controller;
  const _MoneyInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.currency_rupee_rounded,
                  color: AppColors.darkGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Money-Based Investment',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    Text(
                      'Save money regularly & get premium maturity bonus',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoPoint(
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.success,
            title: 'Fixed Monthly Savings',
            desc: 'Save a constant Rupee amount every month (minimum ₹5,000)',
          ),
          const SizedBox(height: 10),
          _InfoPoint(
            icon: Icons.trending_flat_rounded,
            color: AppColors.darkGold,
            title: 'No Market Volatility Risk',
            desc:
                'Your payments accumulate safely in Rupees without gold rate drops risk during tenure',
          ),
          const SizedBox(height: 10),
          _InfoPoint(
            icon: Icons.card_giftcard_rounded,
            color: AppColors.primaryMaroon,
            title: '1-Month Cash Bonus',
            desc:
                'For 10 months tenure, Unnati contributes the 11th month worth of installment as a bonus',
          ),
          const SizedBox(height: 18),
          _MoneyMaturityCard(controller: controller),
        ],
      ),
    );
  }
}

class _GoldInfoCard extends StatelessWidget {
  final AddSchemeController controller;
  const _GoldInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      accentGold: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_atm_rounded,
                  color: AppColors.maroonDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gold-Based Investment',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    Text(
                      'Fixed gold quantity, dynamic value',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoPoint(
            icon: Icons.lock_rounded,
            color: AppColors.darkGold,
            title: 'Gold Caret & Grams Fixed',
            desc: 'You commit to buying a fixed quantity every installment',
          ),
          const SizedBox(height: 10),
          _InfoPoint(
            icon: Icons.sync_rounded,
            color: AppColors.primaryMaroon,
            title: 'Investment Value Changes',
            desc: 'Amount you pay per installment moves with live gold rate',
          ),
          const SizedBox(height: 18),
          _GoldMaturityCard(controller: controller),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Money Maturity Summary Card  (Reactive Obx)
// ─────────────────────────────────────────────────────────────────────────────
class _MoneyMaturityCard extends StatelessWidget {
  final AddSchemeController controller;
  const _MoneyMaturityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double rate = controller.liveGoldRate.value > 0 ? controller.liveGoldRate.value : 7245.50;
      final int tenure = controller.selectedDuration.value;
      final int bonusMonths = tenure ~/ 10;
      final int totalMonths = tenure + bonusMonths;
      
      final String rawAmountText = controller.amountController.text.replaceAll(',', '').trim();
      final double monthlyAmount = (double.tryParse(rawAmountText) ?? 0) > 0
          ? double.parse(rawAmountText)
          : 10000;
      
      final double monthlyGrams = monthlyAmount / rate;
      final double totalPaid = monthlyAmount * tenure;
      final double bonusAmount = monthlyAmount * bonusMonths;
      final double totalMaturityAmount = monthlyAmount * totalMonths;
      final double totalMaturityGrams = monthlyGrams * totalMonths;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: AppColors.maroonDark,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Maturity Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Body rows
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  _MaturityRow(
                    label: 'Monthly Installment',
                    value: controller.formatAmount(monthlyAmount),
                    icon: Icons.payments_rounded,
                    iconColor: AppColors.darkGold,
                  ),
                  const _MaturityDivider(),
                  _MaturityRow(
                    label: 'Tenure',
                    value: '$tenure Months',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primaryMaroon,
                  ),
                  const _MaturityDivider(),
                  _MaturityRow(
                    label: 'Total Paid by You',
                    value: controller.formatAmount(totalPaid),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.textSecondary,
                  ),
                  const _MaturityDivider(),
                  // Bonus row with green highlight
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Unnati Bonus ($bonusMonths Month${bonusMonths > 1 ? "s" : ""})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        Text(
                          '+ ${controller.formatAmount(bonusAmount)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: AppColors.border,
            ),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Redeemable Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.lightGold,
                          ),
                        ),
                        Text(
                          controller.formatAmount(totalMaturityAmount),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        Text(
                          '≈ ${totalMaturityGrams.toStringAsFixed(2)}g at ₹${rate.toStringAsFixed(0)}/g',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.lightGold.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+10% Bonus',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold Maturity Summary Card  (Reactive Obx)
// ─────────────────────────────────────────────────────────────────────────────
class _GoldMaturityCard extends StatelessWidget {
  final AddSchemeController controller;
  const _GoldMaturityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double rate = controller.effectiveRate > 0 ? controller.effectiveRate : 7245.50;
      final int tenure = controller.selectedDuration.value;
      final int bonusMonths = tenure ~/ 10;
      final int totalMonths = tenure + bonusMonths;
      
      final String rawAmountText = controller.amountController.text.replaceAll(',', '').trim();
      final double monthlyAmount = (double.tryParse(rawAmountText) ?? 0) > 0
          ? double.parse(rawAmountText)
          : 10000;

      final double monthlyGrams = monthlyAmount / rate;
      final double totalGramsSaved = monthlyGrams * tenure;
      final double totalPaid = monthlyAmount * tenure;
      final double bonusGrams = monthlyGrams * bonusMonths;
      final double bonusAmount = monthlyAmount * bonusMonths;
      final double totalMaturityGrams = monthlyGrams * totalMonths;
      final double totalMaturityAmount = monthlyAmount * totalMonths;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryMaroon.withValues(alpha: 0.06),
                    AppColors.primaryGold.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: AppColors.maroonDark,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Maturity Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Body rows
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  _MaturityRow(
                    label: 'Monthly Installment (₹)',
                    value: controller.formatAmount(monthlyAmount),
                    icon: Icons.payments_rounded,
                    iconColor: AppColors.darkGold,
                  ),
                  const _MaturityDivider(),
                  _MaturityRow(
                    label: 'Monthly Gold Saved',
                    value: '${monthlyGrams.toStringAsFixed(2)} g (≈ ${controller.formatAmount(monthlyAmount)})',
                    icon: Icons.local_atm_rounded,
                    iconColor: AppColors.darkGold,
                  ),
                  const _MaturityDivider(),
                  _MaturityRow(
                    label: 'Tenure (Regular Accumulations)',
                    value: '$tenure Months',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primaryMaroon,
                  ),
                  const _MaturityDivider(),
                  _MaturityRow(
                    label: 'Total Gold Saved by You',
                    value: '${totalGramsSaved.toStringAsFixed(2)} g (≈ ${controller.formatAmount(totalPaid)})',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.textSecondary,
                  ),
                  const _MaturityDivider(),
                  // Bonus row — 1 or 2 months
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Unnati Bonus ($bonusMonths Month${bonusMonths > 1 ? "s" : ""})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        Text(
                          '+ ${bonusGrams.toStringAsFixed(2)} g (≈ ${controller.formatAmount(bonusAmount)})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: AppColors.border,
            ),

            // Total footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Maturity Gold Qty',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.lightGold,
                          ),
                        ),
                        Text(
                          '${totalMaturityGrams.toStringAsFixed(2)} grams',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        Text(
                          '≈ ${controller.formatAmount(totalMaturityAmount)} at ₹${rate.toStringAsFixed(0)}/g',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.lightGold.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+10% Gold',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers for the maturity cards
// ─────────────────────────────────────────────────────────────────────────────
class _MaturityRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MaturityRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaturityDivider extends StatelessWidget {
  const _MaturityDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFFEEEEEE),
      height: 1,
      thickness: 1,
    );
  }
}

class _InfoPoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _InfoPoint({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isHeader;

  const _CalcRow(
    this.label,
    this.value, {
    this.highlight = false,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    // Header Row
    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Normal Row
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Value
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight
                    ? AppColors.primaryMaroon
                    : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveRateBanner extends StatelessWidget {
  final double rate;
  const _LiveRateBanner({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.show_chart_rounded,
            color: AppColors.primaryGold,
            size: 22,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Gold Rate (24K)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.lightGold,
                ),
              ),
              Text(
                '₹${rate.toStringAsFixed(2)} / gram',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.greenAccent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Customer Details
// ─────────────────────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final AddSchemeController controller;
  const _Step2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Form(
        key: controller.step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
            Text(
              'Fill in the customer\'s KYC information below',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            _PremiumCard(
              child: Column(
                children: [
                  _PremiumField(
                    controller: controller.nameController,
                    label: 'Customer Name',
                    hint: 'Enter full name',
                    icon: Icons.person_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (val.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PremiumField(
                    controller: controller.emailController,
                    label: 'Email Address',
                    hint: 'customer@example.com',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$');
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PremiumField(
                    controller: controller.addressController,
                    label: 'Full Address',
                    hint: 'Enter full address',
                    icon: Icons.home_rounded,
                    maxLines: 3,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Address is required';
                      }
                      if (val.trim().length < 10) {
                        return 'Address must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  // ─── Aadhaar Number (custom always-visible prefix) ───
                  _AadhaarField(controller: controller),
                  // ─── PAN Card Number (custom always-visible prefix, 4-digit editable) ───
                  _PanField(controller: controller),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // OTP section
            _OtpSection(controller: controller),

            const SizedBox(height: 16),

            // Camera capture
            _CameraSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aadhaar Field – always-visible XXXX XXXX prefix
// ─────────────────────────────────────────────────────────────────────────────
class _AadhaarField extends StatelessWidget {
  final AddSchemeController controller;
  const _AadhaarField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Aadhaar Number',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        FormField<String>(
          validator: (_) {
            final raw = controller.rawAadhar.trim();
            if (raw.isEmpty) return 'Aadhaar number is required';
            if (raw.length != 4) return 'Enter last 4 digits of Aadhaar';
            return null;
          },
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.border,
                    width: state.hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.darkGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    // ── Always-visible masked prefix ──
                    Text(
                      'XXXX XXXX',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 22,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 8),
                    // ── Editable 4-digit input ──
                    Expanded(
                      child: TextFormField(
                        controller: controller.aadharController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) {
                          controller.rawAadhar = val.trim();
                          state.didChange(val);
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                          letterSpacing: 4,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '_ _ _ _',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            letterSpacing: 4,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    state.errorText!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.error,
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

class _PanField extends StatelessWidget {
  final AddSchemeController controller;
  const _PanField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'PAN Card Number',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        FormField<String>(
          validator: (_) {
            final raw = controller.rawPan.trim();
            if (raw.isEmpty) return 'PAN card number is required';
            if (raw.length != 4) return 'Enter last 4 characters of PAN';
            return null;
          },
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.border,
                    width: state.hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.badge_rounded,
                      color: AppColors.darkGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    // ── Always-visible masked prefix ──
                    Text(
                      'XXXXXX',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 22,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 8),
                    // ── Editable 4-character input ──
                    Expanded(
                      child: TextFormField(
                        controller: controller.panController,
                        keyboardType: TextInputType.text,
                        maxLength: 4,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        ],
                        onChanged: (val) {
                          final upper = val.trim().toUpperCase();
                          controller.rawPan = upper;
                          state.didChange(upper);
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                          letterSpacing: 4,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '_ _ _ _',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            letterSpacing: 4,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    state.errorText!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.error,
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

class _OtpSection extends StatelessWidget {
  final AddSchemeController c;

  const _OtpSection({required this.controller}) : c = controller;

  final AddSchemeController controller;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Verification',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryMaroon,
            ),
          ),

          const SizedBox(height: 14),

          /// MOBILE + SEND OTP
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _PremiumField(
                    controller: c.mobileController,
                    label: 'Mobile Number',
                    hint: '10-digit mobile number',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,

                    /// Disable after OTP sent
                    enabled: !c.otpSent.value,
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 110,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (c.otpSent.value && !c.otpVerified.value)
                        ? null
                        : c.sendOtp,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: c.otpVerified.value
                            ? const LinearGradient(
                                colors: [AppColors.success, AppColors.success],
                              )
                            : AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: c.isOtpLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : c.otpVerified.value
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                c.otpSent.value ? 'Sent' : 'Send OTP',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.maroonDark,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// OTP SECTION
          Obx(
            () => c.otpSent.value && !c.otpVerified.value
                ? Column(
                    children: [
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: c.otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 8,
                                color: AppColors.primaryMaroon,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '• • • • • •',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textTertiary,
                                  letterSpacing: 6,
                                ),
                                filled: true,
                                fillColor: AppColors.goldLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryGold,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: c.verifyOtp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: c.isOtpLoading.value
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Verify',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Obx(
                        () => Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              c.otpCountdown.value > 0
                                  ? 'Resend OTP in ${c.otpCountdown.value}s'
                                  : 'Didn\'t receive OTP?',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (c.otpCountdown.value == 0) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: c.resendOtp,
                                child: Text(
                                  'Resend',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          /// VERIFIED SUCCESS
          Obx(
            () => c.otpVerified.value
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mobile number verified successfully',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CameraSection extends StatelessWidget {
  final AddSchemeController c;
  const _CameraSection({required this.controller}) : c = controller;
  final AddSchemeController controller;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.darkGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Customer Photo',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMaroon,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Live Camera Only',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => c.capturedImage.value != null
                ? _ImagePreview(
                    file: c.capturedImage.value!,
                    onRetake: c.retakePhoto,
                  )
                : _CameraPlaceholder(
                    isLoading: c.isCapturing.value,
                    onCapture: c.capturePhoto,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCapture;
  const _CameraPlaceholder({required this.isLoading, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onCapture,
      child: Center(
        child: Container(
          width: 180,
          height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundSecondary,
                AppColors.primaryGold.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.5),
              width: 1.5,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                    strokeWidth: 2,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Face silhouette outline
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: AppColors.maroonDark,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Take Selfie',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Front camera opens automatically',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tap indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_rounded,
                              color: AppColors.maroonDark, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'Tap to Capture',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.maroonDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final dynamic file; // File
  final VoidCallback onRetake;
  const _ImagePreview({required this.file, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 180,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                file,
                width: 180,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onRetake,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.replay_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Captured',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 – Plan Details
// ─────────────────────────────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final AddSchemeController controller;
  const _Step3({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
            Text(
              controller.isMoneyInvestment
                  ? 'Enter investment amount and gold purity'
                  : 'Enter gold quantity and purity',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Caret Dropdown
            if (!controller.isMoneyInvestment) ...[
              _PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gold Purity (Caret)',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.backgroundSecondary,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedCaret.value,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.darkGold,
                          ),
                          onChanged: controller.onCaretChanged,
                          items: controller.caretOptions
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryGold,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$c Gold',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${(controller.liveGoldRate.value * (controller.caretMultiplier[c] ?? 1)).toStringAsFixed(2)}/g',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _CaretRateRow(controller: controller),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            _PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Configuration',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// PLAN DURATION
                  Text(
                    'Plan Duration',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMaroon.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryMaroon.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.onDurationChanged(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: controller.selectedDuration.value == 10
                                    ? AppColors.primaryMaroon
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '10 Months',
                                style: GoogleFonts.poppins(
                                  color: controller.selectedDuration.value == 10
                                      ? Colors.white
                                      : AppColors.primaryMaroon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.onDurationChanged(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: controller.selectedDuration.value == 20
                                    ? AppColors.primaryMaroon
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '20 Months',
                                style: GoogleFonts.poppins(
                                  color: controller.selectedDuration.value == 20
                                      ? Colors.white
                                      : AppColors.primaryMaroon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Amount input
            _PremiumCard(child: _MoneyInput(controller: controller)),

            const SizedBox(height: 16),
            // Note card
            _NoteCard(isMoneyInvestment: controller.isMoneyInvestment),
          ],
        ),
      ),
    );
  }
}

class _CaretRateRow extends StatelessWidget {
  final AddSchemeController controller;
  const _CaretRateRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rate = controller.effectiveRate;
      final caret = controller.selectedCaret.value;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.goldLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_rounded, size: 14, color: AppColors.darkGold),
            const SizedBox(width: 8),
            Text(
              'Current $caret rate: ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '₹${rate.toStringAsFixed(2)}/g',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGold,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MoneyInput extends StatelessWidget {
  final AddSchemeController c;
  const _MoneyInput({required this.controller}) : c = controller;
  final AddSchemeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Amount',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: c.amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryMaroon,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Text(
                '₹',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMaroon,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            hintText: '0',
            hintStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGold,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final bool isMoneyInvestment;
  const _NoteCard({required this.isMoneyInvestment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.darkGold,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isMoneyInvestment
                      ? 'Your monthly payments accumulate in Rupees. At maturity, you can redeem the total value plus bonus for any jewelry of your choice.'
                      : 'Your monthly payment is converted to gold grams each month using that day\'s prevailing live rate. At maturity, you will get the total accumulated gold grams plus bonus.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _BottomBar extends StatelessWidget {
  final AddSchemeController c;
  const _BottomBar({required this.controller}) : c = controller;
  final AddSchemeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Obx(() {
        final step = c.currentStep.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary chip row
            if (step == 2) _SummaryRow(controller: c),
            if (step == 2) const SizedBox(height: 12),

            // Navigation buttons
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: c.previousStep,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Back',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (step < 2) {
                        c.nextStep();
                      } else {
                        _showSubmitConfirmationDialog(context, c);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            step == 2 ? 'Submit Scheme' : 'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.maroonDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            step == 2
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: AppColors.maroonDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final AddSchemeController c;
  const _SummaryRow({required this.controller}) : c = controller;
  final AddSchemeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryMaroon.withOpacity(0.06),
            AppColors.primaryGold.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Obx(() {
        return Row(
          children: [
            _SummaryChip(
              label: 'Type',
              value: c.isMoneyInvestment ? 'Money' : 'Gold',
              icon: c.isMoneyInvestment
                  ? Icons.currency_rupee_rounded
                  : Icons.local_atm_rounded,
            ),
            if (!c.isMoneyInvestment) ...[
              _Vdivider(),
              _SummaryChip(
                label: 'Caret',
                value: c.selectedCaret.value,
                icon: Icons.diamond_rounded,
              ),
            ],
            _Vdivider(),
            _SummaryChip(
              label: 'Amount',
              value: c.amountController.text.isNotEmpty
                  ? '₹${c.amountController.text}'
                  : '–',
              icon: Icons.calculate_rounded,
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.darkGold),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryMaroon,
            ),
          ),
        ],
      ),
    );
  }
}

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.border);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumCard extends StatelessWidget {
  final Widget child;
  final bool accentGold;
  const _PremiumCard({required this.child, this.accentGold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentGold
              ? AppColors.primaryGold.withOpacity(0.4)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (accentGold)
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          enabled: enabled,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(icon, color: AppColors.darkGold, size: 20),
            filled: true,
            fillColor: enabled
                ? AppColors.backgroundSecondary
                : AppColors.backgroundSecondary.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGold,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.error,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formatters for KYC Fields
// ─────────────────────────────────────────────────────────────────────────────

class PanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length > 10) {
      return oldValue;
    }
    // Allow only letters and numbers
    if (text.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text)) {
      return oldValue;
    }
    final upper = text.toUpperCase();
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold Gradient Extension (referenced above but defined in AppColors)
// ─────────────────────────────────────────────────────────────────────────────
extension _GoldGradientExt on AppColors {
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.lightGold, AppColors.primaryGold, AppColors.darkGold],
  );
}

// ── SUBMIT SCHEME CONFIRMATION DIALOG (FULL SCREEN PREVIEW) ──────────────────
void _showSubmitConfirmationDialog(
  BuildContext context,
  AddSchemeController c,
) {
  bool isAccepted = false;
  showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: false, // Ensure full screen display
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog.fullscreen(
            backgroundColor: AppColors.backgroundPrimary,
            child: Scaffold(
              backgroundColor: AppColors.backgroundPrimary,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundPrimary,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryMaroon,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                title: Text(
                  "Terms & Privacy",
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primaryMaroon,
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          "Please review the terms and conditions below before proceeding:",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _dialogSectionTitle("1. Acceptance of Terms"),
                        _dialogSectionContent(
                          "By accessing, browsing, or using the Unnati Jewelers mobile application, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, please discontinue use immediately.",
                        ),
                        const SizedBox(height: 20),

                        _dialogSectionTitle("2. Gold Scheme Membership Rules"),
                        _dialogSectionContent(
                          "Our monthly Suvarna Gold Scheme is subject to showroom rules: Installments must be paid on or before the specified due date of every month. Gold rate conversion will be calculated based on the prevailing showroom market rate at the exact time of transaction confirmation. Scheme maturity periods, discount values, and jewelry design choices are fixed per showroom policies and cannot be altered mid-term.",
                        ),
                        const SizedBox(height: 20),

                        _dialogSectionTitle("3. User Accounts & Security"),
                        _dialogSectionContent(
                          "You are responsible for maintaining the confidentiality of your mobile login OTPs and active account credentials. You agree to notify Unnati Jewelers immediately of any unauthorized use of your profile. Accounts are non-transferable.",
                        ),
                        const SizedBox(height: 20),

                        _dialogSectionTitle(
                          "4. Installment Payments & Gateway Charges",
                        ),
                        _dialogSectionContent(
                          "All online scheme payments are processed through secure third-party payment gateways. Unnati Jewelers is not liable for transaction failures, delayed credits, bank chargebacks, or processing fees. In case of payment disputes, please present your bank transaction receipts.",
                        ),
                        const SizedBox(height: 20),

                        _dialogSectionTitle("5. Disclaimer of Liability"),
                        _dialogSectionContent(
                          "Gold and silver market rates are subject to high volatility. Unnati Jewelers does not guarantee financial profit or lock-in rates outside the specified boundaries of the Suvarna Scheme. The app is provided on an 'as-is' basis without warranties.",
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Bottom action sheet
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      border: const Border(
                        top: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Checkbox row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: isAccepted,
                                  activeColor: AppColors.primaryMaroon,
                                  checkColor: Colors.white,
                                  onChanged: (val) {
                                    setState(() {
                                      isAccepted = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isAccepted = !isAccepted;
                                    });
                                  },
                                  child: Text(
                                    "I have read and agree to all Suvarna Gold Scheme terms and conditions.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    "Decline",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isAccepted
                                      ? () {
                                          Navigator.of(ctx).pop(); // close dialog
                                          c.submitScheme(); // trigger submission
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryMaroon,
                                    disabledBackgroundColor:
                                        AppColors.primaryMaroon.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    "I Accept",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isAccepted
                                          ? Colors.white
                                          : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _dialogSectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryMaroon,
    ),
  );
}

Widget _dialogSectionContent(String content) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      content,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    ),
  );
}
