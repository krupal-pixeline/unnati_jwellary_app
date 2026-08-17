import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../model/lucky_draw/lucky_draw_my_wins_model.dart';
import 'lucky_draw_controller.dart';
import 'lucky_draw_sub_coupons_screen.dart';

class LuckyDrawScreen extends StatelessWidget {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LuckyDrawController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Obx(() {
          final Map<String, String> latestWinner = (() {
            if (controller.history.isNotEmpty) {
              final latest = controller.history.first;
              String formattedDate = '';
              try {
                final parsedDate = DateTime.parse(latest.createdAt);
                final months = [
                  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ];
                formattedDate = "${parsedDate.day.toString().padLeft(2, '0')} ${months[parsedDate.month]} ${parsedDate.year}";
              } catch (_) {
                formattedDate = latest.createdAt.split('T').first;
              }

              return {
                'date': formattedDate,
                'ticketNo': latest.winningCouponCode,
                'winner': latest.customerId?.fullName ?? 'Anonymous',
                'prize': 'Grand Draw Winner',
                'drawRef': '#LD-${latest.id.substring(latest.id.length - 4)}',
              };
            }
            return {
              'date': '02 July 2026',
              'ticketNo': 'TKT-90182',
              'winner': 'Ramesh S. (Ahmedabad)',
              'prize': '',
              'drawRef': '#LDK-4821',
            };
          })();

          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primaryMaroon,
                onRefresh: () => controller.refreshAllData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── MY WINS SECTION (Real API Data - horizontal slider) ─────────
                      _buildMyWinsSection(controller),

                      // ── MY COUPONS SECTION (Real API Data) ─────────────────────────
                      _buildMyCouponsSection(controller),
                      if (controller.assignments.isNotEmpty) const SizedBox(height: 24),

                      // ── RECENT WINNERS LIST ────────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Recent Lucky Draw Winners',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWinnersList(controller),
                      const SizedBox(height: 100), // Spacing for bottom nav bar
                    ],
                  ),
                ),
              ),

              // Full-Screen Celebration overlay when active (shows for 4 seconds)
              if (controller.showCelebration.value)
                CelebrationOverlay(
                  winnerName: latestWinner['winner'] ?? 'Ramesh S. (Ahmedabad)',
                  prizeName: latestWinner['prize'] ?? '',
                  ticketNo: latestWinner['ticketNo'] ?? 'TKT-90182',
                  onDismiss: () => controller.showCelebration.value = false,
                ),
            ],
          );
        }),
      ),
    );
  }


  // ── My Coupons Section Widget (Real API Assignments) ───────────────────────
  Widget _buildMyCouponsSection(LuckyDrawController controller) {
    // Show loading shimmer while API is fetching
    if (controller.isAssignmentsLoading.value) {
      return _buildMyCouponsShimmer();
    }

    // Show error state if fetch failed
    if (controller.assignments.isEmpty && controller.errorMessage.value.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'My Coupons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => controller.fetchAssignments(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryMaroon,
                    side: const BorderSide(color: AppColors.primaryMaroon),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Hide section if no assignments found
    if (controller.assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Build cards from real API assignments
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'My Coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...controller.assignments.map((assignment) {
          final totalCount = assignment.couponsAssigned;
          final isActive = assignment.status.toLowerCase() == 'active';
          // couponIdRange e.g. "UJ000000040 to UJ000000049"
          final rangeParts = assignment.couponIdRange.split(' to ');
          final rangeLabel = rangeParts.length == 2
              ? 'Range: ${rangeParts[0]} – ${rangeParts[1]}'
              : assignment.couponIdRange;

          return GestureDetector(
            onTap: () => Get.to(
              () => LuckyDrawSubCouponsScreen(assignment: assignment),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.champagneGold.withValues(alpha: 0.35),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    // Left Stub (Trophy Icon + Badge)
                    Container(
                      width: 80,
                      color: AppColors.champagneGold.withValues(alpha: 0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.champagneGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MEGA DRAW',
                              style: TextStyle(
                                color: AppColors.warmGold,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dashed Divider line
                    CustomPaint(
                      size: const Size(1, double.infinity),
                      painter: DashedLinePainter(
                        color: AppColors.champagneGold.withValues(alpha: 0.4),
                      ),
                    ),

                    // Right details area
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    rangeLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.maroonPrimary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppColors.champagneGold,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildCountBadge(
                                      'Total: $totalCount',
                                      Colors.blue.shade50,
                                      Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCountBadge(
                                      isActive ? 'Active' : assignment.status,
                                      isActive ? Colors.green.shade50 : Colors.orange.shade50,
                                      isActive ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Tap to view →',
                                  style: TextStyle(
                                    color: AppColors.champagneGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCountBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ——————————————————————————— Winners List Widget (Dynamic History from API) ———————————————————————————
  Widget _buildWinnersList(LuckyDrawController controller) {
    if (controller.isHistoryLoading.value && controller.history.isEmpty) {
      return _buildWinnersListShimmer();
    }

    if (controller.history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No history items found.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.history.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final w = controller.history[index];

            String formattedDate = '';
            try {
              final parsedDate = DateTime.parse(w.createdAt);
              final months = [
                '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              formattedDate = "${parsedDate.day.toString().padLeft(2, '0')} ${months[parsedDate.month]} ${parsedDate.year}";
            } catch (_) {
              formattedDate = w.createdAt.split('T').first;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(179), // 0.7 * 255 = 179
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withAlpha(204)), // 0.8 * 255 = 204
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.paleGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🏆', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.customerId?.fullName ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ticket: ${w.winningCouponCode}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (controller.historyPage.value < controller.historyTotalPages.value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: controller.isHistoryLoadingMore.value
                ? const Center(
                    child: ShimmerWidget(
                      width: 140,
                      height: 36,
                      borderRadius: 30,
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => controller.fetchHistory(isLoadMore: true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryMaroon, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      'Load More Winners',
                      style: TextStyle(
                        color: AppColors.primaryMaroon,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }

  // ── My Wins Section Widget (Real API Data - horizontal slider) ──────────────
  Widget _buildMyWinsSection(LuckyDrawController controller) {
    if (controller.isMyWinsLoading.value) {
      return _buildMyWinsShimmer();
    }

    if (controller.myWins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '🎉 My Wins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(Last 7 Days)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.myWins.length,
            itemBuilder: (context, index) {
              final LuckyDrawWinItem win = controller.myWins[index];
              
              // Format date nicely
              String formattedDate = '';
              try {
                final parsedDate = DateTime.parse(win.drawDate);
                final months = [
                  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ];
                formattedDate = "${parsedDate.day.toString().padLeft(2, '0')} ${months[parsedDate.month]} ${parsedDate.year}";
              } catch (_) {
                formattedDate = win.drawDate.split('T').first;
              }

              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C0A10), Color(0xFF6B1D2E), Color(0xFF901F37)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryMaroon.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Decorative background circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -40,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.champagneGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.champagneGold.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🏆 ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'WINNER',
                                        style: TextStyle(
                                          color: AppColors.champagneGold,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WINNING COUPON',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  win.winningCouponCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SELECTED RANGE',
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      win.rangeSelected,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.champagneGold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '₹${win.amount}',
                                    style: const TextStyle(
                                      color: AppColors.maroonPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Shimmer Loading Helpers ────────────────────────────────────────────────
  Widget _buildMyWinsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ShimmerWidget(width: 140, height: 20, borderRadius: 6),
        ),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 2,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 175,
                borderRadius: 18,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMyCouponsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'My Coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: const ShimmerWidget(
              width: double.infinity,
              height: 110,
              borderRadius: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnersListShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          4,
          (index) => const ShimmerWidget(
            width: double.infinity,
            height: 60,
            borderRadius: 12,
            margin: EdgeInsets.only(bottom: 10),
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    while (startY < size.height - 2) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ——————————————————————————— Confetti Particle Model ——————————————————————————————————————————————————————————
class ConfettiParticle {
  double x;
  double y;
  Color color;
  double size;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;
  int shape; // 0: rect, 1: circle, 2: triangle

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

// ——————————————————————————— Confetti Particle Custom Painter ————————————————————————————————————————————————
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.shape == 0) {
        // Rectangle
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      } else if (p.shape == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Triangle
        final path = Path();
        path.moveTo(0, -p.size / 2);
        path.lineTo(p.size / 2, p.size / 2);
        path.lineTo(-p.size / 2, p.size / 2);
        path.close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ——————————————————————————— Full Screen Celebration Overlay Widget ———————————————————————————————————————————
class CelebrationOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final String winnerName;
  final String prizeName;
  final String ticketNo;

  const CelebrationOverlay({
    super.key,
    required this.onDismiss,
    required this.winnerName,
    required this.prizeName,
    required this.ticketNo,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Ticker _ticker;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  
  final List<Color> _confettiColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFD4AF37), // Gold
  ];

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeIn,
    );

    _cardController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 110; i++) {
        _particles.add(ConfettiParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * -size.height - 20,
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          size: _random.nextDouble() * 11 + 6,
          speedY: _random.nextDouble() * 4 + 3,
          speedX: _random.nextDouble() * 2 - 1,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: _random.nextDouble() * 0.1 - 0.05,
          shape: _random.nextInt(3),
        ));
      }
    });

    _ticker = createTicker((elapsed) {
      final size = MediaQuery.of(context).size;
      if (_particles.isEmpty) return;

      setState(() {
        for (var p in _particles) {
          p.y += p.speedY;
          p.x += p.speedX + math.sin(p.y / 24) * 0.4;
          p.rotation += p.rotationSpeed;

          if (p.y > size.height) {
            p.y = -20;
            p.x = _random.nextDouble() * size.width;
          }
        }
      });
    });
    _ticker.start();

    // Self-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _cardController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Premium Backdrop Blur
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),

          // Rain Confetti CustomPainter
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: ConfettiPainter(particles: _particles),
            ),
          ),

          // Central Announcement Card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.champagneGold,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.champagneGold.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🏆',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(
                          color: AppColors.maroonPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Lucky Draw Winner Announced',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.maroonPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.maroonPrimary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.winnerName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.maroonPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prize: ${widget.prizeName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.champagneGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ticket: ${widget.ticketNo}',
                                style: const TextStyle(
                                  color: AppColors.warmGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _cardController.reverse().then((_) {
                            widget.onDismiss();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroonPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'Awesome!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Widget (Animated Gradient Placeholder) ───────────────────────────
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, -0.3),
              end: Alignment(_animation.value + 1, 0.3),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }
}
