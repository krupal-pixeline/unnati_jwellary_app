import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/home/product_model.dart';
import '../../services/base_api_services.dart';
import '../../utils/app_urls.dart';

class SearchProductController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> productsList = <Map<String, dynamic>>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // Automatically trigger search when query changes, with 500ms debounce
    debounce(searchQuery, (_) {
      fetchSearchProducts(isAppend: false);
    }, time: const Duration(milliseconds: 500));

    // Automatically trigger search when gender selection changes
    ever(selectedGender, (_) {
      fetchSearchProducts(isAppend: false);
    });
  }

  Future<void> fetchSearchProducts({bool isAppend = false}) async {
    // If no query and no gender is selected, empty the results and stop
    if (searchQuery.value.trim().isEmpty && selectedGender.value.isEmpty) {
      productsList.clear();
      currentPage.value = 1;
      totalPages.value = 1;
      return;
    }

    // Stop if appending and already at the last page
    if (isAppend && currentPage.value >= totalPages.value) {
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

      if (searchQuery.value.trim().isNotEmpty) {
        params['search'] = searchQuery.value.trim();
      }

      if (selectedGender.value.isNotEmpty && selectedGender.value != 'All') {
        params['gender'] = selectedGender.value;
      }

      final responseJson = await BaseApiService().getRequest(
        url: AppUrls.products,
        queryParams: params,
        apiName: 'SEARCH_PRODUCTS_API',
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
          productsList.addAll(fetchedList);
        } else {
          productsList.assignAll(fetchedList);
        }
      } else {
        if (!isAppend) {
          productsList.clear();
        }
      }
    } catch (e) {
      debugPrint("❌ [SearchProductController] Error searching products: $e");
      if (!isAppend) {
        productsList.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resetSearch() {
    searchQuery.value = '';
    selectedGender.value = '';
    productsList.clear();
    currentPage.value = 1;
    totalPages.value = 1;
  }
}
