import 'package:get/get.dart';
import '../../model/home/banner_model.dart';
import '../../model/home/home_category_model.dart';
import '../../model/home/trending_model.dart';
import '../../model/home/styling_model.dart';
import '../../model/home/product_model.dart';
import '../../model/home/showcase_collection_model.dart';
import '../../services/home_api_services.dart';
import '../../utils/other_methods.dart';

class HomeController extends GetxController {
  final HomeApiService _homeApiService = HomeApiService();

  // ── Showcase Collections
  final RxBool isShowcaseLoading = true.obs;
  final RxList<ShowcaseCollection> showcaseList = <ShowcaseCollection>[].obs;

  // ── Banner Slider
  final RxInt currentBannerIndex = 0.obs;
  final RxBool isBannersLoading = true.obs;
  final RxList<BannerDataModel> bannersList = <BannerDataModel>[].obs;

  // ── Categories Slider
  final RxBool isCategoriesLoading = true.obs;
  final RxList<HomeCategoryModel> categoriesList = <HomeCategoryModel>[].obs;

  // ── Trending Collections
  final RxBool isTrendingLoading = true.obs;
  final RxList<TrendingDataModel> trendingList = <TrendingDataModel>[].obs;

  // ── Instagram Reels (Styling)
  final RxBool isStylingLoading = true.obs;
  final RxList<StylingDataModel> stylingReelsList = <StylingDataModel>[].obs;

  // ── Dynamic Products Lists (Featured, New Arrivals, Best Sellers)
  final RxBool isFeaturedLoading = true.obs;
  final RxList<ProductDataModel> featuredList = <ProductDataModel>[].obs;

  final RxBool isNewArrivalsLoading = true.obs;
  final RxList<ProductDataModel> newArrivalsList = <ProductDataModel>[].obs;

  final RxBool isBestSellersLoading = true.obs;
  final RxList<ProductDataModel> bestSellersList = <ProductDataModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchCategories();
    fetchTrending();
    fetchStylingReels();
    fetchFeaturedProducts();
    fetchNewArrivalsProducts();
    fetchBestSellersProducts();
    fetchShowcaseCollections();
  }

  Future<void> fetchBanners() async {
    try {
      isBannersLoading.value = true;
      final response = await _homeApiService.getBanners();
      bannersList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load banners: $e");
    } finally {
      isBannersLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await _homeApiService.getCategories();
      categoriesList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchTrending() async {
    try {
      isTrendingLoading.value = true;
      final response = await _homeApiService.getTrending();
      trendingList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load trending items: $e");
    } finally {
      isTrendingLoading.value = false;
    }
  }

  Future<void> fetchStylingReels() async {
    try {
      isStylingLoading.value = true;
      final response = await _homeApiService.getStylingReels();
      stylingReelsList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load styling reels: $e");
    } finally {
      isStylingLoading.value = false;
    }
  }

  // Gold Rates
  final RxBool isGoldRatesExpanded = false.obs;


  // TODO Simulated 7-day chart data (gold price in hundreds)

  void toggleGoldRates() => isGoldRatesExpanded.toggle();


  //  Wishlist
  final RxSet<int> wishlistedItems = <int>{}.obs;

  void toggleWishlist(int index) {
    if (wishlistedItems.contains(index)) {
      wishlistedItems.remove(index);
    } else {
      wishlistedItems.add(index);
    }
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      isFeaturedLoading.value = true;
      final response = await _homeApiService.getProductsByTag(tag: 'featured');
      featuredList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load featured products: $e");
    } finally {
      isFeaturedLoading.value = false;
    }
  }

  Future<void> fetchNewArrivalsProducts() async {
    try {
      isNewArrivalsLoading.value = true;
      final response = await _homeApiService.getProductsByTag(tag: 'new arrivals');
      newArrivalsList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load new arrivals products: $e");
    } finally {
      isNewArrivalsLoading.value = false;
    }
  }

  Future<void> fetchBestSellersProducts() async {
    try {
      isBestSellersLoading.value = true;
      final response = await _homeApiService.getProductsByTag(tag: 'best sellers');
      bestSellersList.assignAll(response.data);
    } catch (e) {
      OtherMethods.customLog("❌ [HomeController] Failed to load best sellers products: $e");
    } finally {
      isBestSellersLoading.value = false;
    }
  }

  Future<void> fetchShowcaseCollections() async {
    try {
      isShowcaseLoading.value = true;
      final response = await _homeApiService.getShowcaseCollections();
      showcaseList.assignAll(response);
    } catch (e) {
      OtherMethods.customLog("[HomeController] Failed to load showcase collections: $e");
    } finally {
      isShowcaseLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    await Future.wait([
      fetchBanners(),
      fetchCategories(),
      fetchTrending(),
      fetchStylingReels(),
      fetchFeaturedProducts(),
      fetchNewArrivalsProducts(),
      fetchBestSellersProducts(),
      fetchShowcaseCollections(),
    ]);
  }
}
