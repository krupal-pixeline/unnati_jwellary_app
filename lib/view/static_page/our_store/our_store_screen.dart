import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';
import 'our_store_controller.dart';

class OurStoreScreen extends StatelessWidget {
  const OurStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OurStoreController());

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: const CustomAppBar(title: "Our Store"),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
              ),
            );
          }

          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchStoreDetails(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final store = controller.storeData.value;
          if (store == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Card with Shop Name & Logo
                _buildShopLogoHeaderCard(),

                // 2. Showroom Image Card (Padded All Sides)
                _buildStoreImageCard(store),

                const SizedBox(height: 12),

                // 3. Interactive Quick Contact Actions (Call, Mail, Map)
                _buildQuickActionCards(controller, store),

                const SizedBox(height: 14),

                // 4. Location Address Details Card
                _buildAddressCard(controller, store),

                const SizedBox(height: 14),

                // 5. Store Operating Hours Card
                _buildOperatingHoursCard(store),

                const SizedBox(height: 14),

                // 6. Store Highlights & Amenities
                _buildStoreAmenitiesCard(),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── 1. Imperial Maroon & Royal Gold Brand Header Card ─────────────────────
  Widget _buildShopLogoHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A0815),
            AppColors.primaryMaroon,
            Color(0xFF5A0C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Gold Framed Logo Badge
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGold,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/app_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.diamond_rounded,
                  size: 32,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Shop Name & Luxury Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryGold,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "SINCE 1978",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "UNNATI JEWELLERS",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Exclusive Gold & Diamond Jewellery",
                  style: GoogleFonts.outfit(
                    color: AppColors.champagneGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Clean Store Image Card (Padded All Sides) ───────────────────────────
  Widget _buildStoreImageCard(dynamic store) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: store.imageUrl.isNotEmpty
              ? Image.network(
                  store.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMaroon),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _buildFallbackBanner(),
                )
              : _buildFallbackBanner(),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: AppColors.maroonDeep,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond_rounded, size: 48, color: AppColors.primaryGold),
            const SizedBox(height: 8),
            Text(
              "Unnati Jewellers",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Quick Action Buttons Row (Call, Email, Maps) ────────────────────────
  Widget _buildQuickActionCards(OurStoreController controller, dynamic store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Action 1: Call
          Expanded(
            child: _quickActionButton(
              icon: Icons.phone_forwarded_rounded,
              title: "Call Us",
              subtitle: store.phone.isNotEmpty ? store.phone : "Call Store",
              color: const Color(0xFF2E7D32),
              onTap: () => controller.makePhoneCall(),
            ),
          ),
          const SizedBox(width: 10),
          // Action 2: Email
          Expanded(
            child: _quickActionButton(
              icon: Icons.mark_email_read_rounded,
              title: "Email Us",
              subtitle: "Mail Inquiry",
              color: AppColors.primaryMaroon,
              onTap: () => controller.sendEmail(),
            ),
          ),
          const SizedBox(width: 10),
          // Action 3: Directions
          Expanded(
            child: _quickActionButton(
              icon: Icons.alt_route_rounded,
              title: "Directions",
              subtitle: "Open Map",
              color: const Color(0xFF1565C0),
              onTap: () => controller.openMap(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. Location Address Card ───────────────────────────────────────────────
  Widget _buildAddressCard(OurStoreController controller, dynamic store) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryMaroon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Store Address",
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          Text(
            store.address,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Google Maps Navigation Bar Button
          GestureDetector(
            onTap: () => controller.openMap(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryMaroon,
                    AppColors.maroonDeep,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMaroon.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Open in Google Maps",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Operating Hours Card ────────────────────────────────────────────────
  Widget _buildOperatingHoursCard(dynamic store) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: AppColors.primaryGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Store Hours",
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),

          // Weekdays Timings
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryMaroon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  store.hoursWeekdays,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sunday Timings
          Row(
            children: [
              const Icon(Icons.event_seat_rounded, size: 18, color: AppColors.primaryGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  store.hoursSunday,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. Store Amenities & Highlights Card ──────────────────────────────────
  Widget _buildStoreAmenitiesCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.champagneGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Showroom Highlights",
            style: GoogleFonts.outfit(
              color: AppColors.primaryMaroon,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _amenityItem(Icons.verified_rounded, "100% BIS Hallmarked Jewellery"),
          const SizedBox(height: 8),
          _amenityItem(Icons.diamond_rounded, "Certified Solitaires & Fine Diamonds"),
          const SizedBox(height: 8),
          _amenityItem(Icons.local_cafe_rounded, "VIP Private Customer Lounge"),
          const SizedBox(height: 8),
          _amenityItem(Icons.local_parking_rounded, "Dedicated Customer Valet Parking"),
        ],
      ),
    );
  }

  Widget _amenityItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGold),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
