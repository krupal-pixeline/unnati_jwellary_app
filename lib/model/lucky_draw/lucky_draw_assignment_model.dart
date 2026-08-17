// =====================================================================
// LuckyDrawAssignmentResponse Model – Response of GET /coupons/my-assignments
// =====================================================================

class LuckyDrawAssignmentResponse {
  final bool success;
  final List<LuckyDrawAssignment> data;
  final LuckyDrawPagination? pagination;

  LuckyDrawAssignmentResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory LuckyDrawAssignmentResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<LuckyDrawAssignment> assignments = dataList
        .map((item) => LuckyDrawAssignment.fromJson(item as Map<String, dynamic>))
        .toList();

    return LuckyDrawAssignmentResponse(
      success: json['success'] as bool? ?? false,
      data: assignments,
      pagination: json['pagination'] != null
          ? LuckyDrawPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
    };
  }
}

class LuckyDrawAssignment {
  final String batchId;
  final int amountPerCoupon;
  final int couponsAssigned;
  final int totalAmount;
  final String couponIdRange;
  final String status;
  final String dateAssigned;

  LuckyDrawAssignment({
    required this.batchId,
    required this.amountPerCoupon,
    required this.couponsAssigned,
    required this.totalAmount,
    required this.couponIdRange,
    required this.status,
    required this.dateAssigned,
  });

  factory LuckyDrawAssignment.fromJson(Map<String, dynamic> json) {
    return LuckyDrawAssignment(
      batchId: json['batchId'] as String? ?? '',
      amountPerCoupon: json['amountPerCoupon'] as int? ?? 0,
      couponsAssigned: json['couponsAssigned'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
      couponIdRange: json['couponIdRange'] as String? ?? '',
      status: json['status'] as String? ?? '',
      dateAssigned: json['dateAssigned'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'amountPerCoupon': amountPerCoupon,
      'couponsAssigned': couponsAssigned,
      'totalAmount': totalAmount,
      'couponIdRange': couponIdRange,
      'status': status,
      'dateAssigned': dateAssigned,
    };
  }
}

class LuckyDrawPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  LuckyDrawPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory LuckyDrawPagination.fromJson(Map<String, dynamic> json) {
    return LuckyDrawPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'pages': pages,
    };
  }
}
