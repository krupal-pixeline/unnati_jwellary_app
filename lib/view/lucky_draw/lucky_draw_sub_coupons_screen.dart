import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../model/lucky_draw/lucky_draw_assignment_model.dart';
import '../../model/lucky_draw/my_coupon_model.dart';
import '../../services/lucky_draw_api_service.dart';
import '../../utils/app_colors.dart';

class LuckyDrawSubCouponsScreen extends StatefulWidget {
  final LuckyDrawAssignment assignment;

  const LuckyDrawSubCouponsScreen({super.key, required this.assignment});

  @override
  State<LuckyDrawSubCouponsScreen> createState() =>
      _LuckyDrawSubCouponsScreenState();
}

class _LuckyDrawSubCouponsScreenState
    extends State<LuckyDrawSubCouponsScreen> {
  final LuckyDrawApiService _apiService = LuckyDrawApiService();
  final ScrollController _scrollController = ScrollController();

  List<MyCoupon> _coupons = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _page = 1;
  final int _limit = 20; // default limit per page
  bool _hasMore = true;
  int _totalCoupons = 0;

  // Derived counts from loaded coupons
  int get _activeCount => _coupons.where((c) => c.isActive).length;
  int get _wonCount => _coupons.where((c) => c.isWon).length;

  @override
  void initState() {
    super.initState();
    _fetchMyCoupons();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if the scroll position is near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _fetchNextPage();
      }
    }
  }

  Future<void> _fetchMyCoupons() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _page = 1;
      _hasMore = true;
      _coupons.clear();
    });
    try {
      final raw = await _apiService.getMyCoupons(
        widget.assignment.batchId,
        page: _page,
        limit: _limit,
      );
      final response = MyCouponResponse.fromJson(raw);
      if (mounted) {
        setState(() {
          _coupons = response.data;
          _totalCoupons = response.pagination?.total ?? widget.assignment.couponsAssigned;
          _hasMore = _coupons.length < _totalCoupons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final nextPage = _page + 1;
      final raw = await _apiService.getMyCoupons(
        widget.assignment.batchId,
        page: nextPage,
        limit: _limit,
      );
      final response = MyCouponResponse.fromJson(raw);
      if (mounted) {
        setState(() {
          _page = nextPage;
          _coupons.addAll(response.data);
          _totalCoupons = response.pagination?.total ?? _totalCoupons;
          _hasMore = _coupons.length < _totalCoupons;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          Get.snackbar(
            'Error Loading Coupons',
            e.toString().replaceAll('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorLight,
            colorText: AppColors.error,
          );
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parsedDate = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${parsedDate.day.toString().padLeft(2, '0')} '
          '${months[parsedDate.month]} ${parsedDate.year}';
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final isActive = assignment.status.toLowerCase() == 'active';
    final formattedDate = _formatDate(assignment.dateAssigned);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'My Coupons',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ASSIGNMENT SUMMARY CARD ────────────────────────────────────
              _buildAssignmentSummaryCard(
                assignment: assignment,
                isActive: isActive,
                formattedDate: formattedDate,
              ),
              const SizedBox(height: 16),

              // ── SECTION HEADER ─────────────────────────────────────────────
              if (!_isLoading && _errorMessage == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Coupons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          if (_wonCount > 0)
                            _buildCountChip(
                                '\u{1F3C6} $_wonCount Won',
                                const Color(0xFFFFF8E1),
                                AppColors.warmGold),
                          if (_wonCount > 0) const SizedBox(width: 6),
                          if (_activeCount > 0)
                            _buildCountChip(
                                '$_activeCount Active',
                                const Color(0xFFE8F5E9),
                                const Color(0xFF2E7D32)),
                          if (_activeCount > 0) const SizedBox(width: 6),
                          _buildCountChip(
                              '$_totalCoupons Total',
                              AppColors.gray100,
                              AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              if (!_isLoading && _errorMessage == null)
                const SizedBox(height: 12),

              // ── BODY: Loading / Error / List ───────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    if (_coupons.isEmpty) return _buildEmptyState();
    return _buildCouponList();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (_, __) => _buildShimmerTicket(),
    );
  }

  Widget _buildShimmerTicket() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Failed to Load Coupons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchMyCoupons,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroonPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_activity_outlined,
                color: AppColors.champagneGold, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No Coupons Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 6),
          const Text('No coupons exist for this batch.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    return RefreshIndicator(
      onRefresh: _fetchMyCoupons,
      color: AppColors.maroonPrimary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _coupons.length + (_hasMore ? 1 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == _coupons.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.maroonPrimary),
                  ),
                ),
              ),
            );
          }
          final coupon = _coupons[index];
          return _buildCouponTicket(coupon: coupon, index: index);
        },
      ),
    );
  }

  Widget _buildAssignmentSummaryCard({
    required LuckyDrawAssignment assignment,
    required bool isActive,
    required String formattedDate,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3E121C), Color(0xFF6B1D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroonPrimary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_activity_rounded,
                      color: AppColors.champagneGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COUPON BATCH',
                        style: TextStyle(
                          color: AppColors.champagneGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Batch ID: #${assignment.batchId.split("-").last}',
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.2)
                      : AppColors.champagneGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.4)
                        : AppColors.champagneGold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  assignment.status.toUpperCase(),
                  style: TextStyle(
                    color: isActive
                        ? Colors.greenAccent
                        : AppColors.champagneGold,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            assignment.couponIdRange,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'TOTAL COUPONS',
                  _isLoading
                      ? '...'
                      : '$_totalCoupons Tickets',
                  Colors.white70,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                  'AMOUNT/COUPON',
                  '\u20B9${assignment.amountPerCoupon}',
                  AppColors.champagneGold,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                    'ASSIGNED ON', formattedDate, Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCountChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildCouponTicket({
    required MyCoupon coupon,
    required int index,
  }) {
    final status = coupon.status.toLowerCase();
    final isWon = status == 'won';
    final isActive = status == 'active';

    final Color stubColor;
    final Color cardBg;
    final Color borderColor;
    final Color codeColor;

    if (isWon) {
      stubColor = AppColors.champagneGold.withValues(alpha: 0.35);
      cardBg = const Color(0xFFFFFDE7);
      borderColor = AppColors.champagneGold.withValues(alpha: 0.5);
      codeColor = AppColors.warmGold;
    } else if (isActive) {
      stubColor = AppColors.maroonPrimary.withValues(alpha: 0.15);
      cardBg = Colors.white;
      borderColor = AppColors.maroonPrimary.withValues(alpha: 0.12);
      codeColor = AppColors.maroonPrimary;
    } else {
      stubColor = AppColors.gray300;
      cardBg = AppColors.gray100;
      borderColor = AppColors.gray300;
      codeColor = AppColors.textSecondary;
    }

    final formattedCreated = _formatDate(coupon.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 100,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isWon
            ? [
                BoxShadow(
                  color: AppColors.champagneGold.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(width: 14, color: stubColor),
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(
                color: borderColor.withValues(alpha: 0.5),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          coupon.couponCode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: codeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        _buildStatusBadge(coupon.status),
                      ],
                    ),
                    Text(
                      'Lucky Draw Coupon #${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive || isWon
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: isActive || isWon
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedCreated,
                              style: TextStyle(
                                fontSize: 10,
                                color: isActive || isWon
                                    ? AppColors.textSecondary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\u20B9${coupon.amount}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isWon
                                ? AppColors.warmGold
                                : isActive
                                    ? AppColors.champagneGold
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();

    final Color bg;
    final Color border;
    final Color dotColor;
    final Color textColor;
    final String label;
    final Widget? icon;

    if (s == 'won') {
      bg = const Color(0xFFFFF8E1);
      border = AppColors.warmGold.withValues(alpha: 0.5);
      dotColor = AppColors.warmGold;
      textColor = AppColors.warmGold;
      label = 'Won!';
      icon = const Text('\u{1F3C6}', style: TextStyle(fontSize: 9));
    } else if (s == 'active') {
      bg = const Color(0xFFE8F5E9);
      border = const Color(0xFF81C784).withValues(alpha: 0.5);
      dotColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
      label = 'Active';
      icon = null;
    } else {
      bg = AppColors.gray200;
      border = AppColors.gray300;
      dotColor = AppColors.textTertiary;
      textColor = AppColors.textSecondary;
      label = 'Expired';
      icon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    while (startY < size.height - 2) {
      canvas.drawLine(
          Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
