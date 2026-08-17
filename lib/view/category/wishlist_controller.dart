import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_urls.dart';
import '../../utils/app_key_names.dart';
import '../../utils/other_methods.dart';
import '../../services/base_api_services.dart';

class WishlistController extends GetxController {
  // Central wishlist storage of products (as maps)
  final RxList<Map<String, dynamic>> wishlistedProducts = <Map<String, dynamic>>[].obs;
  
  // Search text query
  final RxString searchQuery = ''.obs;

  // Filtered list based on search query
  final RxList<Map<String, dynamic>> filteredProducts = <Map<String, dynamic>>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  final BaseApiService _baseApi = BaseApiService();

  @override
  void onInit() {
    super.onInit();
    
    // Set up filtered products listener
    filteredProducts.assignAll(wishlistedProducts);
    
    // Bind search and filter changes
    ever(wishlistedProducts, (_) => filterWishlist(searchQuery.value));
    ever(searchQuery, (query) => filterWishlist(query));

    // Fetch wishlist from API on init
    fetchWishlist();
  }

  Map<String, dynamic>? _getAuthHeaders() {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    if (token != null && token.toString().isNotEmpty) {
      return {
        'Authorization': 'Bearer $token',
      };
    }
    return null;
  }

  Future<void> fetchWishlist() async {
    final headers = _getAuthHeaders();
    if (headers == null) {
      // User not logged in, clear wishlist
      wishlistedProducts.clear();
      return;
    }

    try {
      isLoading.value = true;
      update();

      final response = await _baseApi.getRequest(
        url: AppUrls.wishlist,
        extraHeaders: headers,
        apiName: 'GET_WISHLIST',
      );

      if (response['success'] == true) {
        final List list = response['data'] as List? ?? [];
        final List<Map<String, dynamic>> parsed = [];
        
        for (var item in list) {
          Map<String, dynamic> prodMap = {};
          if (item is Map) {
            if (item.containsKey('product') && item['product'] is Map) {
              prodMap = Map<String, dynamic>.from(item['product'] as Map);
            } else {
              prodMap = Map<String, dynamic>.from(item);
            }
          }

          final id = prodMap['_id']?.toString() ?? prodMap['id']?.toString() ?? '';
          if (id.isEmpty) continue;

          final name = prodMap['productName']?.toString() ?? prodMap['name']?.toString() ?? 'Gold Jewelry';
          final calculatedPrice = prodMap['calculatedPrice']?.toString() ?? prodMap['price']?.toString() ?? '0';
          
          final weightVal = prodMap['weight'];
          final weight = weightVal != null ? '$weightVal gm' : '';
          final karat = prodMap['purity']?.toString() ?? prodMap['karat']?.toString() ?? '';
          
          final imagesList = prodMap['images'] as List? ?? [];
          final image = imagesList.isNotEmpty ? imagesList[0].toString() : (prodMap['image']?.toString() ?? '');

          final uiProduct = Map<String, dynamic>.from(prodMap);
          uiProduct.addAll({
            'id': id,
            '_id': id,
            'name': name,
            'price': calculatedPrice.startsWith('₹') ? calculatedPrice : '₹$calculatedPrice',
            'weight': weight,
            'karat': karat,
            'purity': karat,
            'image': image,
            'badge': (prodMap['tags'] as List? ?? []).isNotEmpty 
                ? (prodMap['tags'] as List)[0].toString().toUpperCase() 
                : (prodMap['badge']?.toString() ?? ''),
          });
          parsed.add(uiProduct);
        }

        wishlistedProducts.assignAll(parsed);
      }
    } catch (e) {
      debugPrint("❌ [WishlistController] Error fetching wishlist: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> toggleWishlist(Map<String, dynamic> product) async {
    final headers = _getAuthHeaders();
    if (headers == null) {
      Get.snackbar(
        'Login Required',
        'Please login to manage your wishlist.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final id = product['id']?.toString() ?? product['_id']?.toString() ?? '';
    final name = product['name']?.toString() ?? '';

    if (id.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid product ID.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final isAlreadyWishlisted = isProductWishlisted(name, id: id);

    try {
      if (isAlreadyWishlisted) {
        // Optimistically remove from list
        wishlistedProducts.removeWhere((p) {
          final pId = p['id']?.toString() ?? p['_id']?.toString() ?? '';
          return pId == id || p['name'] == name;
        });
        update();

        // Call DELETE API
        final response = await _baseApi.deleteRequest(
          url: '${AppUrls.wishlist}/$id',
          extraHeaders: headers,
          apiName: 'DELETE_WISHLIST_ITEM',
        );

        if (response['success'] != true) {
          // Re-fetch wishlist on failure to sync
          await fetchWishlist();
        }
      } else {
        // Optimistically add to list
        final uiProduct = Map<String, dynamic>.from(product);
        uiProduct.addAll({
          'id': id,
          '_id': id,
        });
        wishlistedProducts.add(uiProduct);
        update();

        // Call POST API
        final response = await _baseApi.postRequest(
          url: AppUrls.wishlist,
          body: {'productId': id},
          extraHeaders: headers,
          apiName: 'ADD_WISHLIST_ITEM',
        );

        if (response['success'] != true) {
          // Rollback on failure by fetching again
          await fetchWishlist();
        }
      }
    } catch (e) {
      debugPrint("❌ [WishlistController] Error toggling wishlist: $e");
      // Re-fetch wishlist to ensure UI is in sync with backend
      await fetchWishlist();
    }
  }

  bool isProductWishlisted(String productName, {String? id}) {
    return wishlistedProducts.any((p) {
      if (id != null && id.isNotEmpty) {
        final pId = p['id']?.toString() ?? p['_id']?.toString() ?? '';
        if (pId == id) return true;
      }
      return p['name'] == productName;
    });
  }

  void filterWishlist(String query) {
    if (query.trim().isEmpty) {
      filteredProducts.assignAll(wishlistedProducts);
    } else {
      final q = query.trim().toLowerCase();
      filteredProducts.assignAll(
        wishlistedProducts.where((p) {
          final name = (p['name'] ?? '').toString().toLowerCase();
          final category = (p['category'] ?? '').toString().toLowerCase();
          final collection = (p['collection'] ?? '').toString().toLowerCase();
          return name.contains(q) || category.contains(q) || collection.contains(q);
        }).toList()
      );
    }
  }
}
