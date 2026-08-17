import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';
import 'scheme_details_controller.dart';

class SchemeDetailsScreen extends StatelessWidget {
  const SchemeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SchemeDetailsController());
    final scheme = controller.scheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: "Scheme Details",
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Export & Share Report",
            onPressed: () => controller.exportAndShareReport(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SCHEME CARD INFORMATION ───────────────────────────────────
              _buildSchemeHeaderCard(controller, scheme),

              const SizedBox(height: 24),

              // ── PAYMENT DETAILS HEADER ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Payment Installments",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),

              // ── UNIFIED PAYMENTS LIST ──────────────────────────────────────
              Obx(() {
                if (controller.isLoadingDetails.value && controller.installments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: AppColors.primaryMaroon),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.installments.length,
                  itemBuilder: (context, index) {
                    final item = controller.installments[index];
                    final bool isPaid = item.status == 'Paid';
                    final bool isPayable = item.status == 'Payable' && controller.scheme.canPayNextInstallment;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.white
                            : isPayable
                            ? AppColors.goldLight
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPaid
                              ? AppColors.border.withValues(alpha: 0.4)
                              : isPayable
                              ? AppColors.primaryGold
                              : AppColors.border.withValues(alpha: 0.8),
                          width: isPayable ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon Status Indicator
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : isPayable
                                  ? AppColors.primaryGold.withValues(alpha: 0.15)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPaid
                                  ? Icons.check_circle_rounded
                                  : isPayable
                                  ? Icons.payment_rounded
                                  : Icons.schedule_rounded,
                              color: isPaid
                                  ? AppColors.success
                                  : isPayable
                                  ? AppColors.primaryMaroon
                                  : AppColors.warning,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Installment #${item.number}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid
                                        ? AppColors.textPrimary
                                        : isPayable
                                        ? AppColors.primaryMaroon
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isPayable ? "Payable Now" : (isPaid ? "Paid: ${item.date}" : "Pending"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: isPayable
                                        ? AppColors.primaryGold
                                        : isPaid
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight: isPayable ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price and Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                controller.formatAmount(item.amount),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid
                                      ? AppColors.primaryMaroon
                                      : isPayable
                                      ? AppColors.primaryMaroon
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPaid
                                    ? "+${controller.formatGrams(item.goldGrams)}"
                                    : "${controller.formatGrams(item.goldGrams)} (Est.)",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isPaid
                                      ? AppColors.success
                                      : isPayable
                                      ? AppColors.primaryGold
                                      : AppColors.textTertiary,
                                ),
                              ),
                              if (isPayable && controller.scheme.isActive) ...[
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => controller.payInstallment(item.number),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryMaroon,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Pay Now",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (isPaid) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.download_rounded,
                                color: AppColors.primaryMaroon,
                                size: 20,
                              ),
                              tooltip: "Download PDF Receipt",
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => controller.generateAndShareInstallmentReceipt(item),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 12),

              // ── DEACTIVATE SCHEME BUTTON ───────────────────────────────────
              if (controller.scheme.isActive)
                _buildDeactivateButton(context, controller),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Card ────────────────────────────────────────────────────────────
  Widget _buildSchemeHeaderCard(SchemeDetailsController controller, dynamic scheme) {
    final bool isMoney = scheme.type == 'Money';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${scheme.id} · Purity: ${scheme.purity}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMoney
                      ? AppColors.primaryMaroon.withValues(alpha: 0.08)
                      : AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isMoney ? "Invest on Money" : "Invest on Gold",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isMoney ? AppColors.primaryMaroon : AppColors.darkGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL AMOUNT PAID",
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    isMoney
                        ? Text(
                      controller.formatAmount(scheme.totalAmountPaid),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    )
                        : Obx(() => Text(
                      controller.formatAmount(scheme.accumulatedGold * controller.liveGoldRate.value),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    )),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: AppColors.divider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GOLD ACCUMULATED",
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatGrams(scheme.accumulatedGold),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Installment:",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              isMoney
                  ? Text(
                controller.formatAmount(scheme.installmentAmount),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
                  : Obx(() => Text(
                "${scheme.installmentAmount.toStringAsFixed(2)} g (≈ ${controller.formatAmount(scheme.installmentAmount * controller.liveGoldRate.value)})",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Completed Months:",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                "${scheme.paidInstallments} / ${scheme.totalInstallments} Months",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Deactivate Button ──────────────────────────────────────────────────────
  Widget _buildDeactivateButton(BuildContext context, SchemeDetailsController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: OutlinedButton.icon(
        onPressed: () => _showDeactivateDialog(context, controller),
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: Text(
          "Deactivate Scheme",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Confirmation Modal (GetX dialog, reason required) ──────────────────────
  void _showDeactivateDialog(BuildContext context, SchemeDetailsController controller) {
    Get.dialog(
      _DeactivateSchemeDialog(controller: controller),
      barrierDismissible: false,
    );
  }
}

// ── Deactivate Confirmation Dialog Widget ─────────────────────────────────────
// This is its own StatefulWidget so the TextEditingController is owned and
// disposed by Flutter's normal widget lifecycle (only after the dialog is
// fully removed from the tree). Uses Get.dialog / Get.back consistently with
// the rest of the app's GetX navigation to avoid overlay/navigator conflicts.
class _DeactivateSchemeDialog extends StatefulWidget {
  final SchemeDetailsController controller;

  const _DeactivateSchemeDialog({required this.controller});

  @override
  State<_DeactivateSchemeDialog> createState() => _DeactivateSchemeDialogState();
}

class _DeactivateSchemeDialogState extends State<_DeactivateSchemeDialog> {
  late final TextEditingController _reasonController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onDeactivatePressed() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _errorText = "Please provide a reason to continue");
      return;
    }
    Get.back(); // close the confirmation dialog
    widget.controller.deactivateScheme(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppColors.backgroundPrimary,
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Deactivate Scheme?",
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryMaroon,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to deactivate this Suvarna Unnati scheme? "
                  "Your accumulated gold savings will remain safe, but you won't be "
                  "able to make further deposits into this plan.",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Reason for Deactivation *",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              minLines: 2,
              maxLength: 200,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: "e.g. Facing financial difficulty, switching plans...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                errorText: _errorText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.2),
                ),
              ),
              onChanged: (value) {
                if (_errorText != null && value.trim().isNotEmpty) {
                  setState(() => _errorText = null);
                }
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _onDeactivatePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            "Deactivate",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}