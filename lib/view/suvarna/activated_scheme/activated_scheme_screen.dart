import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';
import '../add_scheme/add_scheme_screen.dart';
import '../scheme_details/scheme_details_screen.dart';
import 'activated_scheme_controller.dart';

class ActivatedSchemeScreen extends StatelessWidget {
  const ActivatedSchemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivatedSchemeController());

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: const CustomAppBar(
        title: "My Active Schemes",
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.schemes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryMaroon,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.schemes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load schemes",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchMySchemes(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryMaroon,
          onRefresh: () async {
            await controller.fetchMySchemes();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── PORTFOLIO SUMMARY CARD ─────────────────────────────────────────
                _buildPortfolioSummary(controller),

                // ── SECTION HEADER ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Active Schemes",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMaroon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${controller.schemes.where((s) => s.isActive).length} Active",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),

                // ── LIST OF ACTIVATED SCHEMES ──────────────────────────────────────
                Obx(() {
                  if (controller.schemes.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: controller.schemes.length,
                    itemBuilder: (context, index) {
                      final scheme = controller.schemes[index];
                      return _buildSchemeCard(scheme, controller);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      }),
      // ── FLOATING START NEW SCHEME BUTTON ───────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () => Get.to(() => AddSchemeScreen()),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryMaroon,
                  AppColors.maroonLight,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMaroon.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "Activate New Scheme",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Portfolio Summary Panel ────────────────────────────────────────────────
  Widget _buildPortfolioSummary(ActivatedSchemeController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.champagneLight, // Light Champagne background
            AppColors.champagneMedium,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ESTIMATED PORTFOLIO VALUE",
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Invested",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatAmount(controller.totalInvestedAmount),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryMaroon,
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                width: 1.5,
                height: 45,
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Gold Saved",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatGrams(controller.totalGoldAccumulated),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryMaroon,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: AppColors.primaryGold.withValues(alpha: 0.2),
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Obx(() => Text(
                        "Live 24K Rate: ${controller.formatAmount(controller.liveGoldRate.value)}/g",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "ACTIVE",
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(ActivatedScheme scheme, ActivatedSchemeController controller) {
    final bool isMoney = scheme.type == 'Money';

    return GestureDetector(
      onTap: () {
        Get.to(
          () => const SchemeDetailsScreen(),
          arguments: scheme,
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.isActive ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.isActive
                ? AppColors.border.withValues(alpha: 0.6)
                : Colors.grey.shade300,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Name + Type Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.isActive ? AppColors.primaryMaroon : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "ID: ${scheme.id} · Purity: ${scheme.purity}",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: !scheme.isActive
                        ? Colors.grey.shade200
                        : isMoney
                            ? AppColors.primaryMaroon.withValues(alpha: 0.08)
                            : AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    !scheme.isActive
                        ? "DEACTIVATED"
                        : isMoney
                            ? "Invest on Money"
                            : "Invest on Gold",
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: !scheme.isActive
                          ? Colors.grey.shade700
                          : isMoney
                              ? AppColors.primaryMaroon
                              : AppColors.darkGold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Installment Info Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Installment",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    isMoney
                        ? Text(
                            controller.formatAmount(scheme.installmentAmount),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: scheme.isActive ? AppColors.textPrimary : Colors.grey.shade700,
                            ),
                          )
                        : Obx(() => Text(
                              "${scheme.installmentAmount.toStringAsFixed(2)} g (≈ ${controller.formatAmount(scheme.installmentAmount * controller.liveGoldRate.value)})",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: scheme.isActive ? AppColors.textPrimary : Colors.grey.shade700,
                              ),
                            )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Next Due Date",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      !scheme.isActive ? "Deactivated" : scheme.nextDueDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: !scheme.isActive ? Colors.grey.shade600 : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Plan Progress: ${scheme.paidInstallments}/${scheme.totalInstallments} Months",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "${(scheme.progress * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.isActive ? AppColors.primaryMaroon : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scheme.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      scheme.isActive ? AppColors.primaryGold : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),

            // Total Saved Values Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: scheme.isActive ? AppColors.primaryMaroon : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    isMoney
                        ? Text(
                            "Total Paid: ${controller.formatAmount(scheme.totalAmountPaid)}",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.isActive ? AppColors.textPrimary : Colors.grey.shade700,
                            ),
                          )
                        : Obx(() => Text(
                              "Total Paid: ${controller.formatAmount(scheme.accumulatedGold * controller.liveGoldRate.value)}",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: scheme.isActive ? AppColors.textPrimary : Colors.grey.shade700,
                              ),
                            )),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: scheme.isActive ? AppColors.primaryGold : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Gold saved: ${controller.formatGrams(scheme.accumulatedGold)}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.isActive ? AppColors.primaryMaroon : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                size: 64,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Active Schemes",
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You don't have any active Suvarna Unnati schemes. Activate a plan today to start saving in gold with live market rates.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
