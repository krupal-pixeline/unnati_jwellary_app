import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import 'product_details_controller.dart';
import 'image_preview_screen.dart';
import 'photo_gallery_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/custom_app_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? tag;
  const ProductDetailsScreen({super.key, this.tag});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final String _screenTag;
  late final ProductDetailsController controller;
  late final PageController pageController;
  Worker? _imageIndexWorker;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? args = Get.arguments is Map<String, dynamic>
        ? Map<String, dynamic>.from(Get.arguments as Map<String, dynamic>)
        : null;
    final String? argId = args?['id']?.toString() ?? args?['_id']?.toString();
    _screenTag = widget.tag ??
        (argId != null && argId.isNotEmpty
            ? "${argId}_${DateTime.now().microsecondsSinceEpoch}"
            : DateTime.now().microsecondsSinceEpoch.toString());

    controller = Get.put(ProductDetailsController(), tag: _screenTag);
    pageController = PageController();

    _imageIndexWorker = ever(controller.currentImageIndex, (index) {
      if (pageController.hasClients && pageController.page?.round() != index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _imageIndexWorker?.dispose();
    pageController.dispose();
    Get.delete<ProductDetailsController>(tag: _screenTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,

      // ── Custom AppBar ──────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Obx(
          () => CustomAppBar(
            title: controller.product['name']?.toString().isNotEmpty == true
                ? controller.product['name'].toString()
                : 'Details',
            actions: [
              IconButton(
                icon: Icon(
                  controller.isWishlisted.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.isWishlisted.value
                      ? Colors.red
                      : Colors.white,
                ),
                onPressed: () => controller.toggleWishlist(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),

      // ── Main Content Area ──────────────────────────────────────────────────
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _ProductDetailsShimmer();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Slider Carousel Card (Edge-to-Edge)
                _buildMainImageSlider(context, controller, pageController),
                const SizedBox(height: 2),

                // 2. Thumbnail Strip Card (Shown only if more than 1 image)
                Obx(() {
                  if (controller.productImages.length <= 1) {
                    return const SizedBox.shrink();
                  }
                  return _buildSectionCard(
                    child: _buildThumbnailStrip(controller),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                  );
                }),

                // 3. Product Header (Title, Price, Hallmark)
                _buildSectionCard(child: _buildProductHeader(controller)),

                // 4. Product Highlights Grid Card (Shown only if highlights exist)
                Obx(() {
                  final highlightsWidget = _buildHighlightsGrid(controller);
                  if (highlightsWidget is SizedBox) return const SizedBox.shrink();
                  return _buildSectionCard(
                    child: highlightsWidget,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                  );
                }),

                // 5. About Product / Description Card (Shown only if description exists)
                Obx(() {
                  final rawDesc = controller.product['description']?.toString() ?? '';
                  if (rawDesc.trim().isEmpty) return const SizedBox.shrink();
                  return _buildSectionCard(child: _buildAboutProduct(controller));
                }),

                // 6. Jewellery Details Section Header & Tab Bar Switcher
                _buildJewelleryDetailsHeader(controller),

                // 7. Dynamic Tab View Content (Tab 0: Specifications, Tab 1: Price Breakup)
                Obx(() {
                  if (controller.selectedDetailTab.value == 1) {
                    // Tab 1: Price Breakup
                    return _buildSectionCard(
                      child: _buildPriceBreakupSection(controller),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                    );
                  }

                  // Tab 0: Product Details Specifications Table
                  return Column(
                    children: [
                      // Specifications table Card
                      _buildSectionCard(
                        child: _buildSpecificationsTable(controller),
                        padding: EdgeInsets.zero,
                      ),

                      // Dynamic Specifications Card
                      Obx(() {
                        final specsRaw = controller.product['specifications'];
                        if (specsRaw == null ||
                            specsRaw is! List ||
                            specsRaw.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _buildSectionCard(
                          child: _buildDynamicSpecificationsSection(controller),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  );
                }),

                // 6. Related Products Card (Shown only if related products exist)
                Obx(() {
                  if (controller.relatedProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildSectionCard(
                    child: _buildRelatedProductsSection(controller),
                    padding: const EdgeInsets.only(top: 10, bottom: 12),
                  );
                }),

                const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ),

      // ── Sticky Bottom Action Row ──────────────────────────────────────────
      bottomNavigationBar: _buildStickyBottomBar(context, controller),
    );
  }

  // ── Helper to build clean uniform cards for each section ──────────────────
  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );
  }

  // ── Main Image Slider ──────────────────────────────────────────────────────
  Widget _buildMainImageSlider(
    BuildContext context,
    ProductDetailsController controller,
    PageController pageController,
  ) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Obx(() {
            if (controller.productImages.isEmpty) {
              return Container(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: AppColors.primaryGold,
                  ),
                ),
              );
            }

            return Stack(
              children: [
                // PageView for swiping images
                PageView.builder(
                  controller: pageController,
                  itemCount: controller.productImages.length,
                  onPageChanged: (index) =>
                      controller.currentImageIndex.value = index,
                  itemBuilder: (context, index) {
                    final imgPath = controller.productImages[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ImagePreviewScreen(
                            images: controller.productImages,
                            initialIndex: index,
                          ),
                        );
                      },
                      child: imgPath.startsWith('http')
                          ? Image.network(
                              imgPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryMaroon,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: AppColors.paleGold,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 64,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                            )
                          : (imgPath.startsWith('assets/')
                              ? Image.asset(
                                  imgPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.paleGold,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 64,
                                            color: AppColors.primaryGold,
                                          ),
                                        ),
                                      ),
                                )
                              : Container(
                                  color: AppColors.paleGold,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 64,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                )),
                    );
                  },
                ),

                // Dot Indicator Overlay (Bottom Center)
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.productImages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: controller.currentImageIndex.value == index
                              ? 18
                              : 6,
                          decoration: BoxDecoration(
                            color: controller.currentImageIndex.value == index
                                ? AppColors.primaryMaroon
                                : AppColors.primaryGold.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Zoom Icon Overlay (Bottom Right)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => ImagePreviewScreen(
                          images: controller.productImages,
                          initialIndex: controller.currentImageIndex.value,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Thumbnail Strip Row ────────────────────────────────────────────────────
  Widget _buildThumbnailStrip(ProductDetailsController controller) {
    return SizedBox(
      height: 60,
      child: Obx(() {
        // Show first 5 thumbnails, and make the 5th an overlay "+5 View All"
        final int visibleCount = controller.productImages.length > 5
            ? 5
            : controller.productImages.length;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          itemBuilder: (context, index) {
            final String imagePath = controller.productImages[index];
            final bool isSelected = controller.currentImageIndex.value == index;
            final bool isLast =
                index == 4 && controller.productImages.length > 5;

            return GestureDetector(
              onTap: () {
                if (isLast) {
                  Get.to(
                    () => PhotoGalleryScreen(
                      images: controller.productImages,
                      productName: controller.product['name'] ?? '',
                    ),
                  );
                } else {
                  controller.selectImage(index);
                }
              },
              child: Container(
                width: 58,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected && !isLast
                        ? AppColors.primaryMaroon
                        : AppColors.border.withValues(alpha: 0.6),
                    width: isSelected && !isLast ? 2.0 : 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: AppColors.backgroundSecondary,
                                    child: const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: AppColors.backgroundSecondary,
                                    child: const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                            ),
                      if (isLast)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          alignment: Alignment.center,
                          child: Text(
                            "+${controller.productImages.length - 4}\nView All",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
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
    );
  }

  // ── Product Title & Price Header ───────────────────────────────────────────
  Widget _buildProductHeader(ProductDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (controller.product['category'] != null &&
                controller.product['category'].toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  controller.product['category'].toString().toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            if (controller.product['category'] != null &&
                controller.product['category'].toString().isNotEmpty &&
                controller.product['subCategoryName'] != null &&
                controller.product['subCategoryName'].toString().isNotEmpty)
              const SizedBox(width: 8),
            if (controller.product['subCategoryName'] != null &&
                controller.product['subCategoryName'].toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  controller.product['subCategoryName']
                      .toString()
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: AppColors.warmGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Product Title
        Text(
          controller.product['name'] ?? '',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),

        // Price & Certification Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      controller.product['price']?.toString() ?? '',
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryMaroon,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (controller.product['originalPrice'] != null &&
                        controller.product['originalPrice'].toString().trim().isNotEmpty)
                      Text(
                        controller.product['originalPrice'].toString(),
                        style: GoogleFonts.outfit(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Inclusive of all taxes",
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => controller.selectedDetailTab.value = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 14,
                      color: AppColors.primaryMaroon,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Price Breakup",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryMaroon,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Jewellery Details Section Header with Segmented Tab Switcher ────────
  Widget _buildJewelleryDetailsHeader(ProductDetailsController controller) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          Text(
            "Jewellery Details",
            style: GoogleFonts.outfit(
              color: AppColors.primaryMaroon,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailsBreakupSegmentedBar(controller),
        ],
      ),
    );
  }

  // ── Segmented Tab Switcher Bar ("Product Details" | "Price Breakup") ──────
  Widget _buildDetailsBreakupSegmentedBar(ProductDetailsController controller) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8D6C8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Details Tab
              GestureDetector(
                onTap: () => controller.selectedDetailTab.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.selectedDetailTab.value == 0
                        ? AppColors.primaryMaroon
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Product Details",
                    style: GoogleFonts.outfit(
                      color: controller.selectedDetailTab.value == 0
                          ? Colors.white
                          : const Color(0xFF4A3E3D),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              // Price Breakup Tab
              GestureDetector(
                onTap: () => controller.selectedDetailTab.value = 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.selectedDetailTab.value == 1
                        ? AppColors.primaryMaroon
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Price Breakup",
                    style: GoogleFonts.outfit(
                      color: controller.selectedDetailTab.value == 1
                          ? Colors.white
                          : const Color(0xFF4A3E3D),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Price Formatting Methods ───────────────────────────────────────
  String _formatIndianCurrency(num? value, {bool showDecimals = false}) {
    if (value == null) return '₹0';
    if (showDecimals) {
      final double val = value.toDouble();
      final String valStr = val.toStringAsFixed(2);
      final List<String> parts = valStr.split('.');
      final String formattedInt = _formatIndianIntString(parts[0]);
      return '₹$formattedInt.${parts[1]}';
    } else {
      final int rounded = value.round();
      return '₹${_formatIndianIntString(rounded.abs().toString())}';
    }
  }

  String _formatIndianIntString(String valStr) {
    if (valStr.length <= 3) return valStr;
    final String lastThree = valStr.substring(valStr.length - 3);
    final String other = valStr.substring(0, valStr.length - 3);
    final String formattedOther = other.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formattedOther,$lastThree';
  }

  // ── Price Breakup Section Widget Table ─────────────────────────────────────
  Widget _buildPriceBreakupSection(ProductDetailsController controller) {
    final prod = controller.product;

    final String purity = prod['purity']?.toString() ?? prod['karat']?.toString() ?? '';
    final String metalType = prod['metal']?.toString() ?? prod['metalType']?.toString() ?? '';
    final String metalTitle = purity.isNotEmpty && metalType.isNotEmpty
        ? "$purity Hallmarked $metalType"
        : (metalType.isNotEmpty ? metalType : (purity.isNotEmpty ? purity : "Metal"));

    final double? weightVal = prod['weight'] != null
        ? double.tryParse(prod['weight'].toString().replaceAll(RegExp(r'[^\d.]'), ''))
        : null;
    final String weightStr = weightVal != null ? "${weightVal}g" : "-";

    final double? baseRate = prod['baseRate'] != null
        ? double.tryParse(prod['baseRate'].toString())
        : null;
    final String rateStr = baseRate != null
        ? "${_formatIndianCurrency(baseRate, showDecimals: true)}/g"
        : "-";

    final double? metalValue = prod['metalValue'] != null
        ? double.tryParse(prod['metalValue'].toString())
        : (baseRate != null && weightVal != null ? baseRate * weightVal : null);
    final String metalValueStr = _formatIndianCurrency(metalValue);

    final double? makingCharge = prod['makingCharge'] != null
        ? double.tryParse(prod['makingCharge'].toString())
        : null;
    final String makingChargeType = prod['makingChargeType']?.toString() ?? '';
    final double? makingChargeValue = prod['makingChargeValue'] != null
        ? double.tryParse(prod['makingChargeValue'].toString())
        : null;
    String makingSubtitle = '';
    if (makingChargeValue != null && makingChargeValue > 0) {
      makingSubtitle = makingChargeType == 'percentage'
          ? "${makingChargeValue.toStringAsFixed(0)}%"
          : _formatIndianCurrency(makingChargeValue);
    }
    final String makingChargeStr = _formatIndianCurrency(makingCharge);

    final double? otherCharge = prod['otherCharge'] != null
        ? double.tryParse(prod['otherCharge'].toString())
        : 0.0;
    final String otherChargeStr = _formatIndianCurrency(otherCharge);

    final double subTotal = (metalValue ?? 0.0) + (makingCharge ?? 0.0) + (otherCharge ?? 0.0);
    final String subTotalStr = _formatIndianCurrency(subTotal > 0 ? subTotal : null);

    final double? gstValue = prod['gstValue'] != null
        ? double.tryParse(prod['gstValue'].toString())
        : null;
    final double? gstAmount = prod['gst'] != null
        ? double.tryParse(prod['gst'].toString())
        : (subTotal > 0 && gstValue != null ? subTotal * (gstValue / 100) : null);
    final String gstLabel = gstValue != null && gstValue > 0 ? "GST (${gstValue.toStringAsFixed(0)}%)" : "GST";
    final String gstStr = _formatIndianCurrency(gstAmount);

    final double? grandTotal = prod['calculatedPrice'] != null
        ? double.tryParse(prod['calculatedPrice'].toString())
        : (subTotal > 0 ? subTotal + (gstAmount ?? 0.0) : null);
    final String grandTotalStr = _formatIndianCurrency(grandTotal);

    final bool hasPriceData = baseRate != null || metalValue != null || makingCharge != null || (grandTotal != null && grandTotal > 0);
    if (!hasPriceData) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        alignment: Alignment.center,
        child: Text(
          "Price breakup details are not available for this item.",
          style: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5D5C5),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // ── Table Header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF4EE),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFEADCCF),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: Text(
                      'PRODUCT DETAILS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6E5A4C),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 40,
                    child: Text(
                      'RATE',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6E5A4C),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 35,
                    child: Text(
                      'WEIGHT',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6E5A4C),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'DISCOUNT',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6E5A4C),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 45,
                    child: Text(
                      'VALUE',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6E5A4C),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Row 1: Metal ────────────────────────────────────────────────
            _buildPriceBreakupRow(
              titleWidget: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metalTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Metal Type",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: const Color(0xFF8C7A6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              rate: rateStr,
              weight: weightStr,
              discount: '-',
              value: metalValueStr,
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0E5DA)),

            // ── Row 2: Making Charges ───────────────────────────────────────
            _buildPriceBreakupRow(
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Making Charges",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (makingSubtitle.isNotEmpty)
                    Text(
                      makingSubtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: const Color(0xFF8C7A6B),
                      ),
                    ),
                ],
              ),
              rate: '-',
              weight: '-',
              discount: '-',
              value: makingChargeStr,
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0E5DA)),

            // ── Row 3: Other Charges ────────────────────────────────────────
            _buildPriceBreakupRow(
              titleWidget: Text(
                "Other Charges",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              rate: '-',
              weight: '-',
              discount: '-',
              value: otherChargeStr,
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0E5DA)),

            // ── Row 4: Sub Total ────────────────────────────────────────────
            _buildPriceBreakupRow(
              titleWidget: Text(
                "Sub Total",
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              rate: '-',
              weight: weightVal != null ? "${weightVal}g" : '-',
              discount: '-',
              value: subTotalStr,
              isBold: true,
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0E5DA)),

            // ── Row 5: GST ──────────────────────────────────────────────────
            _buildPriceBreakupRow(
              titleWidget: Text(
                gstLabel,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              rate: '-',
              weight: '-',
              discount: '-',
              value: gstStr,
            ),

            // ── Row 6: Grand Total ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0F2),
                border: Border(
                  top: BorderSide(
                    color: AppColors.primaryMaroon.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: Text(
                      'Grand Total',
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 40,
                    child: Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                  ),
                  const Expanded(
                    flex: 35,
                    child: Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                  ),
                  const Expanded(
                    flex: 25,
                    child: Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 45,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        grandTotalStr,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryMaroon,
                        ),
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

  Widget _buildPriceBreakupRow({
    required Widget titleWidget,
    required String rate,
    required String weight,
    required String discount,
    required String value,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 70,
            child: titleWidget,
          ),
          Expanded(
            flex: 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                rate,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                weight,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              discount,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 45,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                  color: isBold ? AppColors.textPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Highlights Grid ────────────────────────────────────────────────────────
  Widget _buildHighlightsGrid(ProductDetailsController controller) {
    final prod = controller.product;
    final List<Map<String, dynamic>> highlights = [];

    final String purity = prod['purity']?.toString() ?? prod['karat']?.toString() ?? '';
    if (purity.trim().isNotEmpty) {
      highlights.add({
        'label': 'Purity',
        'val': purity,
        'icon': Icons.workspace_premium_outlined,
      });
    }

    final String weight = prod['weight']?.toString() ?? '';
    if (weight.trim().isNotEmpty) {
      highlights.add({
        'label': 'Weight',
        'val': weight,
        'icon': Icons.scale_outlined,
      });
    }

    final String metal = prod['metal']?.toString() ?? prod['metalType']?.toString() ?? '';
    if (metal.trim().isNotEmpty) {
      highlights.add({
        'label': 'Metal',
        'val': metal,
        'icon': Icons.diamond_outlined,
      });
    }

    final String gender = prod['gender']?.toString() ?? '';
    if (gender.trim().isNotEmpty) {
      highlights.add({
        'label': 'Gender',
        'val': gender,
        'icon': Icons.person_outline,
      });
    }

    final String collection = prod['collection']?.toString() ?? '';
    if (collection.trim().isNotEmpty) {
      highlights.add({
        'label': 'Collection',
        'val': collection,
        'icon': Icons.stars_outlined,
      });
    }

    final String occasion = prod['occasion']?.toString() ?? '';
    if (occasion.trim().isNotEmpty) {
      highlights.add({
        'label': 'Occasion',
        'val': occasion,
        'icon': Icons.celebration_outlined,
      });
    }

    final String hallmark = prod['hallmark']?.toString() ?? '';
    if (hallmark.trim().isNotEmpty) {
      highlights.add({
        'label': 'Certification',
        'val': hallmark,
        'icon': Icons.verified_outlined,
      });
    }

    if (highlights.isEmpty) {
      return const SizedBox.shrink();
    }

    final int count = highlights.length;
    final int crossAxisCount = count < 4 ? count : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.05,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final item = highlights[index];
        return _highlightItem(
          item['label'] as String,
          item['val'] as String,
          item['icon'] as IconData,
        );
      },
    );
  }

  Widget _highlightItem(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── About Product / Description ────────────────────────────────────────────
  Widget _buildAboutProduct(ProductDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About Product",
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final rawHtml = controller.product['description']?.toString() ?? '';
          if (rawHtml.isEmpty) return const SizedBox.shrink();
          final isExpanded = controller.isDescriptionExpanded.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HtmlRichText(
                html: rawHtml,
                maxLines: isExpanded ? null : 4,
                baseStyle: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.toggleDescription(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? "Read Less" : "Read More",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryGold,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Specifications Table ───────────────────────────────────────────────────
  Widget _buildSpecificationsTable(ProductDetailsController controller) {
    final List<Map<String, String>> specKeys = [];

    if (controller.product['purity'] != null &&
        controller.product['purity'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Gold Purity',
        'val': controller.product['purity'].toString(),
      });
    }
    if (controller.product['weight'] != null &&
        controller.product['weight'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Weight',
        'val': controller.product['weight'].toString(),
      });
    }
    if (controller.product['metal'] != null &&
        controller.product['metal'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Metal',
        'val': controller.product['metal'].toString(),
      });
    }
    if (controller.product['gender'] != null &&
        controller.product['gender'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Gender',
        'val': controller.product['gender'].toString(),
      });
    }
    if (controller.product['category'] != null &&
        controller.product['category'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Category',
        'val': controller.product['category'].toString(),
      });
    }
    if (controller.product['subCategoryName'] != null &&
        controller.product['subCategoryName'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Sub Category',
        'val': controller.product['subCategoryName'].toString(),
      });
    }
    if (controller.product['collection'] != null &&
        controller.product['collection'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Collection',
        'val': controller.product['collection'].toString(),
      });
    }
    if (controller.product['hallmark'] != null &&
        controller.product['hallmark'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Hallmark',
        'val': controller.product['hallmark'].toString(),
      });
    }
    if (controller.product['makingCharges'] != null &&
        controller.product['makingCharges'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Making Charge',
        'val': controller.product['makingCharges'].toString(),
      });
    }
    if (controller.product['color'] != null &&
        controller.product['color'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Color',
        'val': controller.product['color'].toString(),
      });
    }
    if (controller.product['gst'] != null &&
        controller.product['gst'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'GST',
        'val': controller.product['gst'].toString(),
      });
    }
    if (controller.product['occasion'] != null &&
        controller.product['occasion'].toString().isNotEmpty) {
      specKeys.add({
        'label': 'Occasion',
        'val': controller.product['occasion'].toString(),
      });
    }

    if (specKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Product Details",
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specKeys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final spec = specKeys[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          index <
                              (specKeys.length % 2 == 0
                                  ? specKeys.length - 2
                                  : specKeys.length - 1)
                          ? AppColors.divider.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 0.5,
                    ),
                    right: BorderSide(
                      color: index % 2 == 0
                          ? AppColors.divider.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      spec['label']!,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spec['val']!,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Dynamic Specifications Card ────────────────────────────────────────────
  Widget _buildDynamicSpecificationsSection(
    ProductDetailsController controller,
  ) {
    final specsRaw = controller.product['specifications'];
    if (specsRaw == null || specsRaw is! List || specsRaw.isEmpty) {
      return const SizedBox.shrink();
    }

    final specs = List<Map<String, dynamic>>.from(specsRaw);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Specifications",
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specs.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: AppColors.divider,
          ),
          itemBuilder: (context, index) {
            final spec = specs[index];
            final name = spec['name']?.toString() ?? '';
            final val = spec['value']?.toString() ?? '';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: index % 2 == 0
                  ? Colors.transparent
                  : AppColors.backgroundPrimary.withValues(alpha: 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: Text(
                      val,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Related Products Carousel
  Widget _buildRelatedProductsSection(ProductDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Related Products",
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 280,
          child: Obx(() {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.relatedProducts.length,
              itemBuilder: (context, index) {
                final relItem = controller.relatedProducts[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to a new product details screen stack for nested viewing
                    Get.to(
                      () => const ProductDetailsScreen(),
                      arguments: relItem,
                      preventDuplicates: false,
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Related Product Image (80% of height -> 224)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: relItem['image'] != null && relItem['image'].toString().startsWith('http')
                              ? Image.network(
                                  relItem['image'].toString(),
                                  height: 224,
                                  width: double.infinity,
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.paleGold.withValues(alpha: 0.3),
                                        height: 224,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 36,
                                            color: AppColors.primaryGold,
                                          ),
                                        ),
                                      ),
                                )
                              : (relItem['image'] != null && relItem['image'].toString().startsWith('assets/')
                                  ? Image.asset(
                                      relItem['image'].toString(),
                                      height: 224,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            color: AppColors.paleGold.withValues(alpha: 0.3),
                                            height: 224,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported_outlined,
                                                size: 36,
                                                color: AppColors.primaryGold,
                                              ),
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: AppColors.paleGold.withValues(alpha: 0.3),
                                      height: 224,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 36,
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                    )),
                        ),

                        // Related Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  relItem['name'] ?? '',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  relItem['price'] ?? '',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.primaryMaroon,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
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
            );
          }),
        ),
      ],
    );
  }


  // ── Sticky Bottom Action Row (Book Visit + Chat with Us) ───────────────────
  Widget _buildStickyBottomBar(BuildContext context, ProductDetailsController controller,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Button 1: Book Visit (Maroon Gradient Primary)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBookingDialog(context, controller),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMaroon.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.champagneGold,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Book Visit",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Button 2: Chat with Us (WhatsApp Outlined Secondary)
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final String phone = "+916351630432";
                  final String productName =
                      controller.product['name']?.toString().trim() ?? '';
                  final String message = productName.isNotEmpty
                      ? "Hi, I'm interested in: *$productName*. Could you share more details?"
                      : "Hi, I'm interested in your products. Could you share more details?";
                  final Uri whatsappUri = Uri.parse(
                    "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
                  );
                  if (await canLaunchUrl(whatsappUri)) {
                    await launchUrl(
                      whatsappUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    Get.snackbar(
                      "WhatsApp Error",
                      "Could not launch WhatsApp application.",
                      backgroundColor: AppColors.errorLight,
                      colorText: AppColors.error,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primaryMaroon,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/whatsapp.png",
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryMaroon,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Chat with Us",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryMaroon,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
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
  }

  // ── Showroom Visit Booking Flow Dialog ──────────────────────────────────────
  void _showBookingDialog(BuildContext context, ProductDetailsController controller) {
    controller.resetBookingState();

    final DateTime today = DateTime.now();
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        final selectedDate = controller.bookingDate;
        final selectedSlot = controller.bookingSlot;
        final isCustomDate = controller.isCustomDate;
        final selectedPurpose = controller.selectedPurpose;
        final selectedBudget = controller.selectedBudget;
        final messageController = controller.bookingMessageController;

        final purposes = [
          'Buying Jewelry',
          'Viewing Collections',
          'Custom Design Inquiry',
          'Jewelry Exchange/Sells',
          'Repairing & Polishing',
          'Other',
        ];

        final budgets = [
          'Under ₹25,000',
          '₹25,000 - ₹50,000',
          '₹50,000 - ₹1,00,000',
          '₹1,00,000 - ₹2,50,000',
          '₹2,50,000 - ₹5,00,000',
          '₹5,00,000+',
          'Not Sure',
        ];

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Schedule Showroom Visit",
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Experience this item live in-store. Select your preferred date and time slot below.",
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date Selection Row
                  Text(
                    "Select Date",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Horizontal Date Selector (Today, Tomorrow, Custom Date)
                  Obx(() {
                    final bool isTodaySelected =
                        !isCustomDate.value &&
                        selectedDate.value.year == today.year &&
                        selectedDate.value.month == today.month &&
                        selectedDate.value.day == today.day;

                    final bool isTomorrowSelected =
                        !isCustomDate.value &&
                        selectedDate.value.year == tomorrow.year &&
                        selectedDate.value.month == tomorrow.month &&
                        selectedDate.value.day == tomorrow.day;

                    final bool isCustomDateSelected = isCustomDate.value;

                    final customLabel = isCustomDateSelected
                        ? "${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}"
                        : "Custom Date";

                    return Row(
                      children: [
                        // Today Chip
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Today"),
                            selected: isTodaySelected,
                            onSelected: (val) {
                              if (val) {
                                selectedDate.value = today;
                                isCustomDate.value = false;
                              }
                            },
                            selectedColor: AppColors.paleGold,
                            backgroundColor: AppColors.backgroundSecondary
                                .withValues(alpha: 0.3),
                            labelStyle: GoogleFonts.outfit(
                              color: isTodaySelected
                                  ? AppColors.maroonPrimary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isTodaySelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isTodaySelected
                                    ? AppColors.primaryGold
                                    : AppColors.border.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Tomorrow Chip
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Tomorrow"),
                            selected: isTomorrowSelected,
                            onSelected: (val) {
                              if (val) {
                                selectedDate.value = tomorrow;
                                isCustomDate.value = false;
                              }
                            },
                            selectedColor: AppColors.paleGold,
                            backgroundColor: AppColors.backgroundSecondary
                                .withValues(alpha: 0.3),
                            labelStyle: GoogleFonts.outfit(
                              color: isTomorrowSelected
                                  ? AppColors.maroonPrimary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isTomorrowSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isTomorrowSelected
                                    ? AppColors.primaryGold
                                    : AppColors.border.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Custom Date Chip
                        Expanded(
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: isCustomDateSelected
                                      ? AppColors.maroonPrimary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    customLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            selected: isCustomDateSelected,
                            onSelected: (val) async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: isCustomDateSelected
                                    ? selectedDate.value
                                    : DateTime.now().add(
                                        const Duration(days: 2),
                                      ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryMaroon,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                selectedDate.value = picked;
                                isCustomDate.value = true;
                              }
                            },
                            selectedColor: AppColors.paleGold,
                            backgroundColor: AppColors.backgroundSecondary
                                .withValues(alpha: 0.3),
                            labelStyle: GoogleFonts.outfit(
                              color: isCustomDateSelected
                                  ? AppColors.maroonPrimary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isCustomDateSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isCustomDateSelected
                                    ? AppColors.primaryGold
                                    : AppColors.border.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),

                  // Time Selection Label
                  Text(
                    "Select Time Slot",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Time Slot Selectors (Static Slots + Dynamic Custom Slot)
                  Obx(() {
                    final currSlot = selectedSlot.value;

                    return Column(
                      children: [
                        _buildSelectableSlotTile(
                          'Morning (10 AM - 1 PM)',
                          currSlot == 'Morning (10 AM - 1 PM)',
                          Icons.wb_twilight_outlined,
                          () {
                            selectedSlot.value = 'Morning (10 AM - 1 PM)';
                          },
                        ),
                        const SizedBox(height: 4),
                        _buildSelectableSlotTile(
                          'Afternoon (1 PM - 4 PM)',
                          currSlot == 'Afternoon (1 PM - 4 PM)',
                          Icons.light_mode_outlined,
                          () {
                            selectedSlot.value = 'Afternoon (1 PM - 4 PM)';
                          },
                        ),
                        const SizedBox(height: 4),
                        _buildSelectableSlotTile(
                          'Evening (4 PM - 8 PM)',
                          currSlot == 'Evening (4 PM - 8 PM)',
                          Icons.wb_sunny_outlined,
                          () {
                            selectedSlot.value = 'Evening (4 PM - 8 PM)';
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),

                  // Purpose of Visit Dropdown
                  Text(
                    "Purpose of Visit",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedPurpose.value,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary.withValues(
                          alpha: 0.3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGold,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: purposes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: GoogleFonts.outfit()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) selectedPurpose.value = val;
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Estimated Budget Dropdown
                  Text(
                    "Estimated Budget",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedBudget.value,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary.withValues(
                          alpha: 0.3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGold,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: budgets.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: GoogleFonts.outfit()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) selectedBudget.value = val;
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Message (Optional) Text Field
                  Text(
                    "Message (Optional)",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: messageController,
                    maxLines: 2,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "Add special instructions or items you want to view...",
                      hintStyle: GoogleFonts.outfit(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGold,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final bool loading = controller.isBookingLoading.value;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMaroon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                final dateStr =
                                    "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";
                                
                                String apiTimeSlot = 'Morning';
                                if (selectedSlot.value.startsWith('Afternoon')) {
                                  apiTimeSlot = 'Afternoon';
                                } else if (selectedSlot.value.startsWith('Evening')) {
                                  apiTimeSlot = 'Evening';
                                }

                                final purposeStr = selectedPurpose.value;
                                final budgetStr = selectedBudget.value;
                                final requirementsStr =
                                    messageController.text.trim();

                                final success = await controller.bookVisit(
                                  preferredDate: dateStr,
                                  preferredTime: apiTimeSlot,
                                  purposeOfVisit: purposeStr,
                                  estimatedBudget: budgetStr,
                                  additionalRequirements: requirementsStr,
                                  productId: controller.product['id']?.toString() ??
                                      controller.product['_id']?.toString() ??
                                      '',
                                );
                                if (success) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  Get.snackbar(
                                    "Booking Confirmed!",
                                    "Showroom visit scheduled for $dateStr during $apiTimeSlot.",
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    colorText: const Color(0xFF2E7D32),
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(15),
                                    duration: const Duration(seconds: 4),
                                  );
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Confirm Appointment",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectableSlotTile(String slotName, bool isSelected, IconData icon, VoidCallback onTap,) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.paleGold.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.border.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryMaroon
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                slotName,
                style: GoogleFonts.outfit(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryMaroon,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}


class _ProductDetailsShimmer extends StatefulWidget {
  const _ProductDetailsShimmer();

  @override
  State<_ProductDetailsShimmer> createState() => _ProductDetailsShimmerState();
}

class _ProductDetailsShimmerState extends State<_ProductDetailsShimmer> with SingleTickerProviderStateMixin {
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

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large image slider placeholder
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(gradient: shimmerGradient),
              ),
              const SizedBox(height: 10),
              // Thumbnail strip placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => Container(
                      height: 50,
                      width: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header title placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: shimmerGradient,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Price placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: shimmerGradient,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Highlights placeholder grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: shimmerGradient,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _HtmlRichText extends StatelessWidget {
  final String html;
  final TextStyle? baseStyle;
  final int? maxLines;

  const _HtmlRichText({required this.html, this.baseStyle, this.maxLines});

  @override
  Widget build(BuildContext context) {
    final spans = _parseHtml(html, baseStyle ?? const TextStyle());
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }

  List<TextSpan> _parseHtml(String input, TextStyle base) {
    final List<TextSpan> spans = [];

    // Strip <div ...> wrapper tags but keep content, replace <br> with newline
    String cleaned = input
        .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');

    // Tokenise: split by any supported HTML tag
    final tagRegex = RegExp(r'(<\/?(b|strong|i|em|u)>)', caseSensitive: false);

    int cursor = 0;
    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;

    for (final match in tagRegex.allMatches(cleaned)) {
      // Add text before this tag
      if (match.start > cursor) {
        final text = _decodeHtml(cleaned.substring(cursor, match.start));
        if (text.isNotEmpty) {
          spans.add(
            TextSpan(
              text: text,
              style: _buildStyle(base, isBold, isItalic, isUnderline),
            ),
          );
        }
      }

      // Process the tag
      final tag = match.group(0)!.toLowerCase();
      final isClosing = tag.startsWith('</');
      final tagName = match.group(2)!.toLowerCase();

      if (tagName == 'b' || tagName == 'strong') {
        isBold = !isClosing;
      } else if (tagName == 'i' || tagName == 'em') {
        isItalic = !isClosing;
      } else if (tagName == 'u') {
        isUnderline = !isClosing;
      }

      cursor = match.end;
    }

    // Remaining text after last tag
    if (cursor < cleaned.length) {
      final text = _decodeHtml(cleaned.substring(cursor));
      if (text.isNotEmpty) {
        spans.add(
          TextSpan(
            text: text,
            style: _buildStyle(base, isBold, isItalic, isUnderline),
          ),
        );
      }
    }

    return spans;
  }

  TextStyle _buildStyle(
    TextStyle base,
    bool bold,
    bool italic,
    bool underline,
  ) {
    return base.copyWith(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  String _decodeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ''); // strip any remaining unknown tags
  }
}
