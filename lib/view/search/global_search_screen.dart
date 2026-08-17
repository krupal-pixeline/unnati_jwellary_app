import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../utils/custom_app_bar.dart';
import '../category/wishlist_controller.dart';
import '../product_details/product_details_screen.dart';
import 'search_product_controller.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SearchProductController _searchProductCtrl;



  @override
  void initState() {
    super.initState();
    _searchProductCtrl = Get.put(SearchProductController());

    // Sync query text changes to controller
    _searchController.addListener(() {
      _searchProductCtrl.searchQuery.value = _searchController.text;
    });

    // Check for initial search query passed from another screen
    final dynamic args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      _searchController.text = args;
      _searchProductCtrl.searchQuery.value = args;
      _searchProductCtrl.fetchSearchProducts(isAppend: false);
    }

    // Scroll listener for pagination on scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNextPage() {
    if (_searchProductCtrl.isLoading.value ||
        _searchProductCtrl.currentPage.value >= _searchProductCtrl.totalPages.value) {
      return;
    }
    _searchProductCtrl.currentPage.value++;
    _searchProductCtrl.fetchSearchProducts(isAppend: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: const CustomAppBar(
          title: "Search Products",
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchTextField(),
              Expanded(
                child: Obx(() {
                  final isQueryEmpty = _searchProductCtrl.searchQuery.value.trim().isEmpty;
                  final isListEmpty = _searchProductCtrl.productsList.isEmpty;
                  final isLoading = _searchProductCtrl.isLoading.value;

                  // 1. If no query, show prompt
                  if (isQueryEmpty) {
                    return _buildSearchPrompt();
                  }

                  // 2. If loading and nothing loaded yet, show spinner
                  if (isListEmpty && isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
                      ),
                    );
                  }

                  // 3. If query/gender active but no results found
                  if (isListEmpty) {
                    return _buildEmptyState();
                  }

                  // 4. Otherwise, show search results grid
                  return Stack(
                    children: [
                      _buildSearchResultsGrid(),
                      if (isLoading && !isListEmpty)
                        const Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Card(
                              elevation: 4,
                              shape: CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Search Input field
  Widget _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products (e.g. Bangle, Ring)…',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Obx(() => _searchProductCtrl.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }



  // Welcome prompt (Recent searches and Suggested categories removed completely)
  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.diamond_outlined,
            size: 64,
            color: AppColors.primaryGold.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'Find Your Sparkle',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMaroon,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Type above to search gold jewelry collections.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Grid list of search results
  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _searchProductCtrl.productsList.length,
      itemBuilder: (context, i) {
        final product = _searchProductCtrl.productsList[i];
        return _ProductSearchGridCard(product: product);
      },
    );
  }

  // Empty state layout
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundSecondary,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.textTertiary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: GoogleFonts.cinzel(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMaroon,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching with other terms',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PRODUCT SEARCH GRID CARD (Matches Premium UI)
// ─────────────────────────────────────────────
class _ProductSearchGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductSearchGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Jewellery Product';
    final price = product['price'] ?? '₹0';
    final weight = product['weight']?.toString() ?? '';
    final karat = product['karat']?.toString() ?? product['purity']?.toString() ?? '';
    final image = product['image'] ?? '';
    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        debugPrint('🔑 [ProductCard Clicked] Product ID: $id');
        Get.to(
          () => const ProductDetailsScreen(),
          arguments: product,
          preventDuplicates: false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: image.isNotEmpty && (image.startsWith('http') || image.startsWith('https'))
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.backgroundSecondary,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
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
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold,
                                  size: 32,
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            image.isNotEmpty ? image : 'assets/temp/demo_1.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0x25000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Floating Wishlist button overlay (Top-Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GetBuilder<WishlistController>(
                      builder: (wishlistCtrl) {
                        final isWishlisted = wishlistCtrl.isProductWishlisted(name, id: id);
                        return GestureDetector(
                          onTap: () => wishlistCtrl.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border_rounded,
                              size: 15,
                              color: isWishlisted ? Colors.red : AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Purity & Weight badges overlays (Bottom)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (karat.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              karat,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (weight.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              weight.contains('g') ? weight : '${weight} gm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Details panel below image
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.primaryMaroon,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
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
}
