class LuckyDrawMyWinsResponse {
  final bool success;
  final List<LuckyDrawWinItem> data;

  LuckyDrawMyWinsResponse({
    required this.success,
    required this.data,
  });

  factory LuckyDrawMyWinsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return LuckyDrawMyWinsResponse(
      success: json['success'] as bool? ?? false,
      data: list
          .map((item) => LuckyDrawWinItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LuckyDrawWinItem {
  final String luckyDrawId;
  final String winningCouponCode;
  final int amount;
  final String drawDate;
  final String rangeSelected;

  LuckyDrawWinItem({
    required this.luckyDrawId,
    required this.winningCouponCode,
    required this.amount,
    required this.drawDate,
    required this.rangeSelected,
  });

  factory LuckyDrawWinItem.fromJson(Map<String, dynamic> json) {
    return LuckyDrawWinItem(
      luckyDrawId: json['luckyDrawId'] as String? ?? '',
      winningCouponCode: json['winningCouponCode'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      drawDate: json['drawDate'] as String? ?? '',
      rangeSelected: json['rangeSelected'] as String? ?? '',
    );
  }

  // Check if this win is older than 7 days from now
  bool get isWithinLast7Days {
    try {
      final parsedDate = DateTime.parse(drawDate);
      final difference = DateTime.now().difference(parsedDate).inDays;
      return difference <= 7;
    } catch (_) {
      return false;
    }
  }
}
