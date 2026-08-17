// =====================================================================
// My Scheme Model  –  Response of GET /swarnim-schemes/my-schemes
// =====================================================================

class MySchemesResponse {
  final bool success;
  final double totalInvestedAmount;
  final double totalGoldAccumulated;
  final List<MySchemeModel> data;

  const MySchemesResponse({
    required this.success,
    required this.totalInvestedAmount,
    required this.totalGoldAccumulated,
    required this.data,
  });

  factory MySchemesResponse.fromJson(Map<String, dynamic> json) {
    return MySchemesResponse(
      success: json['success'] as bool? ?? false,
      totalInvestedAmount: (json['totalInvestedAmount'] as num?)?.toDouble() ?? 0.0,
      totalGoldAccumulated: (json['totalGoldAccumulated'] as num?)?.toDouble() ?? 0.0,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((i) => MySchemeModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalInvestedAmount': totalInvestedAmount,
      'totalGoldAccumulated': totalGoldAccumulated,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class MySchemeModel {
  final String id;
  final String customerId;
  final String schemeIdCode;
  final String planType; // "amount-based" or "gold-based"
  final String accountHolderName;
  final String emailId;
  final String mobileNumber;
  final String livePhoto;
  final String aadhaarNumber;
  final String panCardNumber;
  final String address;
  final double monthlyAmount;
  final int durationMonths;
  final String goldType;
  final String kycStatus;
  final String status;
  final String? deactivationNote;
  final String? completionNote;
  final List<MySchemeInstallmentModel> installments;
  final double totalPaidAmount;
  final double totalGoldAccumulated;
  final String createdAt;
  final String updatedAt;
  final double maturityValue;
  final double goldMarketValue;
  final double currentGoldRate;
  final bool canPayNextInstallment;
  final double planAmount;

  const MySchemeModel({
    required this.id,
    required this.customerId,
    required this.schemeIdCode,
    required this.planType,
    required this.accountHolderName,
    required this.emailId,
    required this.mobileNumber,
    required this.livePhoto,
    required this.aadhaarNumber,
    required this.panCardNumber,
    required this.address,
    required this.monthlyAmount,
    required this.durationMonths,
    required this.goldType,
    required this.kycStatus,
    required this.status,
    this.deactivationNote,
    this.completionNote,
    required this.installments,
    required this.totalPaidAmount,
    required this.totalGoldAccumulated,
    required this.createdAt,
    required this.updatedAt,
    required this.maturityValue,
    required this.goldMarketValue,
    required this.currentGoldRate,
    required this.canPayNextInstallment,
    required this.planAmount,
  });

  factory MySchemeModel.fromJson(Map<String, dynamic> json) {
    String custId = '';
    if (json['customerId'] is Map) {
      custId = (json['customerId'] as Map)['_id'] as String? ?? '';
    } else if (json['customerId'] is String) {
      custId = json['customerId'] as String;
    }

    return MySchemeModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      customerId: custId,
      schemeIdCode: json['schemeIdCode'] as String? ?? '',
      planType: json['planType'] as String? ?? 'amount-based',
      accountHolderName: json['accountHolderName'] as String? ?? '',
      emailId: json['emailId'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      livePhoto: json['livePhoto'] as String? ?? '',
      aadhaarNumber: json['aadhaarNumber'] as String? ?? '',
      panCardNumber: json['panCardNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      monthlyAmount: (json['monthlyAmount'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      goldType: json['goldType'] as String? ?? 'none',
      kycStatus: json['kycStatus'] as String? ?? 'approved',
      status: json['status'] as String? ?? 'active',
      deactivationNote: json['deactivationNote'] as String?,
      completionNote: json['completionNote'] as String?,
      installments: json['installments'] != null && json['installments'] is List
          ? (json['installments'] as List)
              .map((i) => MySchemeInstallmentModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      totalGoldAccumulated: (json['totalGoldAccumulated'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      maturityValue: (json['maturityValue'] as num?)?.toDouble() ?? 0.0,
      goldMarketValue: (json['goldMarketValue'] as num?)?.toDouble() ?? 0.0,
      currentGoldRate: (json['currentGoldRate'] as num?)?.toDouble() ?? 0.0,
      canPayNextInstallment: json['canPayNextInstallment'] as bool? ?? false,
      planAmount: (json['planAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerId': customerId,
      'schemeIdCode': schemeIdCode,
      'planType': planType,
      'accountHolderName': accountHolderName,
      'emailId': emailId,
      'mobileNumber': mobileNumber,
      'livePhoto': livePhoto,
      'aadhaarNumber': aadhaarNumber,
      'panCardNumber': panCardNumber,
      'address': address,
      'monthlyAmount': monthlyAmount,
      'durationMonths': durationMonths,
      'goldType': goldType,
      'kycStatus': kycStatus,
      'status': status,
      'deactivationNote': deactivationNote,
      'completionNote': completionNote,
      'installments': installments.map((e) => e.toJson()).toList(),
      'totalPaidAmount': totalPaidAmount,
      'totalGoldAccumulated': totalGoldAccumulated,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'maturityValue': maturityValue,
      'goldMarketValue': goldMarketValue,
      'planAmount': planAmount,
    };
  }
}

class MySchemeInstallmentModel {
  final String id;
  final String installmentId;
  final int installmentNumber;
  final String installmentName;
  final double amount;
  final double goldWeight;
  final double goldRateAtPayment;
  final String orderId;
  final String paymentStatus;
  final String paymentMode;
  final String paymentDate;

  const MySchemeInstallmentModel({
    required this.id,
    required this.installmentId,
    required this.installmentNumber,
    required this.installmentName,
    required this.amount,
    required this.goldWeight,
    required this.goldRateAtPayment,
    required this.orderId,
    required this.paymentStatus,
    required this.paymentMode,
    required this.paymentDate,
  });

  factory MySchemeInstallmentModel.fromJson(Map<String, dynamic> json) {
    return MySchemeInstallmentModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      installmentId: json['installmentId'] as String? ?? '',
      installmentNumber: (json['installmentNumber'] as num?)?.toInt() ?? 1,
      installmentName: json['installmentName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      goldWeight: (json['goldWeight'] as num?)?.toDouble() ?? 0.0,
      goldRateAtPayment: (json['goldRateAtPayment'] as num?)?.toDouble() ?? 0.0,
      orderId: json['orderId'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMode: json['paymentMode'] as String? ?? 'online',
      paymentDate: json['paymentDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'installmentId': installmentId,
      'installmentNumber': installmentNumber,
      'installmentName': installmentName,
      'amount': amount,
      'goldWeight': goldWeight,
      'goldRateAtPayment': goldRateAtPayment,
      'orderId': orderId,
      'paymentStatus': paymentStatus,
      'paymentMode': paymentMode,
      'paymentDate': paymentDate,
    };
  }
}
