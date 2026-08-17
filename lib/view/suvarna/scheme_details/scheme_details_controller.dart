import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../model/swarnim/my_scheme_model.dart';
import '../../../services/swarnim_scheme_api_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/other_methods.dart';
import '../activated_scheme/activated_scheme_controller.dart';
import 'payment_status_screen.dart';

String _formatDateHelper(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year;
  return '$day $month $year';
}

class PaymentInstallment {
  final int number;
  final String date;
  final double amount;
  final double goldGrams;
  final String status; // 'Paid', 'Payable', 'Pending'
  final String orderId;
  final String paymentMode;
  final MySchemeInstallmentModel? rawInstallment;

  PaymentInstallment({
    required this.number,
    required this.date,
    required this.amount,
    required this.goldGrams,
    required this.status,
    this.orderId = '',
    this.paymentMode = 'online',
    this.rawInstallment,
  });
}

class SchemeDetailsController extends GetxController {
  final SwarnimSchemeApiService _swarnimApiService = SwarnimSchemeApiService();

  late ActivatedScheme scheme;
  final RxList<PaymentInstallment> installments = <PaymentInstallment>[].obs;
  final RxDouble liveGoldRate = 7245.50.obs;

  final RxBool isLoadingDetails = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ActivatedScheme) {
      scheme = Get.arguments as ActivatedScheme;
      _bindLiveRate();
      _generateInstallments();
      if (scheme.id.isNotEmpty) {
        fetchSchemeDetails(scheme.id);
      }
    }
  }

  Future<void> fetchSchemeDetails(String schemeId) async {
    if (schemeId.isEmpty) return;
    try {
      isLoadingDetails.value = true;
      errorMessage.value = '';
      OtherMethods.customLog('📲 [SchemeDetailsController] Fetching scheme details for ID: $schemeId');

      final MySchemeModel detailModel = await _swarnimApiService.getSchemeDetails(schemeId);
      scheme = ActivatedScheme.fromModel(detailModel);

      _generateInstallments();
      update();
      OtherMethods.customLog('✅ [SchemeDetailsController] Details loaded. canPayNextInstallment: ${scheme.canPayNextInstallment}');
    } catch (e) {
      OtherMethods.customLog('❌ [SchemeDetailsController] Error fetching details: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void _bindLiveRate() {
    if (Get.isRegistered<ActivatedSchemeController>()) {
      final activeController = Get.find<ActivatedSchemeController>();
      liveGoldRate.value = activeController.liveGoldRate.value;
      ever(activeController.liveGoldRate, (double newRate) {
        liveGoldRate.value = newRate;
        _generateInstallments();
      });
    }
  }

  void _generateInstallments() {
    final List<PaymentInstallment> temp = [];
    final double baseRate = liveGoldRate.value > 0 ? liveGoldRate.value : (scheme.currentGoldRate > 0 ? scheme.currentGoldRate : 7245.50);

    final int duration = scheme.totalInstallments > 0 ? scheme.totalInstallments : 12;
    final rawInsts = scheme.rawModel?.installments ?? [];

    for (int i = 1; i <= duration; i++) {
      MySchemeInstallmentModel? matchedRaw;
      if (i <= rawInsts.length) {
        matchedRaw = rawInsts[i - 1];
      } else {
        matchedRaw = rawInsts.firstWhereOrNull((inst) => inst.installmentNumber == i);
      }

      if (matchedRaw != null) {
        final isPaid = matchedRaw.paymentStatus.toLowerCase() == 'paid' ||
            matchedRaw.paymentStatus.toLowerCase() == 'completed' ||
            matchedRaw.paymentStatus.toLowerCase() == 'success';

        String dateStr = 'Pending';
        if (matchedRaw.paymentDate.isNotEmpty) {
          try {
            final dt = DateTime.parse(matchedRaw.paymentDate);
            dateStr = _formatDateHelper(dt);
          } catch (_) {
            dateStr = matchedRaw.paymentDate;
          }
        }

        String instStatus = isPaid ? 'Paid' : 'Pending';
        if (!isPaid && i == (scheme.paidInstallments + 1) && scheme.canPayNextInstallment) {
          instStatus = 'Payable';
        }

        final amountVal = matchedRaw.amount > 0 ? matchedRaw.amount : scheme.installmentAmount;
        final goldVal = matchedRaw.goldWeight > 0
            ? matchedRaw.goldWeight
            : (scheme.type == 'Money' ? amountVal / baseRate : scheme.installmentAmount);

        temp.add(PaymentInstallment(
          number: matchedRaw.installmentNumber > 0 ? matchedRaw.installmentNumber : i,
          date: dateStr,
          amount: amountVal,
          goldGrams: goldVal,
          status: instStatus,
          orderId: matchedRaw.orderId,
          paymentMode: matchedRaw.paymentMode,
          rawInstallment: matchedRaw,
        ));
      } else {
        final isNext = (i == scheme.paidInstallments + 1);
        final instStatus = (isNext && scheme.canPayNextInstallment) ? 'Payable' : 'Pending';

        final double purityMultiplier = scheme.purity == '22K' ? 0.9167 : 1.0;
        final double rateForMonth = baseRate * purityMultiplier;

        double amountForMonth = scheme.installmentAmount;
        double goldForMonth = scheme.type == 'Money'
            ? amountForMonth / rateForMonth
            : scheme.installmentAmount;

        temp.add(PaymentInstallment(
          number: i,
          date: 'Pending',
          amount: amountForMonth,
          goldGrams: goldForMonth,
          status: instStatus,
        ));
      }
    }

    installments.assignAll(temp);
  }

  Future<void> generateAndShareInstallmentReceipt(PaymentInstallment item) async {
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
      final primaryColor = PdfColor.fromInt(0xFF800020);
      final goldColor = PdfColor.fromInt(0xFFD4AF37);
      final darkTextColor = PdfColor.fromInt(0xFF2C2C2C);
      final lightBgColor = PdfColor.fromInt(0xFFFAF6F0);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "UNNATI JEWELERS",
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: goldColor,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "Suvarna Unnati Payment Receipt",
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.white),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF2E7D32),
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          "PAID",
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightBgColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: goldColor, width: 1),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfSummaryRow("Scheme ID Code:", scheme.schemeIdCode),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Account Holder:", scheme.name),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Installment No:", "Installment #${item.number}"),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Payment Date:", item.date),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Order ID / Ref:", item.orderId.isNotEmpty ? item.orderId : 'N/A'),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Payment Mode:", item.paymentMode.toUpperCase()),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Amount Paid:", formatPdfAmount(item.amount)),
                      pw.SizedBox(height: 6),
                      _pdfSummaryRow("Gold Accumulated:", formatGrams(item.goldGrams)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "This is an official system-generated payment receipt from Unnati Jewelers.",
                    style: pw.TextStyle(fontSize: 8, color: darkTextColor, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = "Receipt_Installment_${item.number}_${scheme.id}.pdf";
      final String filePath = "${tempDir.path}/$fileName";
      final File file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      Get.back();

      try {
        await Share.shareXFiles([XFile(filePath)]);
      } catch (shareError) {
        Get.snackbar(
          'Receipt Saved',
          'Receipt generated: $fileName',
          backgroundColor: AppColors.successLight,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error Generating Receipt',
        '$e',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Deactivate Scheme logic — now requires a reason string from the dialog.
  Future<void> deactivateScheme(String reason) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate API delay. Pass `reason` to your backend/API call here, e.g.:
    // await api.deactivateScheme(schemeId: scheme.id, reason: reason);
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back(); // close progress loader

    // Update isActive to false in ActivatedSchemeController list
    if (Get.isRegistered<ActivatedSchemeController>()) {
      final activeController = Get.find<ActivatedSchemeController>();
      final int idx = activeController.schemes.indexWhere((s) => s.id == scheme.id);
      if (idx != -1) {
        final old = activeController.schemes[idx];
        activeController.schemes[idx] = ActivatedScheme(
          id: old.id,
          name: old.name,
          type: old.type,
          installmentAmount: old.installmentAmount,
          purity: old.purity,
          paidInstallments: old.paidInstallments,
          totalInstallments: old.totalInstallments,
          totalAmountPaid: old.totalAmountPaid,
          accumulatedGold: old.accumulatedGold,
          nextDueDate: old.nextDueDate,
          isActive: false,
        );
      }
    }

    Get.back(); // close Scheme Details Screen

    Get.snackbar(
      'Scheme Deactivated',
      '${scheme.name} has been deactivated.\nReason: $reason',
      backgroundColor: AppColors.errorLight,
      colorText: AppColors.error,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  // Export Report as a PDF & Share PDF
  Future<void> exportAndShareReport() async {
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

      // Premium Color Palette
      final primaryColor = PdfColor.fromInt(0xFF6B1D2E); // Maroon Primary
      final accentColor = PdfColor.fromInt(0xFFD4AF37); // Gold Accent
      final darkTextColor = PdfColor.fromInt(0xFF333333);
      final lightBgColor = PdfColor.fromInt(0xFFFDFDFD);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context context) {
            return [
              // Header Banner Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "UNNATI JEWELERS",
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Suvarna Unnati Savings Statement",
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: darkTextColor,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Date: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                        style: pw.TextStyle(fontSize: 9, color: darkTextColor),
                      ),
                      pw.Text(
                        "ID: ${scheme.id}",
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1.5, color: accentColor),
              pw.SizedBox(height: 16),

              // Overview Title
              pw.Text(
                "Scheme Summary",
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),

              // Summary Box Container
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFDF9F0),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE5C060), width: 1),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  children: [
                    _pdfSummaryRow("Customer Name:", "Om Prakash"),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Contact Number:", "+91 98765 43210"),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Scheme Name:", scheme.name),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Investment Type:", scheme.type == 'Money' ? 'Invest on Money' : 'Invest on Gold'),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Karat Purity:", scheme.purity),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Monthly Installment:", scheme.type == 'Money'
                        ? formatPdfAmount(scheme.installmentAmount)
                        : "${scheme.installmentAmount.toStringAsFixed(2)} g"),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Total Amount Paid:", formatPdfAmount(scheme.type == 'Money'
                        ? scheme.totalAmountPaid
                        : scheme.accumulatedGold * liveGoldRate.value)),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Gold Accumulated:", formatGrams(scheme.accumulatedGold)),
                    pw.SizedBox(height: 6),
                    _pdfSummaryRow("Completed Months:", "${scheme.paidInstallments} / ${scheme.totalInstallments} Months"),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Table Title
              pw.Text(
                "Installment Ledger & Timeline",
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFEEEEEE), width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(40),
                  1: pw.FlexColumnWidth(2.5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _pdfTableHeaderCell("#"),
                      _pdfTableHeaderCell("Payment / Due Date"),
                      _pdfTableHeaderCell("Amount"),
                      _pdfTableHeaderCell("Gold Saved"),
                      _pdfTableHeaderCell("Status"),
                    ],
                  ),
                  ...installments.map((item) {
                    final isPaid = item.status == 'Paid';
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isPaid ? lightBgColor : PdfColor.fromInt(0xFFFAFAFA),
                      ),
                      children: [
                        _pdfTableBodyCell(item.number.toString()),
                        _pdfTableBodyCell(item.date),
                        _pdfTableBodyCell(formatPdfAmount(item.amount)),
                        _pdfTableBodyCell(formatGrams(item.goldGrams)),
                        _pdfTableBodyCell(
                          item.status.toUpperCase(),
                          color: isPaid ? PdfColor.fromInt(0xFF2E7D32) : PdfColor.fromInt(0xFFE65100),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 35),
              pw.Divider(thickness: 0.5, color: PdfColor.fromInt(0xFFCCCCCC)),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "Thank you for investing with Unnati Jewelers Suvarna Unnati. This is a system-generated statement.",
                  style: pw.TextStyle(fontSize: 8, color: darkTextColor, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to temporary directory (so it is not saved to public downloads)
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = "Suvarna_Report_${scheme.id}.pdf";
      final String filePath = "${tempDir.path}/$fileName";
      final File file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      // Close loader dialog
      Get.back();

      // Try native share
      try {
        await Share.shareXFiles([XFile(filePath)]);
      } catch (shareError) {
        // Handle MissingPluginException if native binary has not been recompiled yet
        Get.snackbar(
          'Share Offline',
          'Relaunch the app to enable direct PDF sharing.',
          backgroundColor: AppColors.yellowLight,
          colorText: AppColors.yellowText,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }

    } catch (e) {
      Get.back(); // close loader dialog
      Get.snackbar(
        'Error Exporting PDF',
        'Could not generate or save statement: $e',
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  pw.Row _pdfSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _pdfTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _pdfTableBodyCell(String text, {PdfColor? color, pw.FontWeight? fontWeight}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color ?? PdfColor.fromInt(0xFF333333),
          fontWeight: fontWeight ?? pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Formatting helpers
  String formatAmount(double v) =>
      '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String formatPdfAmount(double v) =>
      'Rs. ${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String formatGrams(double v) => '${v.toStringAsFixed(4)} g';

  // Pay next installment logic
  Future<void> payInstallment(int installmentNumber) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate payment API delay
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back(); // close progress loader

    double addedAmount = 0.0;
    double addedGold = 0.0;

    // Find and update the scheme in ActivatedSchemeController
    if (Get.isRegistered<ActivatedSchemeController>()) {
      final activeController = Get.find<ActivatedSchemeController>();
      final int schemeIndex = activeController.schemes.indexWhere((s) => s.id == scheme.id);
      if (schemeIndex != -1) {
        final oldScheme = activeController.schemes[schemeIndex];
        final nextPaid = oldScheme.paidInstallments + 1;

        addedAmount = oldScheme.type == 'Money'
            ? oldScheme.installmentAmount
            : oldScheme.installmentAmount * liveGoldRate.value;

        addedGold = oldScheme.type == 'Money'
            ? oldScheme.installmentAmount / liveGoldRate.value
            : oldScheme.installmentAmount;

        final updatedScheme = ActivatedScheme(
          id: oldScheme.id,
          name: oldScheme.name,
          type: oldScheme.type,
          installmentAmount: oldScheme.installmentAmount,
          purity: oldScheme.purity,
          paidInstallments: nextPaid,
          totalInstallments: oldScheme.totalInstallments,
          totalAmountPaid: oldScheme.totalAmountPaid + addedAmount,
          accumulatedGold: oldScheme.accumulatedGold + addedGold,
          nextDueDate: '12-${_getMonthName(DateTime.now().month + 1)}-2026',
        );

        activeController.schemes[schemeIndex] = updatedScheme;

        // Update our local scheme reference and regenerate list!
        scheme = updatedScheme;
        _generateInstallments();
      }
    }

    // Route to beautiful Payment Status Receipt screen
    Get.to(() => PaymentStatusScreen(
      isSuccess: true,
      scheme: scheme,
      installmentNumber: installmentNumber,
      amount: addedAmount,
      goldGrams: addedGold,
    ));
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1) return months[0];
    if (month > 12) return months[11];
    return months[month - 1];
  }
}