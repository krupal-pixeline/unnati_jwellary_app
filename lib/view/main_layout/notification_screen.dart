import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/home_api_services.dart';
import '../../utils/app_colors.dart';
import '../../utils/custom_app_bar.dart';
import '../product_details/product_details_screen.dart';
import '../suvarna/activated_scheme/activated_scheme_screen.dart';

class NotificationItemModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String type; // 'product', 'skim' / 'scheme', 'info'
  final String? productId;
  final DateTime time;
  bool isRead;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    this.productId,
    required this.time,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItemModel> _notifications = [
    NotificationItemModel(
      id: '1',
      title: 'New Arrival: Couple Bands Classic Design',
      description: 'Handcrafted 22K gold couple bands classic design is now back in stock. Tap to view details and buy.',
      imageUrl: 'https://api.unnatijewellers.com/uploads/products/product-1784283672311-985572430.jpeg',
      type: 'product',
      productId: '6a566ad0133b60e899ef4fea',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationItemModel(
      id: '2',
      title: 'Monthly Scheme Installment Due',
      description: 'Your monthly gold scheme installment of ₹5,000 for Suvarna Unnati is due. Make payment today to maintain benefits.',
      type: 'skim',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    NotificationItemModel(
      id: '3',
      title: 'Trending Gold Hoops Earrings',
      description: 'Explore the popular 22K gold hoops earrings design. Tap to check weight and live calculated pricing details.',
      imageUrl: 'https://api.unnatijewellers.com/uploads/products/product-1784284139090-465265438.jpeg',
      type: 'product',
      productId: '6a5a03eb62c579f33e10f150',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItemModel(
      id: '4',
      title: 'Welcome to Unnati Jewellers',
      description: 'Save today, shine forever. Save up to 10% on making charges by joining the Suvarna Unnati Scheme.',
      type: 'info',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _handleNotificationClick(NotificationItemModel notification) async {
    setState(() {
      notification.isRead = true;
    });

    if (notification.type == 'product' && notification.productId != null) {
      // Show loading spinner
      Get.dialog(
        const Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Product Details...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      try {
        final response = await HomeApiService().getProductDetail(
          productId: notification.productId!,
        );
        Get.back(); // Dismiss loading dialog

        Get.to(
          () => const ProductDetailsScreen(),
          arguments: response.data.toUiMap(),
          preventDuplicates: false,
        );
      } catch (e) {
        Get.back(); // Dismiss loading dialog
        Get.snackbar(
          "Error",
          "Could not load product details. Please try again.",
          backgroundColor: Colors.red.withValues(alpha: 0.85),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else if (notification.type == 'skim' || notification.type == 'scheme') {
      Get.to(() => const ActivatedSchemeScreen());
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            notification.title,
            style: GoogleFonts.cinzel(
              color: AppColors.primaryMaroon,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: Text(
            notification.description,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: "Notifications",
        actions: _notifications.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _notifications.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryMaroon,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
          setState(() {});
        },
        child: _notifications.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState(),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                final item = _notifications[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: GestureDetector(
                    onTap: () => _handleNotificationClick(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: item.isRead ? Colors.white : const Color(0xFFFFF9F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isRead
                              ? AppColors.border.withValues(alpha: 0.6)
                              : AppColors.primaryGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Icon Indicator
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? AppColors.backgroundSecondary.withValues(alpha: 0.8)
                                  : AppColors.paleGold.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForType(item.type),
                              size: 18,
                              color: item.isRead ? AppColors.textSecondary : AppColors.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!item.isRead)
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryGold,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getTimeAgo(item.time),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Optional Image Thumbnail on Right
                          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.8),
                                  width: 0.8,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryMaroon,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.backgroundSecondary,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 16,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'product':
        return Icons.shopping_bag_outlined;
      case 'skim':
      case 'scheme':
        return Icons.savings_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: AppColors.primaryGold.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications Yet',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMaroon,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We will alert you when something exciting lands!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
