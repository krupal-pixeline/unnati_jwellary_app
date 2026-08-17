import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';
import 'about_us_controller.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutUsController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: const CustomAppBar(title: "About Us"),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 0. Single Store Image Banner (No Carousel) ────────────────
              _SingleStoreImageBanner(ctrl: controller, size: size),

              // ── Top Brand Showcase Banner ────────────────────────────────
              _buildTopHeroBanner(),

              // ── 1. Our Foundation Section ──────────────────────────────────
              _buildOurFoundationSection(),

              // ── 2. The Philosophy Section (Imperial Maroon) ───────────────
              _buildPhilosophySection(),

              // ── 3. Our Stance & Gold & Jewels Cards Section ──────────────
              _buildStanceAndJewelsSection(),

              // ── 4. Our Legacy Expandable & Collapsible Timeline ───────────
              _buildOurLegacyTimelineSection(controller),

              // ── 5. Our Protocol & Our Mindset Section ─────────────────────
              _buildProtocolAndMindsetSection(),

              // ── 6. Evolving Standards & Suvarna Program Section ────────────
              _buildStandardsAndSuvarnaSection(),

              // ── 7. Generations Of Trust Section (Imperial Maroon) ────────
              _buildGenerationsOfTrustSection(),

              // ── 8. The Unnati Promise Section ─────────────────────────────
              _buildUnnatiPromiseSection(),

              // ── 9. Live Store Location & Showroom Info ────────────────────
              _buildStoreDetailsSection(controller),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── 0. Top Hero Banner Card ───────────────────────────────────────────────
  Widget _buildTopHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A0815),
            AppColors.primaryMaroon,
            Color(0xFF5A0C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/app_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.diamond_rounded,
                  size: 34,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryGold,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "SINCE 1995",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "UNNATI JEWELLERS",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Crafting Memories, Building Trust Across Generations",
                  style: GoogleFonts.outfit(
                    color: AppColors.champagneGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Our Foundation Section ─────────────────────────────────────────────
  Widget _buildOurFoundationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          _buildKicker("— OUR FOUNDATION —", isDark: false),
          const SizedBox(height: 12),
          Text(
            "Never Recommend A Purchase That Is Not In Our Customer's Best Interest.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: AppColors.primaryMaroon,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "For More Than Three Decades, We Have Served Families Not Merely As Jewellers, But As Trusted Advisors, Value Creators, And Long-Term Partners In Some Of Life's Most Important Decisions.",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryMaroon.withValues(alpha: 0.85),
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "At Unnati Jewellers, We Believe That Business Is Built On Ethics. Trends Change, Markets Fluctuate, And Customer Expectations Evolve, But Integrity Remains Timeless. Our Experience Has Taught Us A Simple Truth: When Business Is Conducted With Ethics, Growth Follows Naturally. This Belief Has Guided Every Customer Interaction, Every Recommendation, And Every Relationship We Have Built Since 1995.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. The Philosophy Section ──────────────────────────────────────────────
  Widget _buildPhilosophySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A0815),
            AppColors.primaryMaroon,
            Color(0xFF5A0C1C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKicker("— THE PHILOSOPHY", isDark: true),
          const SizedBox(height: 10),
          Text(
            'What "Unnati" Means',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The Word "Unnati" Translates To Growth, Progress, And Prosperity. But To Us, Growth Is Never Measured Solely By Business Balances Or Sale Turnovers.',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.champagneGold,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "True Growth Occurs When Our Customers Make Informed Decisions, Achieve Their Goals, Strengthen Their Financial Security, And Celebrate Life's Milestones With Absolute Confidence.",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "We Sincerely Wish Growth For Every Individual And Family That Places Their Trust In Us. Because We Believe That When Our Customers Grow, We Grow With Them.",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPhilosophyCard(
                  icon: Icons.trending_up_rounded,
                  title: "True Growth",
                  description:
                      "Calculated Through Customer Prosperity, Not Just Numbers.",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPhilosophyCard(
                  icon: Icons.favorite_border_rounded,
                  title: "Celebrations",
                  description:
                      "Adding Confidence To Your Life's Most Meaningful Moments.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.outfit(
              color: AppColors.champagneGold.withValues(alpha: 0.9),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Our Stance & Gold & Jewels Cards Section ───────────────────────────
  Widget _buildStanceAndJewelsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          _buildInfoBoxCard(
            kicker: "— OUR STANCE",
            title: "Honest Guidance Over Transaction Value",
            paragraphs: [
              "We Believe That Customers Deserve Honest Guidance, Transparent Advice, And Complete Clarity Before Making Any Purchase. We Do Not Believe In Creating Pressure, Encouraging Unnecessary Spending, Or Promoting Purchases Simply For Appearances.",
              "In Fact, Many Of Our Most Meaningful Customer Relationships Have Been Built Through Conversations Where We Advised Customers To Stay Within Their Budget And Choose What Was Genuinely Right For Them.",
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBoxCard(
            kicker: "— GOLD & JEWELS",
            title: "More Than Jewellery",
            paragraphs: [
              "We Believe That Gold Is Not Just A Precious Metal. It Is A Family's Strongest Supporter During Difficult Times, A Trusted Store Of Value, And A Symbol Of Financial Security That Can Serve Generations.",
              "We Believe That Jewellery Is Not Just An Ornament. It Is A Reflection Of Personality, Confidence, Culture, Celebration, And Self-Expression. It Represents Memories, Milestones, Achievements, And Moments That Become Part Of A Family's Story.",
              "That Is Why Every Purchase Deserves Careful Thought, Honest Advice, And Complete Transparency.",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBoxCard({
    required String kicker,
    required String title,
    required List<String> paragraphs,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKicker(kicker, isDark: false),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: AppColors.primaryMaroon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                p,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Expandable & Collapsible Legacy Timeline Section ────────────────────
  Widget _buildOurLegacyTimelineSection(AboutUsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A0815),
            AppColors.primaryMaroon,
            Color(0xFF5A0C1C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildKicker("OUR JOURNEY", isDark: true),
          const SizedBox(height: 8),
          Text(
            "Our Legacy",
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap any milestone to view our journey",
            style: GoogleFonts.outfit(
              color: AppColors.champagneGold.withValues(alpha: 0.8),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.timelineItems.length,
            itemBuilder: (context, index) {
              final item = controller.timelineItems[index];
              final isLast = index == controller.timelineItems.length - 1;

              return Obx(() {
                final isExpanded = controller.timelineExpanded[index].value;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => controller.toggleTimelineItem(index),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? AppColors.primaryGold
                                      : Colors.white.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryGold,
                                    width: isExpanded ? 2 : 1,
                                  ),
                                  boxShadow: isExpanded
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryGold
                                                .withValues(alpha: 0.6),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.primaryGold
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.toggleTimelineItem(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isExpanded
                                    ? AppColors.primaryGold
                                    : AppColors.primaryGold
                                        .withValues(alpha: 0.25),
                                width: isExpanded ? 1.2 : 1,
                              ),
                              boxShadow: isExpanded
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryGold
                                            .withValues(alpha: 0.15),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['year'] ?? '',
                                      style: GoogleFonts.cinzel(
                                        color: AppColors.primaryGold,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primaryGold,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['title'] ?? '',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    item['description'] ?? '',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white
                                          .withValues(alpha: 0.88),
                                      fontSize: 11.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // ── 5. Our Protocol & Our Mindset Section ────────────────────────────────
  Widget _buildProtocolAndMindsetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKicker("— OUR PROTOCOL", isDark: false),
                const SizedBox(height: 8),
                Text(
                  "Education Before Transaction",
                  style: GoogleFonts.cinzel(
                    color: AppColors.primaryMaroon,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "One Of The Principles That Distinguishes Unnati Jewellers Is Our Commitment To Customer Education. We Believe That Informed Customers Make Better Decisions.\n\nBefore Making A Purchase, Customers Deserve To Understand Every Aspect Of It – Purity, Pricing, Making Charges, Value, Exchange Benefits, Investment Considerations, And Long-Term Implications.\n\nOur Goal Is Not Simply To Complete A Transaction. Our Goal Is To Ensure That Every Customer Leaves With Confidence, Clarity, And Peace Of Mind. We Want Our Customers To Leave Happier And More Knowledgeable Than When They Entered.",
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "EDUCATION FIRST",
                        style: GoogleFonts.cinzel(
                          color: AppColors.primaryMaroon,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKicker("— OUR MINDSET", isDark: false),
                const SizedBox(height: 8),
                Text(
                  "Creating Value, Not Transactions",
                  style: GoogleFonts.cinzel(
                    color: AppColors.primaryMaroon,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We Do Not See Ourselves As Jewellery Sellers. We See Ourselves As Value Creators. Every Recommendation, Every Design, Every Service, And Every Customer Interaction Is Guided By One Question:",
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '“How Can We Create The Maximum Value For This Customer?”',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.primaryMaroon,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Sometimes That Means Helping A Customer Find The Perfect Design. Sometimes It Means Guiding Them Toward A Better Investment Decision. Sometimes It Means Advising Them Not To Spend Beyond Their Means. For Us, Value Creation Always Comes Before Transaction Value.",
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "VALUE CREATORS",
                        style: GoogleFonts.cinzel(
                          color: AppColors.primaryMaroon,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Evolving Standards & Suvarna Program Section ───────────────────────
  Widget _buildStandardsAndSuvarnaSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          _buildInfoBoxCard(
            kicker: "— EVOLVING STANDARDS",
            title: "Our Commitment To Innovation",
            paragraphs: [
              "As A Modern Luxury Jeweller, We Continuously Evolve With Changing Customer Expectations, New Technologies, And Emerging Design Trends. We Take Pride In Offering Contemporary Jewellery Collections While Preserving The Values That Have Defined Our Business For Decades.",
              "From Trending Designs To Highly Customized Creations, We Welcome Challenges That Allow Us To Bring Our Customers' Visions To Life. No Matter How Unique Or Demanding A Requirement May Be, We Approach It With Dedication, Craftsmanship, And A Determination To Deliver Excellence. Because We Never Like To See Our Customers Leave Disappointed.",
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBoxCard(
            kicker: "— THE SUVARNA PROGRAM",
            title: "Suvarna Unnati Scheme",
            paragraphs: [
              "For Many Years, Families Trusted Us To Help Them Acquire Jewellery Through Flexible And Comfortable Payment Arrangements Built On Mutual Trust And Long-Term Relationships. As Times Changed And Customer Needs Evolved, This Philosophy Was Transformed Into The Suvarna Unnati Scheme.",
              "The Scheme Represents Our Ongoing Commitment To Helping Customers Plan Their Jewellery Purchases Responsibly While Enjoying Meaningful Benefits. Although The Structure Has Evolved, The Objective Remains Unchanged: Making Jewellery Ownership More Accessible, Convenient, And Rewarding For Our Customers.",
            ],
          ),
        ],
      ),
    );
  }

  // ── 7. Generations Of Trust Section ───────────────────────────────────────
  Widget _buildGenerationsOfTrustSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A0815),
            AppColors.primaryMaroon,
            Color(0xFF5A0C1C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.diversity_3_rounded,
            color: AppColors.primaryGold,
            size: 32,
          ),
          const SizedBox(height: 8),
          _buildKicker("OUR LEGACY", isDark: true),
          const SizedBox(height: 6),
          Text(
            "Generations Of Trust",
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "One Of Our Greatest Achievements Is Not The Jewellery We Have Sold, But The Relationships We Have Built.\n\nToday, Many Families Who First Visited Us Decades Ago Continue To Trust Us Through Their Children And Grandchildren. Being A Part Of Multiple Generations Of The Same Family's Journey Is A Privilege We Deeply Value And Never Take For Granted. These Relationships Remind Us That Trust Is Earned Slowly, Protected Carefully, And Passed Forward Through Consistent Actions Over Time.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.primaryGold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: "Quality Without Compromise: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Every Jewellery Piece Offered By Unnati Jewellers Is BIS Hallmarked, Ensuring Authenticity, Purity, And Absolute Confidence.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. The Unnati Promise Section ────────────────────────────────────────
  Widget _buildUnnatiPromiseSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 2,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 14),
          _buildKicker("— OUR PLEDGE —", isDark: false),
          const SizedBox(height: 8),
          Text(
            "The Unnati Promise",
            style: GoogleFonts.cinzel(
              color: AppColors.primaryMaroon,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "“At Unnati Jewellers, Success Is Not Measured By The Size Of A Transaction. Success Is Measured By The Confidence A Customer Feels After Making The Right Decision. It Is Measured By Relationships That Last Decades. It Is Measured By Trust That Extends Across Generations. And It Is Measured By The Growth, Prosperity, And Happiness Of The Families We Proudly Serve.”",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryMaroon.withValues(alpha: 0.9),
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "THAT IS THE MEANING OF UNNATI.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: AppColors.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "THAT IS OUR PURPOSE. AND THAT IS OUR PROMISE.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: AppColors.primaryMaroon,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── 9. Live Store Location & Showroom Info (Zero Overflow) ───────────────
  Widget _buildStoreDetailsSection(AboutUsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() {
        final store = controller.storeData.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primaryMaroon,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Visit Our Showroom",
                  style: GoogleFonts.cinzel(
                    color: AppColors.primaryMaroon,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 14),
            Text(
              store?.address ??
                  "GROUND FLOOR, SHOP NO.2, SHANTI SKY, WAGHAVADI ROAD,\nPARIMAL CHOWK, Bhavnagar, Gujarat, 364001",
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Hours details
            if (store?.hoursWeekdays != null && store!.hoursWeekdays.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded,
                      size: 16, color: AppColors.primaryGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.hoursWeekdays,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (store?.hoursSunday != null && store!.hoursSunday.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.event_seat_rounded,
                      size: 16, color: AppColors.primaryMaroon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.hoursSunday,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Row 1: Call Store & Email Us
            Row(
              children: [
                Expanded(
                  child: _storeActionButton(
                    icon: Icons.phone_rounded,
                    label: "Call Store",
                    color: const Color(0xFF2E7D32),
                    onTap: () => controller.openDialer(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _storeActionButton(
                    icon: Icons.email_rounded,
                    label: "Email Us",
                    color: AppColors.primaryMaroon,
                    onTap: () => controller.openEmail(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Directions / Map Navigation
            GestureDetector(
              onTap: () => controller.openMap(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      color: Color(0xFF1565C0),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Directions & Map Navigation",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1565C0),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF1565C0),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _storeActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKicker(String kicker, {required bool isDark}) {
    return Text(
      kicker,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        color: AppColors.primaryGold,
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SINGLE STORE IMAGE BANNER COMPONENT (No Carousel)
// ════════════════════════════════════════════════════════════════════════════
class _SingleStoreImageBanner extends StatelessWidget {
  final AboutUsController ctrl;
  final Size size;
  const _SingleStoreImageBanner({required this.ctrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final height = size.height * 0.30;

    return Obx(() {
      final storeImage = ctrl.storeData.value?.imageUrl;

      return Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.maroonDeep,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: (storeImage != null && storeImage.isNotEmpty)
              ? Image.network(
                  storeImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _buildFallbackBanner(),
                )
              : _buildFallbackBanner(),
        ),
      );
    });
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: AppColors.maroonDeep,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond_rounded, size: 48, color: AppColors.primaryGold),
            const SizedBox(height: 8),
            Text(
              "Unnati Jewellers",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
