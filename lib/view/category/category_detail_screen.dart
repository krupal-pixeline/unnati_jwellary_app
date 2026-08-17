import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_urls.dart';
import '../../services/base_api_services.dart';
import '../../services/home_api_services.dart';
import '../../model/home/subcategory_model.dart';
import '../product_details/product_details_screen.dart';
import 'jewelry_category_model.dart';
import 'wishlist_controller.dart';
import 'filter_screen.dart';
import 'category_controller.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final RxString selectedSubCategoryId = 'all'.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Featured'.obs;
  final RxBool isSearchFocused = false.obs;

  // Selected material filters
  final RxList<String> selectedMaterials = <String>[].obs;

  // Price Filters
  double? minPriceFilter;
  double? maxPriceFilter;

  // New filters matching Apply Filter layout
  final RxString selectedGender = 'All'.obs;
  double minWeightFilter = 1.0;
  double maxWeightFilter = 2000.0;
  final RxList<String> selectedHighlights = <String>[].obs;

  // Sort options
  final List<String> sortOptions = const [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
  ];

  final Map<String, String> sortApiKeys = const {
    'Featured': 'featured',
    'Price: Low to High': 'price-asc',
    'Price: High to Low': 'price-desc',
    'Newest': 'newest',
  };

  // API State Observables
  final RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalProducts = 0.obs;

  final RxList<SubCategoryDataModel> apiSubCategories = <SubCategoryDataModel>[].obs;
  final RxBool isLoadingSubCategories = false.obs;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) {
      _fetchProductsFromApi(isAppend: false);
    }, time: const Duration(milliseconds: 500));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadNextPage();
      }
    });

    final String categoryId;
    // Set initial filters from map arguments if present
    if (Get.arguments is Map) {
      final map = Get.arguments as Map<String, dynamic>;
      selectedSubCategoryId.value = map['selectedSubId'] as String? ?? 'all';
      minPriceFilter = map['minPrice'] as double?;
      maxPriceFilter = map['maxPrice'] as double?;
      
      final cat = map['category'] as JewelryCategory;
      categoryId = cat.id;
    } else {
      final cat = Get.arguments as JewelryCategory;
      categoryId = cat.id;
    }

    _loadSubCategories(categoryId);
    _fetchProductsFromApi(isAppend: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNextPage() {
    if (isLoadingProducts.value || currentPage.value >= totalPages.value) {
      return;
    }
    currentPage.value++;
    _fetchProductsFromApi(isAppend: true);
  }

  Future<void> _loadSubCategories(String categoryId) async {
    try {
      isLoadingSubCategories.value = true;
      final categoryController = Get.find<CategoryController>();
      if (categoryController.subCategoriesMap.containsKey(categoryId)) {
        apiSubCategories.assignAll(categoryController.subCategoriesMap[categoryId] ?? []);
        return;
      }
      final response = await HomeApiService().getSubCategories(categoryId: categoryId);
      apiSubCategories.assignAll(response.data);
      categoryController.subCategoriesMap[categoryId] = response.data;
    } catch (e) {
      debugPrint("❌ [CategoryDetailScreen] Error fetching subcategories: $e");
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  Future<void> _fetchProductsFromApi({bool isAppend = false}) async {
    try {
      isLoadingProducts.value = true;

      if (!isAppend) {
        currentPage.value = 1;
      }

      final JewelryCategory category;
      if (Get.arguments is Map) {
        category = (Get.arguments as Map<String, dynamic>)['category'] as JewelryCategory;
      } else {
        category = Get.arguments as JewelryCategory;
      }

      final Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'limit': 20,
        'category': category.id,
      };

      if (selectedSubCategoryId.value != 'all') {
        queryParams['subCategory'] = selectedSubCategoryId.value;
      }

      if (searchQuery.value.trim().isNotEmpty) {
        queryParams['search'] = searchQuery.value.trim();
      }

      if (minPriceFilter != null) {
        queryParams['minPrice'] = minPriceFilter!.toInt();
      }
      if (maxPriceFilter != null) {
        queryParams['maxPrice'] = maxPriceFilter!.toInt();
      }

      if (selectedMaterials.isNotEmpty) {
        queryParams['metalType'] = selectedMaterials.map((m) => m.toLowerCase()).join(',');
      }

      if (selectedGender.value != 'All') {
        queryParams['gender'] = selectedGender.value;
      }

      // Only send weight params when user has specifically changed them
      if (minWeightFilter > 1.0) {
        queryParams['minWeight'] = minWeightFilter.toInt();
      }
      if (maxWeightFilter < 2000.0) {
        queryParams['maxWeight'] = maxWeightFilter.toInt();
      }

      final sortKey = sortApiKeys[selectedSort.value] ?? 'featured';
      queryParams['sortBy'] = sortKey;

      final BaseApiService baseApi = BaseApiService();
      final response = await baseApi.getRequest(
        url: AppUrls.products,
        queryParams: queryParams,
        apiName: 'CATEGORY_DETAIL_PRODUCTS',
      );

      if (response['success'] == true) {
        final List list = response['data'] as List? ?? [];
        final List<Map<String, dynamic>> parsedProducts = list.map((item) {
          final id = item['_id']?.toString() ?? '';
          final name = item['productName']?.toString() ?? 'Gold Jewelry';
          final desc = item['description']?.toString() ?? '';
          final weight = '${item['weight'] ?? 0} gm';
          final karat = item['purity']?.toString() ?? '';
          final calculatedPrice = item['calculatedPrice']?.toString() ?? '0';
          
          final imagesList = item['images'] as List? ?? [];
          final image = imagesList.isNotEmpty ? imagesList[0].toString() : '';

          return {
            'id': id,
            '_id': id,
            'name': name,
            'description': desc,
            'price': '₹$calculatedPrice',
            'weight': weight,
            'karat': karat,
            'purity': karat,
            'metal': item['metalType']?.toString() ?? 'Gold',
            'image': image,
            'badge': (item['tags'] as List? ?? []).isNotEmpty 
                ? (item['tags'] as List)[0].toString().toUpperCase() 
                : '',
            'gender': item['gender']?.toString() ?? 'Women',
          };
        }).toList();

        if (isAppend) {
          apiProducts.addAll(parsedProducts);
        } else {
          apiProducts.assignAll(parsedProducts);
        }

        final pagination = response['pagination'] as Map? ?? {};
        totalPages.value = pagination['totalPages'] as int? ?? 1;
        totalProducts.value = pagination['total'] as int? ?? 0;
      } else {
        if (!isAppend) {
          apiProducts.clear();
          totalPages.value = 1;
          totalProducts.value = 0;
        }
      }
    } catch (e) {
      debugPrint("❌ [CategoryDetailScreen] Error fetching products: $e");
      if (!isAppend) {
        apiProducts.clear();
        totalPages.value = 1;
        totalProducts.value = 0;
      }
    } finally {
      isLoadingProducts.value = false;
    }
  }

  List<Map<String, dynamic>> _getFilteredProducts(List<Map<String, dynamic>> allProducts) {
    return allProducts;
  }

  Future<void> _onPullToRefresh() async {
    setState(() {
      minPriceFilter = null;
      maxPriceFilter = null;
      selectedMaterials.clear();
      selectedHighlights.clear();
      selectedGender.value = 'All';
      minWeightFilter = 1.0;
      maxWeightFilter = 2000.0;
    });
    currentPage.value = 1;
    await _fetchProductsFromApi(isAppend: false);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the passed category from arguments
    final JewelryCategory category;
    if (Get.arguments is Map) {
      category = (Get.arguments as Map<String, dynamic>)['category'] as JewelryCategory;
    } else {
      category = Get.arguments as JewelryCategory;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: RefreshIndicator(
          onRefresh: _onPullToRefresh,
          color: AppColors.primaryMaroon,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // ── CUSTOM HEADER APP BAR ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.maroonPrimary,
              iconTheme: const IconThemeData(color: AppColors.white),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                title: Text(
                  category.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    category.imagePath.startsWith('http')
                        ? Image.network(
                            category.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.maroonDark, AppColors.maroonPrimary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            category.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.maroonDark, AppColors.maroonPrimary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                    // Dark linear gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Subtitle text inside background
                    Positioned(
                      bottom: 44,
                      left: 56,
                      right: 16,
                      child: Text(
                        category.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.champagneGold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SEARCH BAR
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),

            // ACTION BUTTONS ROW (SORT & FILTER)
            SliverToBoxAdapter(
              child: _buildActionButtonsRow(),
            ),

            // SUB-CATEGORIES SECTION
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      'Sub Collections',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                  _buildSubCategoryChips(),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // PRODUCTS SECTION
            Obx(() {
              if (isLoadingProducts.value && currentPage.value == 1) {
                return const SliverToBoxAdapter(
                  child: _ProductGridShimmer(itemCount: 6),
                );
              }

              final displayedProducts = _getFilteredProducts(apiProducts);

              if (displayedProducts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No products available matching your criteria.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = displayedProducts[index];
                      return _ProductGridCard(product: product);
                    },
                    childCount: displayedProducts.length,
                  ),
                ),
              );
            }),

            // Infinite Scroll Loading Indicator at bottom
            SliverToBoxAdapter(
              child: Obx(() {
                if (isLoadingProducts.value && currentPage.value > 1) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: _ProductGridShimmer(itemCount: 2),
                  );
                }
                return const SizedBox(height: 80);
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Obx(() => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSearchFocused.value
                ? AppColors.champagneGold
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: isSearchFocused.value
                    ? AppColors.champagneGold
                    : AppColors.textTertiary,
                size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) =>
                    isSearchFocused.value = hasFocus,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search products in this collection…',
                    hintStyle: TextStyle(
                        color: AppColors.textTertiary, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Obx(() => searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () => searchController.clear(),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ),
                  )
                : const SizedBox(width: 14)),
          ],
        ),
      )),
    );
  }

  // ── Action Buttons Row (Sort / Filter) ─────────────────────────────────────
  Widget _buildActionButtonsRow() {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Sort button
          GestureDetector(
            onTap: _showSortBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: AppColors.primaryMaroon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sort',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          // Filter button
          Obx(() {
            final active = _isAnyFilterActive();
            return GestureDetector(
              onTap: _showFilterSheet,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryMaroon.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primaryMaroon : Colors.grey.shade200,
                    width: active ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: active ? AppColors.primaryMaroon : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Filter',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.primaryMaroon : AppColors.textPrimary,
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubCategoryChips() {
    return SizedBox(
      height: 115,
      child: Obx(() {
        if (isLoadingSubCategories.value) {
          return const _SubCategoryShimmer();
        }

        final activeId = selectedSubCategoryId.value;
        final JewelryCategory category;
        if (Get.arguments is Map) {
          category = (Get.arguments as Map<String, dynamic>)['category'] as JewelryCategory;
        } else {
          category = Get.arguments as JewelryCategory;
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: apiSubCategories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final String id = isAll ? 'all' : apiSubCategories[index - 1].id;
            final String label = isAll ? 'View All' : apiSubCategories[index - 1].subCategoryName;
            final String imageUrl = isAll ? category.imagePath : apiSubCategories[index - 1].image;
            final isSelected = activeId == id;

            return GestureDetector(
              onTap: () {
                selectedSubCategoryId.value = id;
                // Reset all filters when subcollection is switched
                minPriceFilter = null;
                maxPriceFilter = null;
                selectedMaterials.clear();
                selectedGender.value = 'All';
                minWeightFilter = 1.0;
                maxWeightFilter = 2000.0;
                currentPage.value = 1;
                _fetchProductsFromApi();
              },
              child: Container(
                width: 76,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    // Concentric Circular Image
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primaryMaroon 
                              : AppColors.champagneGold.withValues(alpha: 0.5),
                          width: isSelected ? 2.0 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryMaroon.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.champagneGold 
                                : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey.shade100,
                            child: imageUrl.startsWith('http')
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.diamond_outlined,
                                        color: AppColors.primaryMaroon,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.diamond_outlined,
                                        color: AppColors.primaryMaroon,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Subcategory title
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: isSelected ? AppColors.primaryMaroon : AppColors.textSecondary,
                        fontSize: 8.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }



  bool _isAnyFilterActive() {
    final hasPriceFilter = (minPriceFilter != null && minPriceFilter! > 0) || (maxPriceFilter != null && maxPriceFilter! < 500000.0);
    final hasWeightFilter = minWeightFilter > 1.0 || maxWeightFilter < 2000.0;
    final hasGenderFilter = selectedGender.value != 'All';
    final hasMaterialFilter = selectedMaterials.isNotEmpty;
    return hasPriceFilter || hasWeightFilter || hasGenderFilter || hasMaterialFilter;
  }

  void _showSortBottomSheet() {
    Get.bottomSheet(
      Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Title
                Text(
                  'Sort By',
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primaryMaroon,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 8),
                // Options
                ...sortOptions.map((option) {
                  final isSelected = selectedSort.value == option;
                  return InkWell(
                    onTap: () {
                      selectedSort.value = option;
                      Get.back();
                      _fetchProductsFromApi(isAppend: false);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryMaroon.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? AppColors.primaryMaroon
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryMaroon
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryMaroon,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          )),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showFilterSheet() async {
    final JewelryCategory category;
    if (Get.arguments is Map) {
      category = (Get.arguments as Map<String, dynamic>)['category'] as JewelryCategory;
    } else {
      category = Get.arguments as JewelryCategory;
    }

    final result = await Get.to(
      () => const FilterScreen(),
      arguments: {
        'category': category,
        'selectedSubId': selectedSubCategoryId.value,
        'minPrice': minPriceFilter,
        'maxPrice': maxPriceFilter,
        'materials': selectedMaterials.toList(),
        'gender': selectedGender.value,
        'minWeight': minWeightFilter,
        'maxWeight': maxWeightFilter,
        'highlights': selectedHighlights.toList(),
      },
    );

    if (result != null) {
      setState(() {
        selectedSubCategoryId.value = result['selectedSubId'] ?? 'all';
        minPriceFilter = result['minPrice'];
        maxPriceFilter = result['maxPrice'];
        selectedMaterials.assignAll(result['materials'] ?? []);
        selectedGender.value = result['gender'] ?? 'All';
        minWeightFilter = result['minWeight'] ?? 1.0;
        maxWeightFilter = result['maxWeight'] ?? 2000.0;
      });
      _fetchProductsFromApi(isAppend: false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT GRID CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Gold Jewelry';
    final price = product['price'] ?? '₹0';
    final weight = product['weight'] ?? '';
    final karat = product['karat'] ?? '';
    final image = product['image'] ?? 'assets/temp/demo_1.jpeg';
    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        Get.to(
          () => const ProductDetailsScreen(),
          arguments: product,
          preventDuplicates: false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Image Stack - takes up all remaining available height
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: image.startsWith('http')
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.warmCream, AppColors.paleGold],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.warmCream, AppColors.paleGold],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.champagneGold.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                  ),
                  // Gradient overlay on image bottom
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0x30000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Wishlist button overlay (Centralized wishlist toggler)
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
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isWishlisted ? Colors.red : AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Weight & Purity tags at the bottom of the image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (karat.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              karat,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (weight.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              weight,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
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

            // Product Information - natural height, never overflows
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.maroonPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

class _SubCategoryShimmer extends StatefulWidget {
  const _SubCategoryShimmer();

  @override
  State<_SubCategoryShimmer> createState() => _SubCategoryShimmerState();
}

class _SubCategoryShimmerState extends State<_SubCategoryShimmer>
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
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 76,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: shimmerGradient,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: shimmerGradient,
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

class _ProductGridShimmer extends StatefulWidget {
  final int itemCount;

  const _ProductGridShimmer({
    this.itemCount = 6,
  });

  @override
  State<_ProductGridShimmer> createState() => _ProductGridShimmerState();
}

class _ProductGridShimmerState extends State<_ProductGridShimmer>
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

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Shimmer Placeholder
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: shimmerGradient,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                  ),
                  // Info Shimmer Placeholder
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: shimmerGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: shimmerGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: shimmerGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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
