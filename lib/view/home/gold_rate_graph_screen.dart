import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/custom_app_bar.dart';
import '../../services/live_rate_service.dart';
import 'live_rate_controller.dart';

class GoldRateGraphScreen extends StatefulWidget {
  const GoldRateGraphScreen({super.key});

  @override
  State<GoldRateGraphScreen> createState() => _GoldRateGraphScreenState();
} 

class _GoldRateGraphScreenState extends State<GoldRateGraphScreen> {
  late final LiveRateController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<LiveRateController>();
    c.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        appBar: CustomAppBar(
          title: 'Live Metal Rates',
          actions: [
            // ── Live / Offline indicator ─────────────────────────────────
            Obx(() => Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.isConnected.value
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5252),
                          boxShadow: [
                            BoxShadow(
                              color: c.isConnected.value
                                  ? const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.3)
                                  : const Color(0xFFFF5252)
                                      .withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.isConnected.value ? 'Live' : 'Offline',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        // ── Body ──────────────────────────────────────────────────────────
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGold),
                  SizedBox(height: 16),
                  Text(
                    'Loading Live Rates...',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _MetalTabs(c: c),
                const SizedBox(height: 16),
                _RupeeRatesRow(c: c),
                const SizedBox(height: 20),
                _ProductSection(c: c),
                const SizedBox(height: 20),
                _GraphSection(c: c),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METAL TABS — wrapped in Obx so selection state actually updates
// ─────────────────────────────────────────────────────────────────────────────
class _MetalTabs extends StatelessWidget {
  final LiveRateController c;
  const _MetalTabs({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: AppColors.primaryMaroon.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // ── Obx wraps only the reactive Row ──────────────────────────────
        child: Obx(() => Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'GOLD',
                    isSelected: c.selectedMetal.value == 'gold',
                    onTap: () => c.selectMetal('gold'),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'SILVER',
                    isSelected: c.selectedMetal.value == 'silver',
                    onTap: () => c.selectMetal('silver'),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryGold, AppColors.darkGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RUPEE RATES ROW — Obx wraps the entire row so prices update live
// ─────────────────────────────────────────────────────────────────────────────
class _RupeeRatesRow extends StatelessWidget {
  final LiveRateController c;
  const _RupeeRatesRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inr = c.rates.value?.inr;
      final gold24kVal = c.gold24kPrice * 10;
      final silver999Val = c.silver999Price;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _StatsCard(
                title: 'GOLD (10G)',
                price: gold24kVal,
                low: c.lowForKarat('24K') * 10,
                high: c.highForKarat('24K') * 10,
                direction: c.directions['k24'] ?? 'neutral',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatsCard(
                title: 'SILVER (1KG)',
                price: silver999Val,
                low: c.lowForKarat('999'),
                high: c.highForKarat('999'),
                direction: c.directions['s999'] ?? 'neutral',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatsCard(
                title: 'INR (1USD)',
                price: inr?.ask ?? 0,
                low: inr?.low ?? 0,
                high: inr?.high ?? 0,
                direction: c.directions['inr'] ?? 'neutral',
                decimalDigits: 3,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final double price;
  final double low;
  final double high;
  final String direction;
  final int decimalDigits;

  const _StatsCard({
    required this.title,
    required this.price,
    required this.low,
    required this.high,
    required this.direction,
    this.decimalDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color borderCol;
    if (direction == 'up') {
      cardBg = const Color(0xFFE8F5E9);
      borderCol = const Color(0xFF4CAF50);
    } else if (direction == 'down') {
      cardBg = const Color(0xFFFFEBEE);
      borderCol = const Color(0xFFFF5252);
    } else {
      cardBg = Colors.white;
      borderCol = AppColors.primaryMaroon.withValues(alpha: 0.1);
    }

    String fmtPrice() {
      if (price == 0) return '—';
      final formatted = price.toStringAsFixed(decimalDigits).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
      return '₹$formatted';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryMaroon,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fmtPrice(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: direction == 'up'
                  ? const Color(0xFF2E7D32)
                  : (direction == 'down'
                      ? const Color(0xFFC62828)
                      : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                low == 0 ? '—' : low.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                    fontSize: 8.5, color: AppColors.textTertiary),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('|',
                    style: TextStyle(fontSize: 8.5, color: Colors.black12)),
              ),
              Text(
                high == 0 ? '—' : high.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                    fontSize: 8.5, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT SECTION — entire section in Obx so tab switch rebuilds list
// ─────────────────────────────────────────────────────────────────────────────

class _ProductSection extends StatelessWidget {
  final LiveRateController c;
  const _ProductSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primaryMaroon.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Static header (no observables here — no Obx needed)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('PRODUCT',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PURCHASE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('BUY BACK',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black12, height: 1),

          // ── Obx ensures rows rebuild when selectedMetal or rates change ──
          Obx(() {
            final metal = c.selectedMetal.value;
            if (metal == 'gold') {
              return Column(
                children: [
                  _buildItemRow(c, 'k24', 'GOLD 999 WITH GST', '24K'),
                  _buildItemRow(c, 'k22', 'GOLD 22KT 916 HALLMARK', '22K'),
                  _buildItemRow(c, 'k20', 'GOLD 20KT HALLMARK', '20K'),
                  _buildItemRow(c, 'k18', 'GOLD 18KT HALLMARK', '18K'),
                  _buildItemRow(c, 'k14', 'GOLD 14KT HALLMARK', '14K'),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildItemRow(c, 's999', 'SILVER 999 PURITY', '999'),
                  _buildItemRow(c, 's925', 'SILVER 925 HALLMARK', '925'),
                  _buildItemRow(
                      c, 'ordinary', 'SILVER ORNAMENTS RATE', 'Ordinary'),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow(LiveRateController c, String key,
      String displayName, String karatVal) {
    final isGold = !['999', '925', 'Ordinary'].contains(karatVal);
    final double price =
        isGold ? c.priceForKarat(karatVal) * 10 : c.priceForKarat(karatVal);
    final double low =
        isGold ? c.lowForKarat(karatVal) * 10 : c.lowForKarat(karatVal);
    final double high =
        isGold ? c.highForKarat(karatVal) * 10 : c.highForKarat(karatVal);
    final direction = c.directions[key] ?? 'neutral';

    // BUY price calculated as 4% less than SELL price
    final double buyPrice = price > 0 ? (price * 0.96) : 0;
    final double buyLow = low > 0 ? (low * 0.96) : 0;

    Color sellBoxColor;
    if (direction == 'up') {
      sellBoxColor = const Color(0xFF2E7D32);
    } else if (direction == 'down') {
      sellBoxColor = const Color(0xFFC62828);
    } else {
      sellBoxColor = AppColors.primaryMaroon;
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Product name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                Text('Hallmark Guaranteed',
                    style: GoogleFonts.poppins(
                        fontSize: 8.5, color: AppColors.textTertiary)),
              ],
            ),
          ),
          // PURCHASE column (flashing box)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: sellBoxColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: direction != 'neutral'
                        ? [
                            BoxShadow(
                                color: sellBoxColor.withValues(alpha: 0.2),
                                blurRadius: 6)
                          ]
                        : [],
                  ),
                  child: Text(
                    c.formatPriceNoSymbol(price),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(high == 0 ? 'H: —' : 'H-${c.formatPriceNoSymbol(high)}',
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // BUY BACK column (calculated 4% less than SELL)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    buyPrice > 0
                        ? c.formatPriceNoSymbol(buyPrice.roundToDouble())
                        : '—',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buyLow == 0
                      ? 'L: —'
                      : 'L-${c.formatPriceNoSymbol(buyLow.roundToDouble())}',
                  style: GoogleFonts.poppins(
                      fontSize: 9, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRAPH SECTION — Obx tracks graphPoints and selectedMetal
// ─────────────────────────────────────────────────────────────────────────────
class _GraphSection extends StatelessWidget {
  final LiveRateController c;
  const _GraphSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSilver = c.selectedMetal.value == 'silver';
      final activeLabel =
          isSilver ? 'Silver 999 Live Intraday' : 'Gold 24K Live Intraday';
      final points = c.graphPoints;
      final logs = c.history24h;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primaryMaroon.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Metal Rate Trend (Live Updates)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMaroon,
                    )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            AppColors.primaryMaroon.withValues(alpha: 0.2)),
                  ),
                  child: Text('24 Hours',
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(activeLabel,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Graph Canvas
            SizedBox(
              height: 180,
              width: double.infinity,
              child: points.length < 2
                  ? const Center(
                      child: Text(
                        'Gathering hourly rates data...',
                        style:
                            TextStyle(color: Colors.black38, fontSize: 11),
                      ),
                    )
                  : CustomPaint(
                      painter: _IntradayGraphPainter(
                        points: points,
                        lineColor: AppColors.primaryMaroon,
                        gradientColors: [
                          AppColors.primaryMaroon.withValues(alpha: 0.15),
                          AppColors.primaryMaroon.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
            ),

            // X-axis time labels
            if (logs.length >= 2) ...[
              const SizedBox(height: 10),
              _buildXLabels(logs),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildXLabels(List<RateHistoryPoint> logs) {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final first = logs.first.time.toLocal();
    final mid = logs[logs.length ~/ 2].time.toLocal();
    final last = logs.last.time.toLocal();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(fmt(first),
            style: GoogleFonts.poppins(
                fontSize: 8.5, color: AppColors.textTertiary)),
        Text(fmt(mid),
            style: GoogleFonts.poppins(
                fontSize: 8.5, color: AppColors.textTertiary)),
        Text(fmt(last),
            style: GoogleFonts.poppins(
                fontSize: 8.5, color: AppColors.textTertiary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTRADAY GRAPH PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _IntradayGraphPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final List<Color> gradientColors;

  const _IntradayGraphPainter({
    required this.points,
    required this.lineColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final double minVal = points.reduce(math.min) * 0.999;
    final double maxVal = points.reduce(math.max) * 1.001;
    final double valRange = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double stepX = size.width / (points.length - 1);
    final double chartH = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = chartH / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Compute offsets
    final List<Offset> drawPoints = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final pct = (points[i] - minVal) / valRange;
      final y = chartH - (pct * chartH * 0.8) - (chartH * 0.1);
      drawPoints.add(Offset(x, y));
    }

    // Smooth bezier line
    final path = Path();
    path.moveTo(drawPoints[0].dx, drawPoints[0].dy);
    for (int i = 0; i < drawPoints.length - 1; i++) {
      final xc = (drawPoints[i].dx + drawPoints[i + 1].dx) / 2;
      final yc = (drawPoints[i].dy + drawPoints[i + 1].dy) / 2;
      path.quadraticBezierTo(drawPoints[i].dx, drawPoints[i].dy, xc, yc);
    }
    path.lineTo(drawPoints.last.dx, drawPoints.last.dy);

    // Fill gradient
    final fillPath = Path.from(path)
      ..lineTo(drawPoints.last.dx, chartH)
      ..lineTo(0, chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH))
        ..style = PaintingStyle.fill,
    );

    // Line stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Latest dot
    final latest = drawPoints.last;
    canvas.drawCircle(latest, 6, Paint()..color = lineColor.withValues(alpha: 0.2));
    canvas.drawCircle(latest, 3.5, Paint()..color = lineColor);
    canvas.drawCircle(latest, 1.8, Paint()..color = Colors.white);

    // Y-axis labels
    final lp = TextPainter(textDirection: TextDirection.ltr);
    final ts = TextStyle(
        color: AppColors.textTertiary, fontSize: 8.5, fontWeight: FontWeight.w500);
    for (int i = 0; i <= 2; i++) {
      final val = maxVal - (valRange / 2 * i);
      final y = (chartH * 0.1) + (chartH * 0.4 * i);
      lp.text = TextSpan(text: val.toStringAsFixed(0), style: ts);
      lp.layout();
      lp.paint(canvas, Offset(4, y - lp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _IntradayGraphPainter old) =>
      old.points != points || old.lineColor != lineColor;
}
