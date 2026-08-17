import '../model/home/showcase_collection_model.dart';
import '../model/home/banner_model.dart';
import '../model/home/home_category_model.dart';
import '../model/home/product_model.dart';
import '../model/home/subcategory_model.dart';
import '../model/home/styling_model.dart';
import '../model/home/trending_model.dart';
import '../utils/app_urls.dart';
import '../utils/other_methods.dart';
import 'base_api_services.dart';

class HomeApiService {
  static final HomeApiService _instance = HomeApiService._internal();

  factory HomeApiService() => _instance;

  HomeApiService._internal();

  final BaseApiService _baseApi = BaseApiService();

  // =====================================================================
  //  Get Banners  –  GET /cms/banners?active=true
  // =====================================================================
  Future<BannerResponseModel> getBanners() async {
    const String apiName = 'HOME_BANNERS';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching home screen banners...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: AppUrls.banners,
        apiName: apiName,
      );

      final BannerResponseModel model = BannerResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} banners.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Categories  –  GET /categories
  // =====================================================================
  Future<HomeCategoryResponseModel> getCategories() async {
    const String apiName = 'HOME_CATEGORIES';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching categories...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: AppUrls.categories,
        apiName: apiName,
      );

      final HomeCategoryResponseModel model = HomeCategoryResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} categories.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Trending  –  GET /cms/trending
  // =====================================================================
  Future<TrendingResponseModel> getTrending() async {
    const String apiName = 'HOME_TRENDING';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching trending items...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: AppUrls.trending,
        apiName: apiName,
      );

      final TrendingResponseModel model = TrendingResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} trending items.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Styling Reels  –  GET /cms/styling
  // =====================================================================
  Future<StylingResponseModel> getStylingReels() async {
    const String apiName = 'HOME_STYLING';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching styling reels...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: AppUrls.styling,
        apiName: apiName,
      );

      final StylingResponseModel model = StylingResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} styling reels.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Products By Tag  –  GET /products?tag=<tag>
  // =====================================================================
  Future<ProductResponseModel> getProductsByTag({required String tag}) async {
    final String apiName = 'PRODUCTS_${tag.replaceAll(' ', '_').toUpperCase()}';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching products with tag: $tag...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: AppUrls.products,
        queryParams: {'tag': tag},
        apiName: apiName,
      );

      final ProductResponseModel model = ProductResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} products.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Sub Categories by Parent Category ID
  // =====================================================================
  Future<SubCategoryResponseModel> getSubCategories({required String categoryId}) async {
    final String apiName = 'SUBCATEGORIES_$categoryId';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching subcategories for category: $categoryId...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: '${AppUrls.subCategoriesByCategory}$categoryId',
        apiName: apiName,
      );

      final SubCategoryResponseModel model = SubCategoryResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} subcategories.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Single Product Details by Product ID
  // =====================================================================
  Future<ProductDetailResponseModel> getProductDetail({required String productId}) async {
    final String apiName = 'PRODUCT_DETAIL_$productId';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching product details for ID: $productId...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: '${AppUrls.productDetail}$productId',
        apiName: apiName,
      );

      final ProductDetailResponseModel model = ProductDetailResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved product details.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Related Products by Product ID
  // =====================================================================
  Future<ProductResponseModel> getRelatedProducts({required String productId, int limit = 20}) async {
    final String apiName = 'RELATED_PRODUCTS_$productId';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching related products for ID: $productId...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: '${AppUrls.productDetail}$productId/related',
        queryParams: {'limit': limit.toString()},
        apiName: apiName,
      );

      final ProductResponseModel model = ProductResponseModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${model.data.length} related products.');

      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  // =====================================================================
  //  Get Showcase Collections  –  GET /collections/showcase/active
  // =====================================================================
  Future<List<ShowcaseCollection>> getShowcaseCollections() async {
    const String apiName = 'SHOWCASE_COLLECTIONS';

    try {
      OtherMethods.customLog('🌐 [$apiName] Fetching showcase collections...');

      final Map<String, dynamic> responseJson = await _baseApi.getRequest(
        url: '${AppUrls.baseUrl}collections/showcase/active',
        apiName: apiName,
      );

      final List list = responseJson['data'] as List? ?? [];
      final List<ShowcaseCollection> collections = list
          .map((item) => ShowcaseCollection.fromJsonList(item as List))
          .toList();

      OtherMethods.customLog('✅ [$apiName] Success: Retrieved ${collections.length} showcase collections.');

      return collections;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }
}
