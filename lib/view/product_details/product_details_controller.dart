import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../category/wishlist_controller.dart';
import '../profile/profile_controller.dart';
import '../../services/home_api_services.dart';
import '../../services/profile_api_services.dart';
import '../../utils/other_methods.dart';

class ProductDetailsController extends GetxController {
  final HomeApiService _homeApiService = HomeApiService();
  final RxBool isLoading = true.obs;

  // Active image index in the carousel/viewer
  final RxInt currentImageIndex = 0.obs;

  // Active tab index for details vs price breakup toggle (0 = Product Details, 1 = Price Breakup)
  final RxInt selectedDetailTab = 0.obs;

  // Description expansion state ("Read More" / "Read Less")
  final RxBool isDescriptionExpanded = false.obs;

  // Wishlist toggle state
  final RxBool isWishlisted = false.obs;

  // Product data passed to the screen, or a rich fallback default product
  final RxMap<String, dynamic> product = <String, dynamic>{}.obs;

  // Available product photos
  final RxList<String> productImages = <String>[].obs;

  // Dummy related products data for recommendations
  final RxList<Map<String, dynamic>> relatedProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Fetch arguments if passed during navigation
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> args = Map<String, dynamic>.from(Get.arguments as Map<String, dynamic>);
      
      final String? id = args['id'] ?? args['_id'];
      if (id != null && id.isNotEmpty) {
        fetchProductDetails(id);
      } else {
        // Fallback to arguments mapping directly
        _applyLocalArgs(args);
        isLoading.value = false;
      }
    } else {
      // Fallback to high-quality default product if opened directly or without arguments
      _applyDefaultFallback();
      isLoading.value = false;
    }

    // Initialize mock related products
    relatedProducts.assignAll([
      {
        'name': '22K Gold Antique Necklace',
        'price': '₹1,65,000',
        'originalPrice': '₹1,80,000',
        'weight': '16.5g',
        'karat': '22K',
        'image': 'assets/temp/demo_2.jpeg',
        'rating': 4.8,
        'reviews': 94,
        'isWishlisted': false,
        'badge': 'ANTIQUE',
      },
      {
        'name': 'Kundan Floral Gold Necklace',
        'price': '₹1,45,000',
        'originalPrice': '₹1,60,000',
        'weight': '14.8g',
        'karat': '22K',
        'image': 'assets/temp/demo_3.jpeg',
        'rating': 4.7,
        'reviews': 63,
        'isWishlisted': false,
        'badge': 'TRENDING',
      },
      {
        'name': 'Classic Royal Gold Choker',
        'price': '₹1,75,000',
        'originalPrice': '₹1,95,000',
        'weight': '17.9g',
        'karat': '22K',
        'image': 'assets/temp/demo_4.jpeg',
        'rating': 4.9,
        'reviews': 112,
        'isWishlisted': false,
        'badge': 'ROYAL',
      },
      {
        'name': 'Bridal Gold Necklace Set',
        'price': '₹1,35,000',
        'originalPrice': '₹1,50,000',
        'weight': '13.2g',
        'karat': '22K',
        'image': 'assets/temp/demo_5.jpeg',
        'rating': 4.6,
        'reviews': 47,
        'isWishlisted': false,
        'badge': 'NEW',
      },
    ]);
  }

  void _applyLocalArgs(Map<String, dynamic> args) {
    args['category'] ??= 'Necklace';
    args['collection'] ??= 'Royal Collection';
    args['purity'] ??= '${args['karat'] ?? '22K'} (916)';
    args['metal'] ??= 'Gold';
    args['color'] ??= 'Yellow Gold';
    args['occasion'] ??= 'Wedding';
    args['hallmark'] ??= 'BIS Certified';
    args['makingCharges'] ??= 'Included';
    args['gst'] ??= 'Included';
    args['description'] ??= 'A timeless masterpiece that reflects royalty and grace. Designed in ${args['karat'] ?? '22K'} gold with fine detailing and a weight of ${args['weight'] ?? '18.45 gm'}, this piece adds a touch of elegance to your special moments. Crafted by master artisans, it features delicate carvings and premium finishing, making it the perfect heirloom piece.';

    product.assignAll(args);
    
    final WishlistController wishlistController = Get.find<WishlistController>();
    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';
    isWishlisted.value = wishlistController.isProductWishlisted(product['name'] ?? '', id: id);

    productImages.assignAll(
      List.generate(10, (index) => 'assets/temp/demo_${index + 1}.jpeg'),
    );
    if (product['image'] != null) {
      final int imgIndex = productImages.indexOf(product['image'] as String);
      if (imgIndex != -1) {
        currentImageIndex.value = imgIndex;
      }
    }
  }

  void _applyDefaultFallback() {
    product.assignAll({
      'name': '',
      'category': '',
      'collection': '',
      'price': '',
      'originalPrice': '',
      'weight': '',
      'karat': '',
      'purity': '',
      'metal': '',
      'color': '',
      'occasion': '',
      'hallmark': '',
      'makingCharges': '',
      'gst': '',
      'badge': '',
      'description': '',
    });

    final WishlistController wishlistController = Get.find<WishlistController>();
    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';
    isWishlisted.value = wishlistController.isProductWishlisted(product['name'] ?? '', id: id);

    productImages.assignAll(
      List.generate(10, (index) => 'assets/temp/demo_${index + 1}.jpeg'),
    );
  }

  Future<void> fetchProductDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _homeApiService.getProductDetail(productId: id);
      final mapped = response.data.toUiMap();

      product.assignAll(mapped);

      if (response.data.images.isNotEmpty) {
        productImages.assignAll(response.data.images);
      } else {
        productImages.assignAll([mapped['image'] ?? 'assets/temp/demo_1.jpeg']);
      }

      currentImageIndex.value = 0;

      final WishlistController wishlistController = Get.find<WishlistController>();
      isWishlisted.value = wishlistController.isProductWishlisted(product['name'] ?? '', id: id);

      // Fetch related products from API
      try {
        final relatedResponse = await _homeApiService.getRelatedProducts(productId: id);
        final List<Map<String, dynamic>> mappedRelated =
            relatedResponse.data.map((item) => item.toUiMap()).toList();
        relatedProducts.assignAll(mappedRelated);
      } catch (e) {
        OtherMethods.customLog("[ProductDetailsController] Error loading related products: $e");
        // Maintain the mock list as a fallback if API fails
      }

    } catch (e) {
      OtherMethods.customLog("[ProductDetailsController] Error loading details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle wishlist state in the centralized WishlistController
  Future<void> toggleWishlist() async {
    final WishlistController wishlistController = Get.find<WishlistController>();
    
    // Optimistic toggle locally for instant feedback
    isWishlisted.value = !isWishlisted.value;

    await wishlistController.toggleWishlist(product);

    // Re-verify against controller state
    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';
    isWishlisted.value = wishlistController.isProductWishlisted(product['name'] ?? '', id: id);
  }

  // Toggle description read more state
  void toggleDescription() {
    isDescriptionExpanded.toggle();
  }

  // Change currently selected image
  void selectImage(int index) {
    if (index >= 0 && index < productImages.length) {
      currentImageIndex.value = index;
    }
  }

  // ── Booking loading state & API integration ────────────────────────────────
  final RxBool isBookingLoading = false.obs;

  Future<bool> bookVisit({
    required String preferredDate,
    required String preferredTime,
    required String purposeOfVisit,
    required String estimatedBudget,
    required String productId,
    required String additionalRequirements,
  }) async {
    try {
      isBookingLoading.value = true;
      final api = ProfileApiService();
      await api.bookAppointment(
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        purposeOfVisit: purposeOfVisit,
        estimatedBudget: estimatedBudget,
        productId: productId,
        additionalRequirements: additionalRequirements,
      );

      // Refresh profile appointment list if controller exists
      try {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchAppointments();
        }
      } catch (_) {}

      return true;
    } catch (e) {
      Get.snackbar(
        "Booking Failed",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBookingLoading.value = false;
    }
  }

  // ── Booking Sheet State Variables ──────────────────────────────────────────
  final bookingDate = Rx<DateTime>(DateTime.now());
  final bookingSlot = 'Morning (10 AM - 1 PM)'.obs;
  final isCustomDate = false.obs;
  final isCustomTime = false.obs;
  final customTimeVal = const TimeOfDay(hour: 12, minute: 0).obs;
  final selectedPurpose = 'Buying Jewelry'.obs;
  final selectedBudget = '₹50,000 - ₹1,00,000'.obs;
  final bookingMessageController = TextEditingController();

  void resetBookingState() {
    bookingDate.value = DateTime.now();
    bookingSlot.value = 'Morning (10 AM - 1 PM)';
    isCustomDate.value = false;
    isCustomTime.value = false;
    customTimeVal.value = const TimeOfDay(hour: 12, minute: 0);
    selectedPurpose.value = 'Buying Jewelry';
    selectedBudget.value = '₹50,000 - ₹1,00,000';
    bookingMessageController.clear();
  }

  @override
  void onClose() {
    bookingMessageController.dispose();
    super.onClose();
  }
}
