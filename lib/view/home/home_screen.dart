import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../category/category_controller.dart';
import '../category/category_detail_screen.dart';
import '../main_layout/main_layout.dart';
import '../product_details/product_details_screen.dart';
import '../product_list/product_list_screen.dart';
import 'home_controller.dart';
import 'dart:math' as math;
import '../search/global_search_screen.dart';
import 'gold_rate_graph_screen.dart';
import 'live_rate_controller.dart';
import '../../model/home/banner_model.dart';
import '../../model/home/showcase_collection_model.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController homeSearchCtrl = TextEditingController();
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController c = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: RefreshIndicator(
        color: AppColors.primaryMaroon,
        onRefresh: () => c.refreshHomeData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHomeSearchBar(),

                  // 1. Banner Slider
                  _BannerSlider(controller: c),
                  const SizedBox(height: 20),

                  // 2. Gold Rates
                  _GoldRatesSection(controller: c),
                  const SizedBox(height: 24),

                  // 3. Categories (moved below live rates)
                  _CategoriesSection(controller: c),
                  const SizedBox(height: 8),

                  // Showcase Collections (Main Highlight)
                  _ShowcaseCollectionsSection(controller: c),
                  const SizedBox(height: 24),

                  // Shop by Gender
                  _GenderSection(controller: c),
                  const SizedBox(height: 24),

                  // Trending Collections
                  _TrendingCollectionsSection(controller: c),
                  const SizedBox(height: 24),

                  // 4. Featured Products
                  // 4. Featured Products
                  const SectionHeader(
                    title: 'Featured',
                    subtitle: 'Handpicked for you',
                  ),
                  _FeaturedProductsSection(controller: c),
                  const SizedBox(height: 24),

                  // 5. New Arrivals
                  const SectionHeader(
                    title: 'New Arrivals',
                    subtitle: 'Just landed',
                  ),
                  _NewArrivalsSection(controller: c),
                  const SizedBox(height: 24),

                  // 6. Best Sellers
                  const SectionHeader(
                    title: 'Best Sellers',
                    subtitle: 'Most loved pieces',
                  ),
                  _BestSellersSection(controller: c),
                  const SizedBox(height: 24),

                  // Lucky Draw Banner
                  _LuckyDrawBanner(controller: c),
                  const SizedBox(height: 20),

                  // Instagram Reels
                  _InstagramReelsSection(controller: c),
                  const SizedBox(height: 24),

                  // 9. Gold Scheme Comparison
                  const SectionHeader(
                    title: 'Gold Schemes',
                    subtitle: 'Save today, shine forever',
                  ),
                  const SizedBox(height: 12),
                  const _SchemeComparisonSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),    );
  }

  Widget _buildHomeSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.primaryGold,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: homeSearchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Get.to(() => const GlobalSearchScreen(), arguments: value.trim());
                    homeSearchCtrl.clear();
                  }
                },
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search jewelry, rings, necklaces...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final value = homeSearchCtrl.text;
                if (value.trim().isNotEmpty) {
                  Get.to(() => const GlobalSearchScreen(), arguments: value.trim());
                  homeSearchCtrl.clear();
                } else {
                  Get.to(() => const GlobalSearchScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryMaroon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _BannerSlider extends StatelessWidget {
  final HomeController controller;
  const _BannerSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Obx(() {
        if (controller.isBannersLoading.value) {
          return SizedBox(height: 220, child: const _BannerShimmer());
        }

        if (controller.bannersList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: controller.bannersList.length,
                  onPageChanged: (i) => controller.currentBannerIndex.value = i,
                  itemBuilder: (context, i) {
                    final banner = controller.bannersList[i];
                    return _BannerItem(banner: banner);
                  },
                ),
                // Premium Floating Dot indicators (Bottom-Right aligned to prevent text overlap)
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      controller.bannersList.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: controller.currentBannerIndex.value == i
                            ? 18
                            : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.currentBannerIndex.value == i
                              ? AppColors.champagneGold
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final BannerDataModel banner;
  const _BannerItem({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (banner.linkType == 'product' && banner.linkTarget.isNotEmpty) {
          Get.to(
            () => ProductDetailsScreen(),
            arguments: {
              'id': banner.linkTarget,
              'name': banner.title,
              'image': banner.imageUrl,
            },
          );
        } else if (banner.linkType == 'category' &&
            banner.linkTarget.isNotEmpty) {
          final categoryController = Get.put(CategoryController());
          final matchingCategory = categoryController.filteredCategories
              .firstWhereOrNull((c) => c.id == banner.linkTarget);
          if (matchingCategory != null) {
            Get.to(
              () => const CategoryDetailScreen(),
              arguments: matchingCategory,
            );
          } else {
            Get.find<MainLayoutController>().changeTab(1);
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Network Image
          Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black12,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.champagneGold,
                      ),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.maroonDeep,
                    AppColors.primaryMaroon,
                    AppColors.maroonLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),
          ),
          // Dark luxury bottom gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 20,
              top: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    banner.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    banner.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      height: 1.4,
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
}

class _BannerShimmer extends StatefulWidget {
  const _BannerShimmer();

  @override
  State<_BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<_BannerShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnim.value.clamp(0.0, 1.0),
                (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}


class _GoldRatesSection extends StatelessWidget {
  final HomeController controller;
  const _GoldRatesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Ensure LiveRateController is running (shared permanent singleton)
    final lc = Get.put(LiveRateController(), permanent: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.to(() => const GoldRateGraphScreen()),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldSoft, AppColors.champagneMedium],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final gold22k = lc.gold22kPrice;
              final silver999 = lc.silver999Price;
              final hasData = gold22k > 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row for Title and Status
                  Row(
                    children: [
                      const Text(
                        'Live Rates',
                        style: TextStyle(
                          color: AppColors.primaryMaroon,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pulse dot
                      if (lc.isConnected.value)
                        _HomePulseDot()
                      else
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                      const Spacer(),
                      Text(
                        lc.isConnected.value
                            ? 'Updated ${lc.lastUpdatedStr.value}'
                            : 'Connecting…',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Row of values below the title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gold 22K (10G)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasData ? lc.formatPrice(gold22k * 10) : '—',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Gold 22K (10G)',
                              style: TextStyle(
                                color: AppColors.goldDeep,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical divider line
                      Container(
                        width: 1.5,
                        height: 32,
                        color: AppColors.champagneGold.withValues(alpha: 0.35),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      // Silver 999 (1KG)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasData ? lc.formatPrice(silver999) : '—',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Silver 999 (1KG)',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.primaryMaroon,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomePulseDot extends StatefulWidget {
  @override
  State<_HomePulseDot> createState() => _HomePulseDotState();
}

class _HomePulseDotState extends State<_HomePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4CAF50).withValues(alpha: _anim.value),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: _anim.value * 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}


//  CATEGORIES
class _CategoriesSection extends StatelessWidget {
  final HomeController controller;
  const _CategoriesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Discover our collections',
        ),
        SizedBox(
          height: 112,
          child: Obx(() {
            if (controller.isCategoriesLoading.value) {
              return const _CategoryShimmer();
            }

            if (controller.categoriesList.isEmpty) {
              return const Center(
                child: Text(
                  'No categories available',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.categoriesList.length,
              itemBuilder: (context, i) {
                final cat = controller.categoriesList[i];
                return GestureDetector(
                  onTap: () {
                    final categoryController = Get.put(CategoryController());
                    final matchingCategory = categoryController
                        .filteredCategories
                        .firstWhereOrNull(
                          (c) =>
                              c.name.toLowerCase() ==
                              cat.categoryName.toLowerCase(),
                        );
                    if (matchingCategory != null) {
                      Get.to(
                        () => CategoryDetailScreen(),
                        arguments: matchingCategory,
                      );
                    } else {
                      Get.find<MainLayoutController>().changeTab(1);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        // Double-ringed Gold Medallion Frame
                        Container(
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.champagneGold,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.champagneGold.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.champagneGold.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                              color: const Color(0xFFFDFDFD),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                cat.image,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryMaroon,
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: AppColors.primaryMaroon,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.categoryName,
                          style: GoogleFonts.cinzel(
                            color: AppColors.primaryMaroon,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CategoryShimmer extends StatefulWidget {
  const _CategoryShimmer();

  @override
  State<_CategoryShimmer> createState() => _CategoryShimmerState();
}

class _CategoryShimmerState extends State<_CategoryShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 5,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: shimmerGradient,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: shimmerGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductShimmer extends StatefulWidget {
  final double height;
  final double width;
  const _ProductShimmer({required this.height, required this.width});

  @override
  State<_ProductShimmer> createState() => _ProductShimmerState();
}

class _ProductShimmerState extends State<_ProductShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 3,
          itemBuilder: (context, i) {
            return Container(
              width: widget.width,
              height: widget.height,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: shimmerGradient,
              ),
            );
          },
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vertical Accent Line with maroon and gold gradient
          Container(
            width: 3.5,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryMaroon, AppColors.champagneGold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          /// Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryMaroon,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedProductsSection extends StatelessWidget {
  final HomeController controller;
  const _FeaturedProductsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Obx(() {
        if (controller.isFeaturedLoading.value) {
          return const _ProductShimmer(height: 260, width: 175);
        }

        if (controller.featuredList.isEmpty) {
          return const Center(
            child: Text(
              'No featured products available',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.featuredList.length,
          itemBuilder: (context, i) {
            final p = controller.featuredList[i].toUiMap();
            return _ProductCard(
              product: p,
              index: i,
              controller: controller,
              width: 175,
            );
          },
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;
  final HomeController controller;
  final double width;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.controller,
    this.width = 175,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint(
          '🔑 [ProductCard Clicked] Product ID: ${product['id'] ?? product['_id']}',
        );
        Get.to(
          () => const ProductDetailsScreen(),
          arguments: product,
          preventDuplicates: false,
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.45),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area - 80%
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child: product['image'].toString().startsWith('http')
                    ? Image.network(
                        product['image'] as String,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryMaroon,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.paleGold, AppColors.warmCream],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('💍', style: TextStyle(fontSize: 42)),
                          ),
                        ),
                      )
                    : Image.asset(
                        product['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.paleGold, AppColors.warmCream],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('💍', style: TextStyle(fontSize: 42)),
                          ),
                        ),
                      ),
              ),
            ),
            // Info area - 20%
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Text(
                  product['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NEW ARRIVALS
// ─────────────────────────────────────────────────────────────────────────────
class _ArchedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;
  final HomeController controller;
  final double width;

  const _ArchedProductCard({
    required this.product,
    required this.index,
    required this.controller,
    this.width = 155,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint(
          '🔑 [ProductCard Clicked] Product ID: ${product['id'] ?? product['_id']}',
        );
        Get.to(
          () => const ProductDetailsScreen(),
          arguments: product,
          preventDuplicates: false,
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(65),
            topRight: Radius.circular(65),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.4),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area - 80% with Palace Arch shape
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(63),
                  topRight: Radius.circular(63),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                child: product['image'].toString().startsWith('http')
                    ? Image.network(
                        product['image'] as String,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryMaroon,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.paleGold, AppColors.warmCream],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('💍', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      )
                    : Image.asset(
                        product['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.paleGold, AppColors.warmCream],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('💍', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      ),
              ),
            ),
            // Info area - 20%
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Text(
                  product['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewArrivalsSection extends StatelessWidget {
  final HomeController controller;
  const _NewArrivalsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      child: Obx(() {
        if (controller.isNewArrivalsLoading.value) {
          return const _ProductShimmer(height: 245, width: 155);
        }

        if (controller.newArrivalsList.isEmpty) {
          return const Center(
            child: Text(
              'No new arrivals available',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.newArrivalsList.length,
          itemBuilder: (context, i) {
            final product = controller.newArrivalsList[i].toUiMap();
            return _ArchedProductCard(
              product: product,
              index: i,
              controller: controller,
              width: 155,
            );
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BEST SELLERS
// ─────────────────────────────────────────────────────────────────────────────
class _BestSellersSection extends StatelessWidget {
  final HomeController controller;
  const _BestSellersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(() {
        if (controller.isBestSellersLoading.value) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.72,
            children: List.generate(4, (i) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
              );
            }),
          );
        }

        if (controller.bestSellersList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No best sellers available',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.bestSellersList.length.clamp(0, 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) {
            final product = controller.bestSellersList[i].toUiMap();
            return _ProductCard(
              product: product,
              index: i,
              controller: controller,
            );
          },
        );
      }),
    );
  }
}

class _LuckyDrawBanner extends StatelessWidget {
  final HomeController controller;
  const _LuckyDrawBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Get.find<MainLayoutController>().changeTab(3);
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF4A1420), Color(0xFF6B1D2E), Color(0xFF8B3549)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMaroon.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -20,
                top: -20,
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
                right: 40,
                bottom: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagneGold.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text('🎰', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Text(
                                'LUCKY DRAW',
                                style: TextStyle(
                                  color: AppColors.champagneGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          const Text(
                            'Win a Gold Coin\nWorth ₹25,000!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CTA
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.champagneGold,
                                AppColors.warmGold,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'ENTER',
                                style: TextStyle(
                                  color: AppColors.maroonDeep,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'NOW',
                                style: TextStyle(
                                  color: AppColors.maroonDeep,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '1 Entry Free!',
                          style: TextStyle(color: Colors.white60, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchemeComparisonSection extends StatefulWidget {
  const _SchemeComparisonSection();

  @override
  State<_SchemeComparisonSection> createState() =>
      _SchemeComparisonSectionState();
}

class _SchemeComparisonSectionState extends State<_SchemeComparisonSection> {
  int _selectedTab = 0; // 0 = Gold Based, 1 = Amount Based

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? const Color(0xFF33220B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _selectedTab == 0
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF33220B,
                                ).withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Gold Based',
                      style: GoogleFonts.poppins(
                        color: _selectedTab == 0
                            ? const Color(0xFFD4AF37)
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? const Color(0xFF5A0E2D)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _selectedTab == 1
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF5A0E2D,
                                ).withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Amount Based',
                      style: GoogleFonts.poppins(
                        color: _selectedTab == 1
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Card Content Area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedCrossFade(
            firstChild: _buildGoldSchemeCard(context),
            secondChild: _buildAmountSchemeCard(context),
            crossFadeState: _selectedTab == 0
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  Widget _buildGoldSchemeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<MainLayoutController>().changeTab(2);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFDF5), Color(0xFFFBF4E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gold Based Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5B800).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          size: 10,
                          color: Color(0xFF9E7C00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GOLD BASED',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF9E7C00),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Diamond Icon & Title
                  Row(
                    children: [
                      const Icon(
                        Icons.diamond_outlined,
                        size: 24,
                        color: AppColors.primaryMaroon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gold Based Scheme',
                          style: GoogleFonts.cinzel(
                            color: AppColors.primaryMaroon,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Divider(
                    color: AppColors.champagneGold.withValues(alpha: 0.25),
                    height: 12,
                    thickness: 1,
                  ),
                  const SizedBox(height: 4),

                  // Bullets
                  _buildBulletPoint(
                    icon: Icons.diamond_outlined,
                    iconColor: const Color(0xFFB8860B),
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Accumulates gold ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: "at today's rate every month"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFFB8860B),
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Benefit from gold appreciation ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: 'over time'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.card_giftcard_rounded,
                    iconColor: const Color(0xFFB8860B),
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Redeem against jewellery ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: 'at scheme maturity'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFB8860B),
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(text: 'Cancel: refund minus '),
                      const TextSpan(
                        text: "20% of one month's installment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF5EAD4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 12,
                    color: Color(0xFF8B6B23),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'BIS Hallmarked · 22K / 18K Gold available',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8B6B23),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSchemeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<MainLayoutController>().changeTab(2);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7F9), Color(0xFFF7EBEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.primaryMaroon.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Based Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE9EF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryMaroon.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.vpn_key_outlined,
                          size: 10,
                          color: AppColors.primaryMaroon,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AMOUNT BASED',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryMaroon,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Keys Icon & Title
                  Row(
                    children: [
                      const Icon(
                        Icons.key_outlined,
                        size: 24,
                        color: AppColors.primaryMaroon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Amount Based Scheme',
                          style: GoogleFonts.cinzel(
                            color: AppColors.primaryMaroon,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),
                  Divider(
                    color: AppColors.primaryMaroon.withValues(alpha: 0.15),
                    height: 12,
                    thickness: 1,
                  ),
                  const SizedBox(height: 4),

                  // Bullets
                  _buildBulletPoint(
                    icon: Icons.key_outlined,
                    iconColor: AppColors.primaryMaroon,
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Fixed savings ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(
                        text: '— installments retained as currency',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.calendar_month_outlined,
                    iconColor: AppColors.primaryMaroon,
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Predictable ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: '— no market dependency'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.card_giftcard_rounded,
                    iconColor: AppColors.primaryMaroon,
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(
                        text: 'Full amount redeemable ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: 'against jewellery at maturity'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildBulletPoint(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.primaryMaroon,
                    textColor: AppColors.textPrimary,
                    spans: [
                      const TextSpan(text: 'Cancel: '),
                      const TextSpan(
                        text: '100% refund ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      const TextSpan(text: 'of all deposited installments'),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFEEDAE1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.primaryMaroon,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Secure · Transparent Ledger · Digital Receipts',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryMaroon,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({
    required IconData icon,
    required Color iconColor,
    required List<TextSpan> spans,
    Color textColor = AppColors.textPrimary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: textColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
              children: spans,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstagramReelsSection extends StatelessWidget {
  final HomeController controller;
  const _InstagramReelsSection({required this.controller});

  Future<void> _launchInstagram(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (_) {
      Get.snackbar(
        'Instagram Redirect',
        'Could not open Instagram. Please check if the app is installed.',
        backgroundColor: AppColors.backgroundSecondary,
        colorText: AppColors.primaryMaroon,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Unnati On Instagram',
          subtitle: 'Watch our collections in action',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Obx(() {
            if (controller.isStylingLoading.value) {
              return const _ReelsShimmer();
            }

            if (controller.stylingReelsList.isEmpty) {
              return const Center(
                child: Text(
                  'No Instagram reels available',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.stylingReelsList.length,
              itemBuilder: (context, index) {
                final reel = controller.stylingReelsList[index];
                return GestureDetector(
                  onTap: () => _launchInstagram(reel.videoUrl),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Network Thumbnail Image
                          Image.network(
                            reel.thumbnailUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryMaroon,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.warmCream,
                                    AppColors.paleGold,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          // Dark overlay gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                          // Play button in the center
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.25),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          // Instagram icon watermark on top left
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _ReelsShimmer extends StatefulWidget {
  const _ReelsShimmer();

  @override
  State<_ReelsShimmer> createState() => _ReelsShimmerState();
}

class _ReelsShimmerState extends State<_ReelsShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, i) {
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: shimmerGradient,
              ),
            );
          },
        );
      },
    );
  }
}

class _TrendingCollectionsSection extends StatelessWidget {
  final HomeController controller;
  const _TrendingCollectionsSection({required this.controller});

  static const List<String> fallbackImages = [
    'assets/temp/demo_1.jpeg',
    'assets/temp/demo_3.jpeg',
    'assets/temp/demo_2.jpeg',
    'assets/temp/demo_4.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Trending Collections',
          subtitle: 'Handcrafted signature lines',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: Obx(() {
            if (controller.isTrendingLoading.value) {
              return const _TrendingShimmer();
            }

            if (controller.trendingList.isEmpty) {
              return const Center(
                child: Text(
                  'No trending collections available',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.trendingList.length,
              itemBuilder: (context, index) {
                final col = controller.trendingList[index];
                final String fallbackImage =
                    fallbackImages[index % fallbackImages.length];

                return GestureDetector(
                  onTap: () {
                    // Open ProductListScreen and fetch products dynamically by collection ID
                    Get.to(
                      () => ProductListScreen(
                        title: col.title,
                        extraParams: {
                          'collection': col.productId,
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 14, bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Image.asset(fallbackImage, fit: BoxFit.cover),
                          // Dark premium gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                          ),
                          // Text contents
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  col.title,
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  col.subtitle,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      'Explore Collection',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.champagneGold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.champagneGold,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TrendingShimmer extends StatefulWidget {
  const _TrendingShimmer();

  @override
  State<_TrendingShimmer> createState() => _TrendingShimmerState();
}

class _TrendingShimmerState extends State<_TrendingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, i) {
            return Container(
              width: 240,
              margin: const EdgeInsets.only(right: 14, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: shimmerGradient,
              ),
            );
          },
        );
      },
    );
  }
}

class _GenderSection extends StatelessWidget {
  final HomeController controller;
  const _GenderSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final genders = [
      {'key': 'women', 'title': 'Women', 'icon': 'assets/icons/women.png'},
      {'key': 'men', 'title': 'Men', 'icon': 'assets/icons/men.png'},
      {'key': 'kids', 'title': 'Kids', 'icon': 'assets/icons/kids.png'},
      {'key': 'unisex', 'title': 'Unisex', 'icon': 'assets/icons/unisex.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Shop by Gender',
          subtitle: 'Crafted for every style',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: genders.map((g) {
              return GestureDetector(
                onTap: () {
                  final allProducts = <String, Map<String, dynamic>>{};
                  for (var p in controller.featuredList) { allProducts[p.id] = p.toUiMap(); }
                  for (var p in controller.newArrivalsList) { allProducts[p.id] = p.toUiMap(); }
                  for (var p in controller.bestSellersList) { allProducts[p.id] = p.toUiMap(); }

                  final filtered = allProducts.values.where((p) {
                    final prodGender = (p['gender']?.toString() ?? '').toLowerCase();
                    if (g['key'] == 'unisex') {
                      return prodGender == 'unisex';
                    } else if (g['key'] == 'kids') {
                      return prodGender == 'kids' || prodGender == 'kid';
                    } else if (g['key'] == 'men') {
                      return prodGender == 'men' || prodGender == 'unisex';
                    } else {
                      return prodGender == 'women' || prodGender == 'unisex';
                    }
                  }).toList();
                  Get.to(
                    () => ProductListScreen(
                      title: "${g['title']}'s Collection",
                      initialGender: g['key'],
                    ),
                  );
                },
                child: Container(
                  width: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.champagneGold.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full-bleed Image (no margins/padding)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: SizedBox(
                          height: 75,
                          child: Image.asset(
                            g['icon']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryMaroon.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppColors.primaryMaroon,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padded Text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        child: Text(
                          g['title']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: AppColors.primaryMaroon,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHOWCASE COLLECTIONS (MAIN HIGHLIGHT)
// ─────────────────────────────────────────────────────────────────────────────
class _ShowcaseCollectionsSection extends StatelessWidget {
  final HomeController controller;
  const _ShowcaseCollectionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Signature Showcase',
          subtitle: 'Uniquely crafted heritage collections',
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isShowcaseLoading.value) {
            return const _ShowcaseShimmer();
          }

          if (controller.showcaseList.isEmpty) {
            return const SizedBox.shrink();
          }

          final items = controller.showcaseList.toList();
          final List<Widget> children = [];

          for (int i = 0; i < items.length; ) {
            if (i == 0 || i == 3) {
              children.add(_ShowcaseCardHorizontal(
                collection: items[i],
                imageLeft: i == 0,
                index: i,
              ));
              i++;
            } else {
              if (i + 1 < items.length) {
                children.add(Row(
                  children: [
                    Expanded(child: _ShowcaseCardVertical(collection: items[i], index: i)),
                    const SizedBox(width: 14),
                    Expanded(child: _ShowcaseCardVertical(collection: items[i + 1], index: i + 1)),
                  ],
                ));
                i += 2;
              } else {
                children.add(_ShowcaseCardHorizontal(
                  collection: items[i],
                  imageLeft: true,
                  index: i,
                ));
                i++;
              }
            }
            if (i < items.length) {
              children.add(const SizedBox(height: 14));
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: children,
            ),
          );
        }),
      ],
    );
  }
}

// Private helper to get luxurious soft pastel gradients for catalog cards
List<LinearGradient> _getShowcaseGradients() {
  return const [
    LinearGradient(
      colors: [Color(0xFFEDF8F6), Color(0xFFD2EDE8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFFF2F4), Color(0xFFFAD7DD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFFF8EC), Color(0xFFF5E4C3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFF8F3FA), Color(0xFFE9DCF0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFF1F5F8), Color(0xFFD7E2EC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFFF5F0), Color(0xFFFADCD0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}

class _ShowcaseCardHorizontal extends StatelessWidget {
  final ShowcaseCollection collection;
  final bool imageLeft;
  final int index;
  const _ShowcaseCardHorizontal({
    required this.collection,
    this.imageLeft = true,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = _getShowcaseGradients();
    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () {
        // Open ProductListScreen and fetch products dynamically by collection ID
        Get.to(
          () => ProductListScreen(
            title: collection.title,
            extraParams: {
              'collection': collection.id,
            },
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 0.8,
          ),
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
          child: CustomPaint(
            painter: const MandalaCardPainter(
              color: Color(0x10BF9A55), // very subtle mandala watermark
            ),
            child: Row(
              children: [
                if (imageLeft) _buildImage(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "UNNATI HERITAGE",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGold,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collection.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: AppColors.primaryMaroon,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collection.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 8.5,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Explore text link
                        Text(
                          "EXPLORE COLLECTION",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryMaroon,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!imageLeft) _buildImage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final BorderRadius borderRadius = imageLeft
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Container(
      width: 130,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border(
          right: imageLeft
              ? const BorderSide(color: AppColors.champagneGold, width: 0.8)
              : BorderSide.none,
          left: !imageLeft
              ? const BorderSide(color: AppColors.champagneGold, width: 0.8)
              : BorderSide.none,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: collection.backgroundImage.isNotEmpty
            ? Image.network(
                collection.backgroundImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryMaroon,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white,
                  child: const Center(
                    child: Icon(
                      Icons.diamond_outlined,
                      color: AppColors.champagneGold,
                      size: 24,
                    ),
                  ),
                ),
              )
            : Container(
                color: Colors.white,
                child: const Center(
                  child: Icon(
                    Icons.diamond_outlined,
                    color: AppColors.champagneGold,
                    size: 24,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ShowcaseCardVertical extends StatelessWidget {
  final ShowcaseCollection collection;
  final int index;
  const _ShowcaseCardVertical({required this.collection, required this.index});

  @override
  Widget build(BuildContext context) {
    final gradients = _getShowcaseGradients();
    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () {
        // Open ProductListScreen and fetch products dynamically by collection ID
        Get.to(
          () => ProductListScreen(
            title: collection.title,
            extraParams: {
              'collection': collection.id,
            },
          ),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 0.8,
          ),
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
          child: CustomPaint(
            painter: const MandalaCardPainter(
              color: Color(0x15BF9A55), // subtle mandala background
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Center image of the collection
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.champagneGold.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: collection.backgroundImage.isNotEmpty
                          ? Image.network(
                              collection.backgroundImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.white,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryMaroon,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white,
                                child: const Center(
                                  child: Icon(
                                    Icons.diamond_outlined,
                                    color: AppColors.champagneGold,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: const Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold,
                                  size: 20,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: Text(
                    collection.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: AppColors.primaryMaroon,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowcaseShimmer extends StatefulWidget {
  const _ShowcaseShimmer();

  @override
  State<_ShowcaseShimmer> createState() => _ShowcaseShimmerState();
}

class _ShowcaseShimmerState extends State<_ShowcaseShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: shimmerGradient,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: shimmerGradient,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MANDALA PAINTERS (DECORATIVE ARTWORK)
// ─────────────────────────────────────────────────────────────────────────────
class MandalaDividerPainter extends CustomPainter {
  final Color color;
  const MandalaDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Draw center diamond
    final path = Path()
      ..moveTo(cx, cy - 6)
      ..lineTo(cx + 6, cy)
      ..lineTo(cx, cy + 6)
      ..lineTo(cx - 6, cy)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw elegant swirls
    final leftSwirl = Path()
      ..moveTo(cx - 10, cy)
      ..cubicTo(cx - 20, cy - 8, cx - 25, cy + 8, cx - 35, cy - 2)
      ..cubicTo(cx - 40, cy - 8, cx - 45, cy, cx - 55, cy);
    canvas.drawPath(leftSwirl, paint);

    final rightSwirl = Path()
      ..moveTo(cx + 10, cy)
      ..cubicTo(cx + 20, cy - 8, cx + 25, cy + 8, cx + 35, cy - 2)
      ..cubicTo(cx + 40, cy - 8, cx + 45, cy, cx + 55, cy);
    canvas.drawPath(rightSwirl, paint);

    // Draw horizontal lines extending to the edges
    canvas.drawLine(Offset(0, cy), Offset(cx - 60, cy), paint);
    canvas.drawLine(Offset(cx + 60, cy), Offset(size.width, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MandalaCardPainter extends CustomPainter {
  final Color color;
  const MandalaCardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // 1. Draw delicate concentric mandala rings in the center background
    final double baseRadius = w * 0.22;
    canvas.drawCircle(Offset(cx, cy), baseRadius, paint);
    canvas.drawCircle(Offset(cx, cy), baseRadius * 0.7, paint);
    canvas.drawCircle(Offset(cx, cy), baseRadius * 0.4, paint);

    // 2. Draw 12-fold symmetry petals
    final int segments = 12;
    for (int i = 0; i < segments; i++) {
      final double angle = (2 * math.pi * i) / segments;
      final double px = cx + baseRadius * 0.85 * math.cos(angle);
      final double py = cy + baseRadius * 0.85 * math.sin(angle);
      canvas.drawCircle(Offset(px, py), baseRadius * 0.25, paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
