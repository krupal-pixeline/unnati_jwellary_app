import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import 'category_controller.dart';
import 'jewelry_category_model.dart';
import 'category_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final CategoryController controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: _buildCategoryList(),
    );
  }

  // ── Category List ──────────────────────────────────────────────────
  Widget _buildCategoryList() {
    return RefreshIndicator(
      color: AppColors.primaryMaroon,
      onRefresh: () => controller.fetchCategoriesFromApi(),
      child: Obx(() {
        if (controller.isCategoriesLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
            ),
          );
        }

        if (controller.filteredCategories.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: SizedBox(
              height: MediaQuery.of(Get.context!).size.height * 0.7,
              child: _buildEmptyState(),
            ),
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.filteredCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final cat = controller.filteredCategories[i];
            return _CategoryListCard(category: cat, controller: controller);
          },
        );
      }),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.paleGold, AppColors.backgroundSecondary],
              ),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.champagneGold,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Collections Found',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EXPANDABLE CATEGORY LIST CARD
// ─────────────────────────────────────────────
class _CategoryListCard extends StatelessWidget {
  final JewelryCategory category;
  final CategoryController controller;
  const _CategoryListCard({required this.category, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => const CategoryDetailScreen(),
            arguments: category,
          );
        },
        child: Container(
          height: 100,
          color: Colors.transparent, // Ensure full hit test area
          child: Row(
            children: [
              // Left Dark Maroon image box
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFF420B0B), // Deep maroon
                  child: category.imagePath.startsWith('http')
                      ? Image.network(
                          category.imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.champagneGold),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryMaroon,
                            child: const Icon(
                              Icons.diamond_outlined,
                              color: AppColors.champagneGold,
                              size: 36,
                            ),
                          ),
                        )
                      : Image.asset(
                          category.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryMaroon,
                            child: const Icon(
                              Icons.diamond_outlined,
                              color: AppColors.champagneGold,
                              size: 36,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // TODO Middle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${category.productCount}+ Products',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Forward Arrow Indicator instead of Dropdown
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
