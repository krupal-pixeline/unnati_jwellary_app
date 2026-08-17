// =====================================================================
// MyCouponModel – Response of GET /coupons/my-coupons?batchId=...
// Statuses from API: "active" | "expired" | "won"
// =====================================================================

class MyCouponResponse {
  final bool success;
  final List<MyCoupon> data;
  final MyCouponPagination? pagination;

  MyCouponResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory MyCouponResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return MyCouponResponse(
      success: json['success'] as bool? ?? false,
      data: list
          .map((item) => MyCoupon.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? MyCouponPagination.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MyCoupon {
  final String id;
  final String couponCode;
  final MyCouponCustomer? customer;
  final int amount;
  final String status; // "active" | "expired" | "won"
  final String batchId;
  final String createdAt;
  final String updatedAt;

  MyCoupon({
    required this.id,
    required this.couponCode,
    this.customer,
    required this.amount,
    required this.status,
    required this.batchId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyCoupon.fromJson(Map<String, dynamic> json) {
    return MyCoupon(
      id: json['_id'] as String? ?? '',
      couponCode: json['couponCode'] as String? ?? '',
      customer: json['customerId'] != null
          ? MyCouponCustomer.fromJson(
              json['customerId'] as Map<String, dynamic>)
          : null,
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isExpired => status.toLowerCase() == 'expired';
  bool get isWon => status.toLowerCase() == 'won';
}

class MyCouponCustomer {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;
  final String customerIdCode;

  MyCouponCustomer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.customerIdCode,
  });

  factory MyCouponCustomer.fromJson(Map<String, dynamic> json) {
    return MyCouponCustomer(
      id: json['_id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      customerIdCode: json['customerIdCode'] as String? ?? '',
    );
  }
}

class MyCouponPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  MyCouponPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory MyCouponPagination.fromJson(Map<String, dynamic> json) {
    return MyCouponPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
    );
  }
}
