import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_colors.dart';
import '../activated_scheme/activated_scheme_controller.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final ActivatedScheme scheme;
  final int installmentNumber;
  final double amount;
  final double goldGrams;
  final String transactionId = "TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}";

  PaymentStatusScreen({
    super.key,
    required this.isSuccess,
    required this.scheme,
    required this.installmentNumber,
    required this.amount,
    required this.goldGrams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          isSuccess ? "Payment Receipt" : "Payment Status",
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                // ── STATUS HEADER ICON ────────────────────────────────────────
                _buildStatusIcon(),

                const SizedBox(height: 24),

                // ── STATUS LABELS ────────────────────────────────────────────
                Text(
                  isSuccess ? "Payment Successful ✓" : "Payment Failed ✗",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? AppColors.success : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  isSuccess
                      ? "Thank you! Your installment has been received."
                      : "Your payment gateway transaction could not be completed.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // ── TRANSACTION DETAILS CARD ─────────────────────────────────
                _buildDetailsCard(),

                const SizedBox(height: 36),

                // ── ACTIONS BUTTONS ──────────────────────────────────────────
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Status Circle Header ───────────────────────────────────────────────────
  Widget _buildStatusIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSuccess
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSuccess
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.error.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSuccess
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.error.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isSuccess ? AppColors.success : AppColors.error,
          size: 60,
        ),
      ),
    );
  }

  // ── Details Panel ──────────────────────────────────────────────────────────
  Widget _buildDetailsCard() {
    final now = DateTime.now();
    final dateString = "${now.day} ${_getMonthName(now.month)} ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transaction Info",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
                ),
              ),
              if (isSuccess)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "PAID",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow("Scheme Name", scheme.name),
          _detailRow("Installment", "Month #$installmentNumber"),
          _detailRow("Payment Mode", scheme.type == 'Money' ? "Rupee SIP" : "Gold Weight SIP"),
          _detailRow("Amount Paid", _formatAmount(amount)),
          _detailRow("Gold Saved", "${goldGrams.toStringAsFixed(4)} g"),
          _detailRow("Date & Time", dateString),
          const Divider(height: 24, thickness: 0.8),
          _detailRow(
            "Transaction ID",
            transactionId,
            valueColor: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (isSuccess)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _generateAndShareReceipt(),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                "Share Receipt (PDF)",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (!isSuccess)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: Text(
                "Retry Payment",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              Get.back(); // close status screen and return to details
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Back to Scheme",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Receipt PDF Generation & Sharing ───────────────────────────────────────
  Future<void> _generateAndShareReceipt() async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final pdf = pw.Document();

      final primaryColor = PdfColor.fromInt(0xFF6B1D2E);
      final accentColor = PdfColor.fromInt(0xFFD4AF37);
      final darkTextColor = PdfColor.fromInt(0xFF333333);
      final lightBg = PdfColor.fromInt(0xFFFDFDFD);

      final now = DateTime.now();
      final dateString = "${now.day} ${_getMonthName(now.month)} ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: lightBg,
                border: pw.Border.all(color: accentColor, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo/Header Banner
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "UNNATI JEWELERS",
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "Suvarna Savings Receipt",
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: darkTextColor,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFE8F5E9),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          "SUCCESS",
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: accentColor),
                  pw.SizedBox(height: 10),

                   // Receipt Meta Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "TRANSACTION RECEIPT",
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                      ),
                      pw.Text(
                        "No: REC/2026/#$installmentNumber/${transactionId.substring(transactionId.length - 4)}",
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkTextColor),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Customer Details Section
                  pw.Text(
                    "CUSTOMER DETAILS",
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                  pw.SizedBox(height: 6),
                  _pdfRow("Customer Name:", "Om Prakash"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Contact Number:", "+91 98765 43210"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Address:", "102, Gold Palace, CG Road, Ahmedabad"),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 0.5, color: PdfColor.fromInt(0xFFDDDDDD)),
                  pw.SizedBox(height: 8),

                  // Payment Details Section
                  pw.Text(
                    "PAYMENT & TRANSACTION DETAILS",
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                  pw.SizedBox(height: 6),
                  _pdfRow("Transaction ID:", transactionId),
                  pw.SizedBox(height: 4),
                  _pdfRow("Payment Method:", "UPI / Net Banking"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Date & Time:", dateString),
                  pw.SizedBox(height: 4),
                  _pdfRow("Scheme Name:", scheme.name),
                  pw.SizedBox(height: 4),
                  _pdfRow("Installment Month:", "Month #$installmentNumber"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Payment Type:", scheme.type == 'Money' ? "Money Plan" : "Gold Weight Plan"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Amount Paid:", "Rs. ${amount.toStringAsFixed(2)}"),
                  pw.SizedBox(height: 4),
                  _pdfRow("Gold Accumulated:", "${goldGrams.toStringAsFixed(4)} g"),

                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 0.5, color: PdfColor.fromInt(0xFFCCCCCC)),
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Text(
                      "This is a system generated receipt and requires no physical signature.",
                      style: pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF888888)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = "${tempDir.path}/Receipt_$transactionId.pdf";
      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      Get.back(); // close loader dialog

      // Open Native Share sheet
      try {
        await Share.shareXFiles([XFile(filePath)]);
      } catch (shareError) {
        Get.snackbar(
          'Share Unavailable',
          'Receipt generated! Restart the app to enable direct sharing.',
          backgroundColor: AppColors.yellowLight,
          colorText: AppColors.yellowText,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back(); // close loader dialog
      Get.snackbar(
        'Error',
        'Could not generate receipt PDF: $e',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  pw.Row _pdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  // Formatting helpers
  String _formatAmount(double v) =>
      '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1) return months[0];
    if (month > 12) return months[11];
    return months[month - 1];
  }
}
