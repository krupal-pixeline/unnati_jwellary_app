import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../add_scheme/add_scheme_screen.dart';
import '../activated_scheme/activated_scheme_screen.dart';
import '../activated_scheme/activated_scheme_controller.dart';
import 'suvarna_main_controller.dart';
import 'youtube_video_player_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SuvarnaMainScreen extends StatelessWidget {
  const SuvarnaMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SuvarnaMainController());
    final activeController = Get.put(ActivatedSchemeController());

    return Obx(() {
      if (activeController.schemes.isNotEmpty) {
        return const ActivatedSchemeScreen();
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await activeController.fetchMySchemes();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _ActiveSchemesBanner(controller: activeController),
                    const SizedBox(height: 24),

                // ── VIDEO SECTION
                _SectionHeader(
                  icon: Icons.play_circle_fill_rounded,
                  title: 'Watch & Learn',
                ),
                const SizedBox(height: 12),
                const _VideoSection(),

                const SizedBox(height: 28),

                // HOW IT WORKS
                _SectionHeader(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'How It Works',
                ),
                const SizedBox(height: 12),
                const _SuvarnaUnnatiHowItWorksCard(),
                const SizedBox(height: 28),

                // ── BENEFITS ───────────────────────────────────────────
                _SectionHeader(
                  icon: Icons.stars_rounded,
                  title: 'Benefits Of Suvarna Unnati',
                ),
                const SizedBox(height: 12),
                _BenefitsGrid(),

                const SizedBox(height: 28),

                // ── IMPORTANT NOTES ────────────────────────────────────
                _ImportantNoteCard(),

                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _CtaButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gold, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO SECTION (Horizontal multi-video playlist)
// ─────────────────────────────────────────────────────────────────────────────
class _VideoSection extends StatelessWidget {
  const _VideoSection();

  final List<Map<String, String>> youtubeVideos = const [
    {
      'id': '8nyjzyAij9Q',
      'title': 'Suvarna Unnati Scheme Intro',
      'desc': 'Get a detailed walkthrough of the gold investment program, monthly installments, and how Unnati Jewelers contributes bonus months to secure your wedding or savings portfolio.',
      'duration': '5:24',
    },
    {
      'id': 'M7lc1UVf-VE',
      'title': 'Gold Weight Savings Benefits',
      'desc': 'Learn the benefits of Gold Weight accumulation and how you can shield your investment from gold rate inflation.',
      'duration': '3:40',
    },
    {
      'id': 'dQw4w9WgXcQ',
      'title': 'Scheme Benefits & Maturity',
      'desc': 'Understand the maturity payouts, gold rate locking features, and direct benefits available upon redemption of your Unnati savings account.',
      'duration': '4:15',
    },
    {
      'id': 'y881t8ilMyc',
      'title': 'Purity Guarantee Promise',
      'desc': 'Discover our absolute purity promise. We showcase our 100% HUID Hallmarking guidelines and quality verification labs.',
      'duration': '5:12',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: youtubeVideos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final video = youtubeVideos[index];
          final String thumbnailUrl = 'https://img.youtube.com/vi/${video['id']}/hqdefault.jpg';

          return GestureDetector(
            onTap: () {
              Get.to(
                () => const YoutubeVideoPlayerScreen(),
                arguments: video,
              );
            },
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thumbnail Image stack with play overlay
                  Expanded(
                    flex: 12,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.play_circle_filled_rounded,
                                color: AppColors.gold,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                        // Dark tint overlay
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                        ),
                        // Centered Play Button
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.goldLight,
                              size: 26,
                            ),
                          ),
                        ),
                        // Duration Badge at bottom right
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video['duration']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Title and Short Description
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              video['desc']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.textMedium,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suvarna UNNATI HOW IT WORKS CARD
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Suvarna UNNATI HOW IT WORKS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SuvarnaUnnatiHowItWorksCard extends StatefulWidget {
  const _SuvarnaUnnatiHowItWorksCard();

  @override
  State<_SuvarnaUnnatiHowItWorksCard> createState() =>
      _SuvarnaUnnatiHowItWorksCardState();
}

class _SuvarnaUnnatiHowItWorksCardState
    extends State<_SuvarnaUnnatiHowItWorksCard> {
  int _selectedTab = 0; // 0 = Invest on Money, 1 = Invest on Gold
  int _selectedTenure = 10; // 10 or 20
  double _monthlyAmount = 10000;

  @override
  Widget build(BuildContext context) {
    final activeController = Get.find<ActivatedSchemeController>();
    return Obx(() {
      final double goldRate = activeController.liveGoldRate.value;
      final double calculatedWeight = _monthlyAmount / goldRate;
      final int bonusMonths = _selectedTenure ~/ 10;
      final int totalMonths = _selectedTenure + bonusMonths;

      return _PremiumCard(
        borderColor: AppColors.gold.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sliding Tab Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('💰', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Invest on Money',
                              style: GoogleFonts.poppins(
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⚖️', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Invest on Gold',
                              style: GoogleFonts.poppins(
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Explanation Description
            Text(
              _selectedTab == 0
                  ? 'Invest a fixed amount of money every month for $_selectedTenure months. At maturity, Unnati Jewelers adds $bonusMonths extra monthly installment${bonusMonths > 1 ? "s" : ""} as a bonus. You get 10% instant profit!'
                  : 'Accumulate fixed weight of gold every month for $_selectedTenure months. At maturity, Unnati Jewelers contributes $bonusMonths month${bonusMonths > 1 ? "s" : ""} worth of gold weight as a bonus to your account.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // 3. Calculator Title / Interactive Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Installment',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '₹${_monthlyAmount.toInt().toString()}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                thumbColor: AppColors.gold,
                overlayColor: AppColors.gold.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _monthlyAmount,
                min: 1000,
                max: 10000,
                divisions: 45,
                onChanged: (val) {
                  setState(() {
                    _monthlyAmount = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),

            // 3.5. Fixed Tenure Row Selection (10 Months vs 20 Months)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Scheme Tenure',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _tenureButton(10),
                      const SizedBox(width: 4),
                      _tenureButton(20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Live Calculation Output Box
            _ExampleBox(
              title: _selectedTab == 0
                  ? 'Invest on Money Maturity Summary'
                  : 'Invest on Gold Maturity Summary',
              rows: _selectedTab == 0
                  ? [
                      _InfoRow(
                        label: 'Your Monthly Payment',
                        value: '₹${_monthlyAmount.toInt()}',
                        highlight: false,
                      ),
                      _InfoRow(
                        label: 'Tenure Regular Payments',
                        value: '$_selectedTenure Months',
                        highlight: false,
                      ),
                      _InfoRow(
                        label: 'Total Paid by You',
                        value: '₹${(_monthlyAmount * _selectedTenure).toInt()}',
                        highlight: false,
                      ),
                      _InfoRow(
                        label:
                            'Unnati Bonus ($bonusMonths Month${bonusMonths > 1 ? "s" : ""})',
                        value: '₹${(_monthlyAmount * bonusMonths).toInt()}',
                        highlight: true,
                        customColor: AppColors.success,
                      ),
                      _InfoRow(
                        label: 'Total Maturity Value',
                        value: '₹${(_monthlyAmount * totalMonths).toInt()}',
                        highlight: true,
                      ),
                    ]
                  : [
                      _InfoRow(
                        label: 'Your Monthly Gold Saved',
                        value:
                            '${calculatedWeight.toStringAsFixed(2)} g (≈ ₹${_monthlyAmount.toInt()})',
                        highlight: false,
                      ),
                      _InfoRow(
                        label: 'Tenure Regular Accumulations',
                        value: '$_selectedTenure Months',
                        highlight: false,
                      ),
                      _InfoRow(
                        label: 'Total Gold Saved by You',
                        value:
                            '${(calculatedWeight * _selectedTenure).toStringAsFixed(2)} g (≈ ₹${(_monthlyAmount * _selectedTenure).toInt()})',
                        highlight: false,
                      ),
                      _InfoRow(
                        label:
                            'Unnati Bonus ($bonusMonths Month${bonusMonths > 1 ? "s" : ""})',
                        value:
                            '${(calculatedWeight * bonusMonths).toStringAsFixed(2)} g (≈ ₹${(_monthlyAmount * bonusMonths).toInt()})',
                        highlight: true,
                        customColor: AppColors.success,
                      ),
                      _InfoRow(
                        label: 'Total Maturity Gold Qty',
                        value:
                            '${(calculatedWeight * totalMonths).toStringAsFixed(2)} g (≈ ₹${(_monthlyAmount * totalMonths).toInt()})',
                        highlight: true,
                      ),
                    ],
            ),
            const SizedBox(height: 16),

            // Journey Stepper
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 How the Profit Works:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _stepRow('1', 'Pay regularly for $_selectedTenure months.'),
                  _stepRow(
                    '2',
                    'We add $bonusMonths extra installment${bonusMonths > 1 ? "s" : ""} absolutely FREE.',
                  ),
                  _stepRow('3', 'Redeem total value for jewelry at maturity.'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _tenureButton(int months) {
    final isSelected = _selectedTenure == months;
    return GestureDetector(
      onTap: () => setState(() => _selectedTenure = months),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$months Months',
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _stepRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BENEFITS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _BenefitsGrid extends StatelessWidget {
  static const List<_BenefitItem> _items = [
    _BenefitItem(
      icon: Icons.security_rounded,
      label: 'Safe Investment',
      color: AppColors.success,
    ),
    _BenefitItem(
      icon: Icons.show_chart_rounded,
      label: 'Live Gold Rate Tracking',
      color: AppColors.goldDark,
    ),
    _BenefitItem(
      icon: Icons.receipt_long_rounded,
      label: 'Digital Records',
      color: AppColors.blueAccent,
    ),
    _BenefitItem(
      icon: Icons.price_check_rounded,
      label: 'Transparent Pricing',
      color: AppColors.primary,
    ),
    _BenefitItem(
      icon: Icons.tune_rounded,
      label: 'Flexible Investment Options',
      color: AppColors.purpleAccent,
    ),
    _BenefitItem(
      icon: Icons.trending_up_rounded,
      label: 'Long Term Wealth Growth',
      color: AppColors.orangeAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) => _BenefitTile(item: _items[i]),
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final String label;
  final Color color;
  const _BenefitItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _BenefitTile extends StatelessWidget {
  final _BenefitItem item;
  const _BenefitTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const Spacer(),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT NOTE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ImportantNoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Important Notes',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            'Gold prices are market dependent.',
            'Investment values may fluctuate.',
            'Live gold rates are used for all calculations.',
            'Please read all scheme details carefully before proceeding.',
          ].map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _CtaButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => AddSchemeScreen());
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start Suvarna Unnati',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Base premium card with consistent styling
class _PremiumCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _PremiumCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Example box with label-value rows
class _ExampleBox extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<_InfoRow> rows;

  const _ExampleBox({
    required this.title,
    required this.rows,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calculate_outlined, color: accentColor, size: 14),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: rows
                  .map((r) => _RowWidget(row: r, accent: accentColor))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool highlight;
  final Color? customColor;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.highlight,
    this.customColor,
  });
}

class _RowWidget extends StatelessWidget {
  final _InfoRow row;
  final Color accent;
  const _RowWidget({required this.row, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: row.highlight
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (row.customColor ?? accent).withValues(alpha: 0.15),
                  (row.customColor ?? accent).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (row.customColor ?? accent).withValues(alpha: 0.3),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Text(
            row.value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w600,
              color: row.highlight
                  ? (row.customColor ?? accent)
                  : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSchemesBanner extends StatelessWidget {
  final ActivatedSchemeController controller;
  const _ActiveSchemesBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.schemes.isEmpty) return const SizedBox();

      return GestureDetector(
        onTap: () => Get.to(() => const ActivatedSchemeScreen()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You have ${controller.schemes.length} Active Schemes",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Total saved: ${controller.formatGrams(controller.totalGoldAccumulated)} gold",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
