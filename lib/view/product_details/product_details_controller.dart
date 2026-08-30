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
      _applyDefaultFallback();
      isLoading.value = false;
    }
  }

  void _applyLocalArgs(Map<String, dynamic> args) {
    product.assignAll(args);
    
    try {
      if (Get.isRegistered<WishlistController>()) {
        final WishlistController wishlistController = Get.find<WishlistController>();
        final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';
        isWishlisted.value = wishlistController.isProductWishlisted(product['name']?.toString() ?? '', id: id);
      }
    } catch (_) {}

    if (args['images'] != null && args['images'] is List && (args['images'] as List).isNotEmpty) {
      productImages.assignAll((args['images'] as List).map((e) => e.toString()).toList());
    } else if (args['image'] != null && args['image'].toString().isNotEmpty) {
      productImages.assignAll([args['image'].toString()]);
    } else {
      productImages.clear();
    }

    if (product['image'] != null && productImages.isNotEmpty) {
      final int imgIndex = productImages.indexOf(product['image'] as String);
      if (imgIndex != -1) {
        currentImageIndex.value = imgIndex;
      }
    }
  }

  void _applyDefaultFallback() {
    product.clear();
    productImages.clear();
    relatedProducts.clear();
    isWishlisted.value = false;
  }

  Future<void> fetchProductDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _homeApiService.getProductDetail(productId: id);
      final mapped = response.data.toUiMap();

      product.assignAll(mapped);

      if (response.data.images.isNotEmpty) {
        productImages.assignAll(response.data.images);
      } else if (mapped['image'] != null && mapped['image'].toString().isNotEmpty) {
        productImages.assignAll([mapped['image'].toString()]);
      } else {
        productImages.clear();
      }

      currentImageIndex.value = 0;

      try {
        if (Get.isRegistered<WishlistController>()) {
          final WishlistController wishlistController = Get.find<WishlistController>();
          isWishlisted.value = wishlistController.isProductWishlisted(product['name']?.toString() ?? '', id: id);
        }
      } catch (_) {}

      // Fetch related products from API
      try {
        final relatedResponse = await _homeApiService.getRelatedProducts(productId: id);
        final List<Map<String, dynamic>> mappedRelated =
            relatedResponse.data.map((item) => item.toUiMap()).toList();
        relatedProducts.assignAll(mappedRelated);
      } catch (e) {
        OtherMethods.customLog("[ProductDetailsController] Error loading related products: $e");
        relatedProducts.clear();
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
