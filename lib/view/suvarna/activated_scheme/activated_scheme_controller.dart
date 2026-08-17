import 'package:get/get.dart';
import '../../../model/swarnim/my_scheme_model.dart';
import '../../../services/swarnim_scheme_api_service.dart';
import '../../../utils/other_methods.dart';

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year;
  return '$day-$month-$year';
}

class ActivatedScheme {
  final String id;
  final String schemeIdCode;
  final String name;
  final String type; // 'Money' or 'Gold'
  final double installmentAmount; // Rupee amount or Gram weight
  final String purity; // '24K', '22K', etc.
  final int paidInstallments;
  final int totalInstallments;
  final double totalAmountPaid;
  final double accumulatedGold;
  final String nextDueDate;
  final double progress; // percentage paid
  final bool isActive;
  final String aadhaarNumber;
  final String panCardNumber;
  final String address;
  final String status;
  final String kycStatus;
  final String livePhoto;
  final double planAmount;
  final double maturityValue;
  final double currentGoldRate;
  final bool canPayNextInstallment;
  final MySchemeModel? rawModel;

  ActivatedScheme({
    required this.id,
    this.schemeIdCode = '',
    required this.name,
    required this.type,
    required this.installmentAmount,
    required this.purity,
    required this.paidInstallments,
    required this.totalInstallments,
    required this.totalAmountPaid,
    required this.accumulatedGold,
    required this.nextDueDate,
    this.isActive = true,
    this.aadhaarNumber = '',
    this.panCardNumber = '',
    this.address = '',
    this.status = 'active',
    this.kycStatus = 'approved',
    this.livePhoto = '',
    this.planAmount = 0.0,
    this.maturityValue = 0.0,
    this.currentGoldRate = 0.0,
    this.canPayNextInstallment = false,
    this.rawModel,
  }) : progress = totalInstallments > 0 ? (paidInstallments / totalInstallments).clamp(0.0, 1.0) : 0.0;

  factory ActivatedScheme.fromModel(MySchemeModel model) {
    final isMoney = model.planType == 'amount-based';
    final typeStr = isMoney ? 'Money' : 'Gold';
    final purityStr = model.goldType != 'none' && model.goldType.isNotEmpty ? model.goldType : '24K';

    final paidCount = model.installments
        .where((i) =>
            i.paymentStatus.toLowerCase() == 'paid' ||
            i.paymentStatus.toLowerCase() == 'completed' ||
            i.paymentStatus.toLowerCase() == 'success')
        .length;

    final totalCount = model.durationMonths > 0 ? model.durationMonths : 12;

    String nextDateStr = 'N/A';
    try {
      final pendingInst = model.installments.firstWhereOrNull(
          (i) => i.paymentStatus.toLowerCase() == 'pending');
      if (pendingInst != null && pendingInst.paymentDate.isNotEmpty) {
        final dt = DateTime.parse(pendingInst.paymentDate);
        nextDateStr = _formatDate(dt);
      } else if (model.createdAt.isNotEmpty) {
        final dt = DateTime.parse(model.createdAt);
        nextDateStr = _formatDate(dt.add(const Duration(days: 30)));
      }
    } catch (_) {}

    return ActivatedScheme(
      id: model.id,
      schemeIdCode: model.schemeIdCode.isNotEmpty ? model.schemeIdCode : model.id,
      name: model.accountHolderName.isNotEmpty
          ? model.accountHolderName
          : 'Suvarna Unnati Scheme',
      type: typeStr,
      installmentAmount: model.monthlyAmount,
      purity: purityStr,
      paidInstallments: paidCount,
      totalInstallments: totalCount,
      totalAmountPaid: model.totalPaidAmount,
      accumulatedGold: model.totalGoldAccumulated,
      nextDueDate: nextDateStr,
      isActive: model.status.toLowerCase() == 'active',
      aadhaarNumber: model.aadhaarNumber,
      panCardNumber: model.panCardNumber,
      address: model.address,
      status: model.status,
      kycStatus: model.kycStatus,
      livePhoto: model.livePhoto,
      planAmount: model.planAmount,
      maturityValue: model.maturityValue,
      currentGoldRate: model.currentGoldRate,
      canPayNextInstallment: model.canPayNextInstallment,
      rawModel: model,
    );
  }
}

class ActivatedSchemeController extends GetxController {
  final SwarnimSchemeApiService _apiService = SwarnimSchemeApiService();

  // Loading & Error States
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Live Gold Rate per gram (24K)
  final RxDouble liveGoldRate = 7245.50.obs;

  // Portfolio Totals from API
  final RxDouble apiTotalInvestedAmount = 0.0.obs;
  final RxDouble apiTotalGoldAccumulated = 0.0.obs;

  // List of active schemes
  final RxList<ActivatedScheme> schemes = <ActivatedScheme>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMySchemes();
    _startRateRefresh();
  }

  Future<void> fetchMySchemes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      OtherMethods.customLog('📲 [ActivatedSchemeController] Fetching my schemes from API...');

      final response = await _apiService.getMySchemes();

      apiTotalInvestedAmount.value = response.totalInvestedAmount;
      apiTotalGoldAccumulated.value = response.totalGoldAccumulated;

      final List<ActivatedScheme> loaded = response.data
          .map((model) => ActivatedScheme.fromModel(model))
          .toList();

      schemes.assignAll(loaded);
      OtherMethods.customLog('✅ [ActivatedSchemeController] Successfully loaded ${schemes.length} schemes.');
    } catch (e) {
      OtherMethods.customLog('❌ [ActivatedSchemeController] Error fetching schemes: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _startRateRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 15));
      final delta = liveGoldRate.value * 0.003;
      liveGoldRate.value += (DateTime.now().second % 2 == 0 ? delta : -delta);
      return true;
    });
  }

  // Computed Portfolio values
  double get totalInvestedAmount {
    if (apiTotalInvestedAmount.value > 0) return apiTotalInvestedAmount.value;
    return schemes.where((s) => s.isActive).fold(0.0, (sum, item) {
      if (item.type == 'Gold') {
        return sum + (item.accumulatedGold * liveGoldRate.value);
      }
      return sum + item.totalAmountPaid;
    });
  }

  double get totalGoldAccumulated {
    if (apiTotalGoldAccumulated.value > 0) return apiTotalGoldAccumulated.value;
    return schemes.where((s) => s.isActive).fold(0.0, (sum, item) => sum + item.accumulatedGold);
  }

  // Formatting helpers
  String formatAmount(double v) =>
      '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String formatGrams(double v) => '${v.toStringAsFixed(4)} g';
}
