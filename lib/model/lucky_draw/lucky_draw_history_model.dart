// =====================================================================
// LuckyDrawHistory Model – Response of GET /lucky-draws
// =====================================================================

class LuckyDrawHistoryResponse {  
  final bool success;
  final List<LuckyDrawHistoryItem> data;
  final LuckyDrawHistoryPagination? pagination;

  LuckyDrawHistoryResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory LuckyDrawHistoryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<LuckyDrawHistoryItem> items = list
        .map((item) => LuckyDrawHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return LuckyDrawHistoryResponse(
      success: json['success'] as bool? ?? false,
      data: items,
      pagination: json['pagination'] != null
          ? LuckyDrawHistoryPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LuckyDrawHistoryItem {
  final String id;
  final String startCouponCode;
  final String endCouponCode;
  final String winningCouponId;
  final String winningCouponCode;
  final LuckyDrawWinnerCustomer? customerId;
  final String createdAt;
  final String updatedAt;

  LuckyDrawHistoryItem({
    required this.id,
    required this.startCouponCode,
    required this.endCouponCode,
    required this.winningCouponId,
    required this.winningCouponCode,
    this.customerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LuckyDrawHistoryItem.fromJson(Map<String, dynamic> json) {
    return LuckyDrawHistoryItem(
      id: json['_id'] as String? ?? '',
      startCouponCode: json['startCouponCode'] as String? ?? '',
      endCouponCode: json['endCouponCode'] as String? ?? '',
      winningCouponId: json['winningCouponId'] as String? ?? '',
      winningCouponCode: json['winningCouponCode'] as String? ?? '',
      customerId: json['customerId'] != null
          ? LuckyDrawWinnerCustomer.fromJson(json['customerId'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}

class LuckyDrawWinnerCustomer {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;
  final String customerIdCode;

  LuckyDrawWinnerCustomer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.customerIdCode,
  });

  factory LuckyDrawWinnerCustomer.fromJson(Map<String, dynamic> json) {
    return LuckyDrawWinnerCustomer(
      id: json['_id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      customerIdCode: json['customerIdCode'] as String? ?? '',
    );
  }
}

class LuckyDrawHistoryPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  LuckyDrawHistoryPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory LuckyDrawHistoryPagination.fromJson(Map<String, dynamic> json) {
    return LuckyDrawHistoryPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
    );
  }
}
