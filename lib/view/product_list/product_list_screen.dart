import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_urls.dart';
import '../../services/base_api_services.dart';
import '../../model/home/product_model.dart';
import '../category/wishlist_controller.dart';
import '../product_details/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>>? products;
  final String? initialGender;
  final String? apiUrl;
  final Map<String, String>? extraParams;

  const ProductListScreen({
    super.key,
    required this.title,
    this.products,
    this.initialGender,
    this.apiUrl,
    this.extraParams,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final RxString selectedGender = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedSort = 'Featured'.obs;

  final RxList<Map<String, dynamic>> displayedProducts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  final ScrollController _scrollController = ScrollController();

  // Gender display list
  final List<String> genderOptions = const ['All', 'Men', 'Women', 'Kids', 'Unisex'];

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

  @override
  void initState() {
    super.initState();

    // Map initial gender selection parameter
    if (widget.initialGender != null) {
      final String g = widget.initialGender!.toLowerCase();
      if (g == 'men') {
        selectedGender.value = 'Men';
      } else if (g == 'women') {
        selectedGender.value = 'Women';
      } else if (g == 'kids') {
        selectedGender.value = 'Kids';
      } else if (g == 'unisex') {
        selectedGender.value = 'Unisex';
      }
    }

    // Set initial static products if passed
    if (widget.products != null) {
      displayedProducts.assignAll(widget.products!);
    }

    // Scroll listener for pagination on scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadNextPage();
      }
    });

    // Handle search query with debounce
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) {
      _fetchProducts(isAppend: false);
    }, time: const Duration(milliseconds: 500));

    // Fetch initial list from API
    _fetchProducts(isAppend: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNextPage() {
    if (isLoading.value || currentPage.value >= totalPages.value) {
      return;
    }
    currentPage.value++;
    _fetchProducts(isAppend: true);
  }

  Future<void> _fetchProducts({bool isAppend = false}) async {
    // If it's a static list and the user hasn't selected any gender/sort/search, skip API call
    if (widget.products != null &&
        selectedGender.value.isEmpty &&
        searchQuery.value.trim().isEmpty &&
        selectedSort.value == 'Featured' &&
        widget.apiUrl == null &&
        widget.extraParams == null) {
      return;
    }

    try {
      isLoading.value = true;

      if (!isAppend) {
        currentPage.value = 1;
      }

      final Map<String, dynamic> params = {
        'page': currentPage.value.toString(),
        'limit': '10',
      };

      if (selectedGender.value.isNotEmpty && selectedGender.value != 'All') {
        params['gender'] = selectedGender.value;
      }

      if (searchQuery.value.trim().isNotEmpty) {
        params['search'] = searchQuery.value.trim();
      }

      final sortKey = sortApiKeys[selectedSort.value] ?? 'featured';
      params['sortBy'] = sortKey;

      if (widget.extraParams != null) {
        params.addAll(widget.extraParams!);
      }

      final responseJson = await BaseApiService().getRequest(
        url: widget.apiUrl ?? AppUrls.products,
        queryParams: params,
        apiName: 'PRODUCTS_LIST_SCREEN',
      );

      final bool success = responseJson['success'] as bool? ?? false;
      if (success) {
        final dataList = responseJson['data'] as List?;
        final List<Map<String, dynamic>> fetchedList = [];
        if (dataList != null) {
          for (var item in dataList) {
            if (item is Map<String, dynamic>) {
              final productData = ProductDataModel.fromJson(item);
              fetchedList.add(productData.toUiMap());
            }
          }
        }

        final pagination = responseJson['pagination'] as Map?;
        if (pagination != null) {
          totalPages.value = int.tryParse(pagination['totalPages']?.toString() ?? '1') ?? 1;
        } else {
          totalPages.value = 1;
        }

        if (isAppend) {
          displayedProducts.addAll(fetchedList);
        } else {
          displayedProducts.assignAll(fetchedList);
        }
      } else {
        if (!isAppend) {
          displayedProducts.clear();
        }
      }
    } catch (e) {
      debugPrint("❌ [ProductListScreen] Error fetching products from API: $e");
      if (!isAppend && displayedProducts.isEmpty && widget.products != null) {
        displayedProducts.assignAll(widget.products!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Sort Button
            IconButton(
              icon: const Icon(Icons.sort_rounded, color: AppColors.primaryMaroon),
              onPressed: _showSortBottomSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryMaroon,
                onRefresh: () => _fetchProducts(isAppend: false),
                child: Obx(() {
                  if (displayedProducts.isEmpty && isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
                      ),
                    );
                  }

                  if (displayedProducts.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: _buildEmptyState(),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      _buildGrid(displayedProducts),
                      if (isLoading.value && displayedProducts.isNotEmpty)
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Obx(() => searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      searchController.clear();
                      searchQuery.value = '';
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textSecondary),
                    ),
                  )
                : const SizedBox(width: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderTabs() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: genderOptions.length,
        itemBuilder: (context, index) {
          final gender = genderOptions[index];
          return Obx(() {
            final isSelected = (selectedGender.value == gender) ||
                (selectedGender.value.isEmpty && gender == 'All');
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  gender.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primaryMaroon,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryMaroon,
                backgroundColor: AppColors.paleGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                showCheckmark: false,
                onSelected: (val) {
                  if (val) {
                    selectedGender.value = gender == 'All' ? '' : gender;
                    _fetchProducts(isAppend: false);
                  }
                },
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> list) {
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final product = list[index];
        return _ProductGridCard(product: product);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond_outlined, size: 48, color: AppColors.primaryGold.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          const Text(
            'No matching products found.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Text(
                "Sort Products By",
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
                ),
              ),
            ),
            ...sortOptions.map((opt) {
              return Obx(() {
                final isSelected = selectedSort.value == opt;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryMaroon : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryMaroon)
                      : null,
                  onTap: () {
                    selectedSort.value = opt;
                    Get.back();
                    _fetchProducts(isAppend: false);
                  },
                );
              });
            }),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Gold Jewelry';
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
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
            // Image Area with Overlays
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
                  // Gradient Vignette overlay on bottom of the image for badge readability
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
                  // Favorite Wishlist heart button (Top-Right)
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
                  // Purity & Weight badges (Bottom-Left and Bottom-Right Overlay)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Purity Badge (e.g. 22K)
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
                        // Weight Badge (e.g. 10.44 gm)
                        if (weight.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              weight.contains('g') ? weight : '$weight gm',
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
            // Text Details Panel below the image
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
