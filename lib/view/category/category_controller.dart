// category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jewelry_category_model.dart';
import '../../services/home_api_services.dart';
import '../../model/home/subcategory_model.dart';
import '../../utils/other_methods.dart';

class CategoryController extends GetxController {
  final HomeApiService _homeApiService = HomeApiService();
  final RxBool isCategoriesLoading = true.obs;

  // Dynamic Map of Subcategories and their loading states
  final RxMap<String, List<SubCategoryDataModel>> subCategoriesMap = <String, List<SubCategoryDataModel>>{}.obs;
  final RxMap<String, bool> subCategoriesLoadingMap = <String, bool>{}.obs;

  // ── Text Controller ────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();

  // ── Observables ────────────────────────────────────────────────────────
  final RxString searchQuery    = ''.obs;
  final RxString selectedSort   = 'Featured'.obs;
  final RxBool   isGridView     = true.obs;
  final RxBool   isSearchFocused = false.obs;

  // ── Filter Options ─────────────────────────────────────────────────────
  final RxList<FilterOption> materialFilters = <FilterOption>[
    FilterOption(id: 'gold',     label: '22K Gold'),
    FilterOption(id: '18k',      label: '18K Gold'),
    FilterOption(id: 'diamond',  label: 'Diamond'),
    FilterOption(id: 'platinum', label: 'Platinum'),
    FilterOption(id: 'silver',   label: 'Silver'),
    FilterOption(id: 'pearl',    label: 'Pearl'),
    FilterOption(id: 'rosegold', label: 'Rose Gold'),
  ].obs;

  // ── Sort Options ───────────────────────────────────────────────────────
  final List<String> sortOptions = const [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Most Popular',
    'Newest',
  ];

  // ── Master Data ────────────────────────────────────────────────────────
  final List<JewelryCategory> _allCategories = [
    JewelryCategory(
      id: '1',
      name: 'Necklaces',
      subtitle: 'Timeless elegance',
      imagePath: 'assets/temp/demo_1.jpeg',
      productCount: 128,
      tags: ['gold', 'diamond', 'pearl'],
      isFeatured: true,
      startingPrice: 12500,
      subCategories: [
        JewelrySubCategory(
          id: '1_1',
          name: 'Choker Necklaces',
          subtitle: 'Close-fitting necklaces',
          imagePath: 'assets/temp/demo_1.jpeg',
          products: [
            {
              'name': '22K Gold Antique Choker',
              'category': 'Necklaces',
              'collection': 'Antique Collection',
              'price': '₹1,25,000',
              'originalPrice': '₹1,35,000',
              'weight': '14.50 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Festive',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_1.jpeg',
              'badge': 'ANTIQUE',
            },
            {
              'name': 'Royal Pearl Kundan Choker',
              'category': 'Necklaces',
              'collection': 'Royal Collection',
              'price': '₹1,95,000',
              'originalPrice': '₹2,10,000',
              'weight': '22.10 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Wedding',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_2.jpeg',
              'badge': 'ROYAL',
            },
            {
              'name': 'Diamond Eternity Choker',
              'category': 'Necklaces',
              'collection': 'Eternity Collection',
              'price': '₹2,45,000',
              'originalPrice': '₹2,70,000',
              'weight': '16.80 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Gold',
              'color': 'White Gold',
              'occasion': 'Festive',
              'hallmark': 'IGI Certified',
              'image': 'assets/temp/demo_3.jpeg',
              'badge': 'TRENDING',
            },
          ],
        ),
        JewelrySubCategory(
          id: '1_2',
          name: 'Bridal Necklaces',
          subtitle: 'Grandeur for your special day',
          imagePath: 'assets/temp/demo_3.jpeg',
          products: [
            {
              'name': 'Heritage Gold Bridal Haram',
              'category': 'Necklaces',
              'collection': 'Heritage Collection',
              'price': '₹3,45,000',
              'originalPrice': '₹3,75,000',
              'weight': '42.30 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Wedding',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_3.jpeg',
              'badge': 'HERITAGE',
            },
            {
              'name': 'Classic Pearl Opera Necklace',
              'category': 'Necklaces',
              'collection': 'Pearl Collection',
              'price': '₹65,000',
              'originalPrice': '₹72,000',
              'weight': '24.00 gm',
              'karat': 'Pearl',
              'purity': 'Natural Pearls',
              'metal': 'Pearl',
              'color': 'White',
              'occasion': 'Casual',
              'hallmark': 'GIA Certified',
              'image': 'assets/temp/demo_1.jpeg',
              'badge': 'ELEGANT',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '2',
      name: 'Rings',
      subtitle: 'Crafted to last forever',
      imagePath: 'assets/temp/demo_2.jpeg',
      productCount: 214,
      tags: ['gold', '18k', 'diamond', 'platinum'],
      isFeatured: true,
      startingPrice: 8999,
      subCategories: [
        JewelrySubCategory(
          id: '2_1',
          name: 'Engagement Rings',
          subtitle: 'Seal your love forever',
          imagePath: 'assets/temp/demo_4.jpeg',
          products: [
            {
              'name': 'Classic Solitaire Diamond Ring',
              'category': 'Rings',
              'collection': 'Solitaire Collection',
              'price': '₹85,000',
              'originalPrice': '₹95,000',
              'weight': '3.20 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Platinum',
              'color': 'White Gold',
              'occasion': 'Engagement',
              'hallmark': 'IGI Certified',
              'image': 'assets/temp/demo_4.jpeg',
              'badge': 'SOLITAIRE',
            },
            {
              'name': 'Rose Gold Promise Ring',
              'category': 'Rings',
              'collection': 'Promise Collection',
              'price': '₹28,000',
              'originalPrice': '₹32,000',
              'weight': '2.40 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Gold',
              'color': 'Rose Gold',
              'occasion': 'Engagement',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_5.jpeg',
              'badge': 'NEW',
            },
            {
              'name': 'Platinum Band Ring',
              'category': 'Rings',
              'collection': 'Minimalist Collection',
              'price': '₹35,000',
              'originalPrice': '₹40,000',
              'weight': '4.80 gm',
              'karat': 'Platinum',
              'purity': '950 Platinum',
              'metal': 'Platinum',
              'color': 'Platinum',
              'occasion': 'Engagement',
              'hallmark': 'PT950 Certified',
              'image': 'assets/temp/demo_2.jpeg',
              'badge': 'MINIMALIST',
            },
          ],
        ),
        JewelrySubCategory(
          id: '2_2',
          name: 'Cocktail Rings',
          subtitle: 'Make a bold statement',
          imagePath: 'assets/temp/demo_5.jpeg',
          products: [
            {
              'name': 'Vintage Floral Gold Ring',
              'category': 'Rings',
              'collection': 'Vintage Collection',
              'price': '₹42,000',
              'originalPrice': '₹47,000',
              'weight': '6.45 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Party',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_5.jpeg',
              'badge': 'BESTSELLER',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '3',
      name: 'Earrings',
      subtitle: 'Statement & subtle',
      imagePath: 'assets/temp/demo_3.jpeg',
      productCount: 176,
      tags: ['gold', 'rosegold', 'pearl', 'silver'],
      startingPrice: 3500,
      subCategories: [
        JewelrySubCategory(
          id: '3_1',
          name: 'Gold Jhumkas',
          subtitle: 'Traditional bell earrings',
          imagePath: 'assets/temp/demo_6.jpeg',
          products: [
            {
              'name': 'Traditional Peacock Jhumka',
              'category': 'Earrings',
              'collection': 'Traditional Collection',
              'price': '₹55,000',
              'originalPrice': '₹60,000',
              'weight': '8.20 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Festive',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_6.jpeg',
              'badge': 'POPULAR',
            },
            {
              'name': 'Solitaire Diamond Studs',
              'category': 'Earrings',
              'collection': 'Solitaire Collection',
              'price': '₹1,10,000',
              'originalPrice': '₹1,25,000',
              'weight': '1.90 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Gold',
              'color': 'White Gold',
              'occasion': 'Daily Wear',
              'hallmark': 'IGI Certified',
              'image': 'assets/temp/demo_4.jpeg',
              'badge': 'PREMIUM',
            },
            {
              'name': 'Rose Gold Hoop Earrings',
              'category': 'Earrings',
              'collection': 'Hoops Collection',
              'price': '₹18,500',
              'originalPrice': '₹21,000',
              'weight': '3.10 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Gold',
              'color': 'Rose Gold',
              'occasion': 'Casual',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_6.jpeg',
              'badge': 'CASUAL',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '4',
      name: 'Bangles',
      subtitle: 'Traditional grandeur',
      imagePath: 'assets/temp/demo_4.jpeg',
      productCount: 92,
      tags: ['gold', '22K', 'silver'],
      isFeatured: true,
      startingPrice: 18000,
      subCategories: [
        JewelrySubCategory(
          id: '4_1',
          name: 'Broad Kada Bangles',
          subtitle: 'Stunning wrist wear',
          imagePath: 'assets/temp/demo_7.jpeg',
          products: [
            {
              'name': 'Antique Carved Kada',
              'category': 'Bangles',
              'collection': 'Antique Collection',
              'price': '₹1,20,000',
              'originalPrice': '₹1,32,000',
              'weight': '18.10 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Wedding',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_7.jpeg',
              'badge': 'EXCLUSIVE',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '5',
      name: 'Bracelets',
      subtitle: 'Delicate & luxurious',
      imagePath: 'assets/temp/demo_5.jpeg',
      productCount: 108,
      tags: ['gold', 'diamond', 'silver', 'platinum'],
      startingPrice: 6800,
      subCategories: [
        JewelrySubCategory(
          id: '5_1',
          name: 'Chain Bracelets',
          subtitle: 'Delicate wrist bands',
          imagePath: 'assets/temp/demo_8.jpeg',
          products: [
            {
              'name': 'Dainty Gold Chain Bracelet',
              'category': 'Bracelets',
              'collection': 'Dainty Collection',
              'price': '₹24,500',
              'originalPrice': '₹27,000',
              'weight': '3.80 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Casual',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_8.jpeg',
              'badge': 'NEW',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '6',
      name: 'Pendants',
      subtitle: 'Symbols of love',
      imagePath: 'assets/temp/demo_6.jpeg',
      productCount: 143,
      tags: ['gold', 'diamond', 'pearl'],
      startingPrice: 4200,
      subCategories: [
        JewelrySubCategory(
          id: '6_1',
          name: 'Religious Pendants',
          subtitle: 'Devotional charms',
          imagePath: 'assets/temp/demo_9.jpeg',
          products: [
            {
              'name': 'Ganesha Gold Pendant',
              'category': 'Pendants',
              'collection': 'Divine Collection',
              'price': '₹15,000',
              'originalPrice': '₹17,000',
              'weight': '2.10 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Daily Wear',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_9.jpeg',
              'badge': 'DIVINE',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '7',
      name: 'Anklets',
      subtitle: 'Grace in every step',
      imagePath: 'assets/temp/demo_7.jpeg',
      productCount: 56,
      tags: ['gold', 'silver'],
      startingPrice: 2900,
      subCategories: [
        JewelrySubCategory(
          id: '7_1',
          name: 'Silver Payal',
          subtitle: 'Traditional anklets',
          imagePath: 'assets/temp/demo_10.jpeg',
          products: [
            {
              'name': 'Sterling Silver Pajeb',
              'category': 'Anklets',
              'collection': 'Silver Collection',
              'price': '₹4,500',
              'originalPrice': '₹5,000',
              'weight': '45.00 gm',
              'karat': 'Silver',
              'purity': '925 Sterling Silver',
              'metal': 'Silver',
              'color': 'Silver',
              'occasion': 'Festive',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_10.jpeg',
              'badge': 'SILVER',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '8',
      name: 'Mangalsutra',
      subtitle: 'Sacred & stunning',
      imagePath: 'assets/temp/demo_8.jpeg',
      productCount: 74,
      tags: ['gold', 'diamond', '22K'],
      isFeatured: true,
      startingPrice: 22000,
      subCategories: [
        JewelrySubCategory(
          id: '8_1',
          name: 'Modern Short Mangalsutra',
          subtitle: 'Sleek designs',
          imagePath: 'assets/temp/demo_1.jpeg',
          products: [
            {
              'name': 'Dainty Diamond Mangalsutra',
              'category': 'Mangalsutra',
              'collection': 'Modern Collection',
              'price': '₹48,000',
              'originalPrice': '₹54,000',
              'weight': '4.10 gm',
              'karat': '18K',
              'purity': '18K (750)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Daily Wear',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_1.jpeg',
              'badge': 'MODERN',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '9',
      name: 'Nose Rings',
      subtitle: 'Exquisite detailing',
      imagePath: 'assets/temp/demo_9.jpeg',
      productCount: 38,
      tags: ['gold', 'silver', 'rosegold'],
      startingPrice: 1800,
      subCategories: [
        JewelrySubCategory(
          id: '9_1',
          name: 'Bridal Nath',
          subtitle: 'Traditional bridal look',
          imagePath: 'assets/temp/demo_2.jpeg',
          products: [
            {
              'name': 'Heritage Gold Nath',
              'category': 'Nose Rings',
              'collection': 'Heritage Collection',
              'price': '₹12,500',
              'originalPrice': '₹14,000',
              'weight': '1.80 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Wedding',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_2.jpeg',
              'badge': 'HERITAGE',
            },
          ],
        ),
      ],
    ),
    JewelryCategory(
      id: '10',
      name: 'Maang Tikka',
      subtitle: 'Bridal splendor',
      imagePath: 'assets/temp/demo_10.jpeg',
      productCount: 61,
      tags: ['gold', 'diamond', 'pearl'],
      isFeatured: true,
      startingPrice: 15500,
      subCategories: [
        JewelrySubCategory(
          id: '10_1',
          name: 'Bridal Tikka',
          subtitle: 'Splendid head ornament',
          imagePath: 'assets/temp/demo_3.jpeg',
          products: [
            {
              'name': 'Classic Kundan Maang Tikka',
              'category': 'Maang Tikka',
              'collection': 'Bridal Collection',
              'price': '₹22,000',
              'originalPrice': '₹24,500',
              'weight': '5.20 gm',
              'karat': '22K',
              'purity': '22K (916)',
              'metal': 'Gold',
              'color': 'Yellow Gold',
              'occasion': 'Wedding',
              'hallmark': 'BIS Certified',
              'image': 'assets/temp/demo_3.jpeg',
              'badge': 'ROYAL',
            },
          ],
        ),
      ],
    ),
  ];

  // ── Filtered List (shown in UI) ────────────────────────────────────────
  final RxList<JewelryCategory> filteredCategories = <JewelryCategory>[].obs;
  final RxList<Map<String, dynamic>> filteredProducts = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> get allProducts => _allProducts;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _allProducts.clear();
    for (var cat in _allCategories) {
      for (var sub in cat.subCategories) {
        for (var prod in sub.products) {
          _allProducts.add({
            ...prod,
            'categoryId': cat.id,
            'categoryName': cat.name,
            'subCategoryId': sub.id,
            'subCategoryName': sub.name,
          });
        }
      }
    }
    filteredProducts.assignAll(_allProducts);
    filteredCategories.assignAll(_allCategories);
    
    // Begin loading categories from API
    fetchCategoriesFromApi();
    
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchCategoriesFromApi() async {
    try {
      isCategoriesLoading.value = true;
      final response = await _homeApiService.getCategories();
      
      final mapped = response.data.map((cat) {
        return JewelryCategory(
          id: cat.id,
          name: cat.categoryName,
          subtitle: '',
          imagePath: cat.image,
          productCount: cat.productCount,
          tags: [cat.categoryName.toLowerCase()],
          startingPrice: 5000,
        );
      }).toList();

      _allCategories.clear();
      _allCategories.addAll(mapped);
      
      filteredCategories.assignAll(_allCategories);
    } catch (e) {
      OtherMethods.customLog("❌ [CategoryController] Error loading categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchSubCategoriesFor(String categoryId) async {
    if (subCategoriesMap.containsKey(categoryId)) return; // already loaded
    try {
      subCategoriesLoadingMap[categoryId] = true;
      final response = await _homeApiService.getSubCategories(categoryId: categoryId);
      subCategoriesMap[categoryId] = response.data;
    } catch (e) {
      OtherMethods.customLog("❌ [CategoryController] Error loading subcategories for $categoryId: $e");
    } finally {
      subCategoriesLoadingMap[categoryId] = false;
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────
  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _applyFilters();
  }

  void _applyFilters() {
    // 1. Filter categories
    List<JewelryCategory> catResult = List<JewelryCategory>.from(_allCategories);
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      catResult = catResult.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.subtitle.toLowerCase().contains(query) ||
            c.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    final selectedMaterials = materialFilters
        .where((f) => f.isSelected)
        .map((f) => f.id)
        .toList();

    if (selectedMaterials.isNotEmpty) {
      catResult = catResult
          .where((c) => c.tags.any((t) => selectedMaterials.contains(t)))
          .toList();
    }

    switch (selectedSort.value) {
      case 'Price: Low to High':
        catResult.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        break;
      case 'Price: High to Low':
        catResult.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
        break;
      case 'Most Popular':
        catResult.sort((a, b) => b.productCount.compareTo(a.productCount));
        break;
      case 'Newest':
        catResult = catResult.reversed.toList();
        break;
      case 'Featured':
      default:
        catResult.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return 0;
        });
        break;
    }
    filteredCategories.assignAll(catResult);

    // 2. Filter products
    List<Map<String, dynamic>> prodResult = List<Map<String, dynamic>>.from(_allProducts);
    
    if (query.isNotEmpty) {
      prodResult = prodResult.where((p) {
        final name = (p['name'] as String? ?? '').toLowerCase();
        final collection = (p['collection'] as String? ?? '').toLowerCase();
        final categoryName = (p['categoryName'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            collection.contains(query) ||
            categoryName.contains(query);
      }).toList();
    }

    if (selectedMaterials.isNotEmpty) {
      prodResult = prodResult.where((p) {
        final name = (p['name'] as String? ?? '').toLowerCase();
        final metal = (p['metal'] as String? ?? '').toLowerCase();
        final karat = (p['karat'] as String? ?? '').toLowerCase();
        
        return selectedMaterials.any((matId) {
          if (matId == 'gold') return metal == 'gold' && karat == '22k';
          if (matId == '18k') return metal == 'gold' && karat == '18k';
          if (matId == 'diamond') return name.contains('diamond');
          if (matId == 'platinum') return metal == 'platinum';
          if (matId == 'silver') return metal == 'silver';
          return name.contains(matId);
        });
      }).toList();
    }

    switch (selectedSort.value) {
      case 'Price: Low to High':
        prodResult.sort((a, b) {
          final pa = _parsePrice(a['price'] as String? ?? '0');
          final pb = _parsePrice(b['price'] as String? ?? '0');
          return pa.compareTo(pb);
        });
        break;
      case 'Price: High to Low':
        prodResult.sort((a, b) {
          final pa = _parsePrice(a['price'] as String? ?? '0');
          final pb = _parsePrice(b['price'] as String? ?? '0');
          return pb.compareTo(pa);
        });
        break;
      case 'Most Popular':
        prodResult.sort((a, b) {
          final wa = _parseWeight(a['weight'] as String? ?? '0');
          final wb = _parseWeight(b['weight'] as String? ?? '0');
          return wb.compareTo(wa);
        });
        break;
      case 'Newest':
        prodResult = prodResult.reversed.toList();
        break;
      case 'Featured':
      default:
        prodResult.sort((a, b) {
          final isFeaturedA = a['badge'] != null ? 1 : 0;
          final isFeaturedB = b['badge'] != null ? 1 : 0;
          return isFeaturedB.compareTo(isFeaturedA);
        });
        break;
    }
    filteredProducts.assignAll(prodResult);
  }

  double _parsePrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  double _parseWeight(String weightStr) {
    final clean = weightStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  // ── Public Methods ─────────────────────────────────────────────────────

  /// Toggle a material filter chip by [id]
  void toggleMaterialFilter(String id) {
    final idx = materialFilters.indexWhere((f) => f.id == id);
    if (idx != -1) {
      materialFilters[idx].isSelected = !materialFilters[idx].isSelected;
      materialFilters.refresh();
      _applyFilters();
    }
  }

  /// Change the active sort option
  void setSort(String sort) {
    selectedSort.value = sort;
    _applyFilters();
  }

  /// Clear every active filter and search
  void clearAllFilters() {
    for (final f in materialFilters) {
      f.isSelected = false;
    }
    materialFilters.refresh();
    searchController.clear();
    selectedSort.value = 'Featured';
    _applyFilters();
  }

  // ── Computed Getters ───────────────────────────────────────────────────

  /// Returns true if any filter/search/sort is active
  bool get hasActiveFilters =>
      materialFilters.any((f) => f.isSelected) ||
          searchQuery.value.trim().isNotEmpty ||
          selectedSort.value != 'Featured';

  /// Number of selected material chips
  int get activeFilterCount =>
      materialFilters.where((f) => f.isSelected).length;

  /// Formatted price helper
  static String formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toStringAsFixed(0);
  }
}
