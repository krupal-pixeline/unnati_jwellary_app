import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unnati_jwelers/view/static_page/about_us/about_us_screen.dart';
import '../static_page/our_store/our_store_screen.dart';
import '../category/wishlist_controller.dart';
import '../category/wishlist_screen.dart';
import 'package:unnati_jwelers/view/static_page/contact_us/contactus_screen.dart';
import 'package:unnati_jwelers/view/static_page/privecy_policy/privecy_policy_screen.dart';
import 'package:unnati_jwelers/view/static_page/terms_and_conditions/terms_and_condition_screen.dart';
import '../../utils/app_colors.dart';
import '../category/category_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_screen.dart';
import '../lucky_draw/lucky_draw_screen.dart';
import '../auth/login/login_screen.dart';
import '../../utils/app_key_names.dart';
import '../../utils/other_methods.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppVersion();
  }

  Future<void> loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = '';
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class MainLayoutScreen extends StatelessWidget {
  MainLayoutScreen({super.key});

  final MainLayoutController controller = Get.put(MainLayoutController());

  final List<Widget> screens = [
    HomeScreen(),
    CategoryScreen(),
    // const SuvarnaMainScreen(),
    const LuckyDrawScreen(),
    const ProfileScreen(),
  ];

  final List<String> titles = [
    "Unnati Jewellers",
    "Categories",
    // "Suvarna Scheme",
    "Lucky Draw",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(WishlistController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      drawer: const AppDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: Obx(
          () => Text(
            titles[controller.currentIndex.value],
            style:  GoogleFonts.cinzel(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications_active_outlined, color: AppColors.textWhite),
          //   onPressed: () => Get.to(() => NotificationScreen()),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withOpacity(.1), blurRadius: 10),
          ],
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: AppColors.white,
            type: BottomNavigationBarType.fixed,
            onTap: controller.changeTab,
            items:  [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: "Categories",
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.workspace_premium_outlined),
              //   activeIcon: Icon(Icons.workspace_premium),
              //   label: "Suvarna",
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_activity_outlined),
                activeIcon: Icon(Icons.local_activity),
                label: "Lucky Draw",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _drawerFallbackAvatar(String name) {
    final initial = name.isNotEmpty && name != 'Guest User' ? name[0].toUpperCase() : 'U';
    return CircleAvatar(
      backgroundColor: AppColors.backgroundPrimary,
      child: Text(
        initial,
        style: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryMaroon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layoutCtrl = Get.isRegistered<MainLayoutController>()
        ? Get.find<MainLayoutController>()
        : Get.put(MainLayoutController());

    final ProfileController profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      child: Column(
        children: [
          // ── USER PROFILE HEADER ────────────────────────────────────────────
          Obx(() {
            final p = profileCtrl.profile.value;
            final userModelMap = OtherMethods.getStorage(AppKeyNames.userModel);

            final String fullName = p?.fullName.isNotEmpty == true
                ? p!.fullName
                : (userModelMap != null ? (userModelMap['fullName'] ?? 'Guest User') : 'Guest User');

            final String mobileNumber = p?.mobileNumber.isNotEmpty == true
                ? p!.mobileNumber
                : (userModelMap != null ? (userModelMap['mobileNumber'] ?? '') : '');

            final String? imageUrl = p?.profileImageUrl ?? (userModelMap != null ? userModelMap['profilePhoto'] : null);
            final String localPath = profileCtrl.selectedImagePath.value;

            return Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold, width: 2),
                    ),
                    child: ClipOval(
                      child: localPath.isNotEmpty
                          ? Image.file(
                              File(localPath),
                              fit: BoxFit.cover,
                            )
                          : (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _drawerFallbackAvatar(fullName),
                                )
                              : _drawerFallbackAvatar(fullName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mobileNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            mobileNumber.startsWith('+') ? mobileNumber : "+91 $mobileNumber",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── LIST OF DRAWER ITEMS ───────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                // Group 1: Navigation
                _sectionHeader("Explore App"),
                _drawerItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  title: "Home",
                  onTap: () {
                    Get.back();
                    layoutCtrl.changeTab(0);
                  },
                ),
                _drawerItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  title: "Categories",
                  onTap: () {
                    Get.back();
                    layoutCtrl.changeTab(1);
                  },
                ),
                  // _drawerItem(
                  //   icon: Icons.workspace_premium_outlined,
                  //   activeIcon: Icons.workspace_premium_rounded,
                  //   title: "Suvarna Gold Scheme",
                  //   isHot: true,
                  //   onTap: () {
                  //     Get.back();
                  //     layoutCtrl.changeTab(2);
                  //   },
                  // ),
                _drawerItem(
                  icon: Icons.local_activity_outlined,
                  activeIcon: Icons.local_activity_rounded,
                  title: "Lucky Draw",
                  onTap: () {
                    Get.back();
                    layoutCtrl.changeTab(2);
                  },
                ),
                _drawerItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  title: "My Profile",
                  onTap: () {
                    Get.back();
                    layoutCtrl.changeTab(3);
                  },
                ),

                const Divider(height: 12, thickness: 0.8),

                // Group 2: Account Features
                _sectionHeader("My Shopping"),
                _drawerItem(
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  title: "Wishlist",
                  onTap: () {
                    Get.back();
                    Get.to(() => WishlistScreen());
                  },
                ),

                const Divider(height: 12, thickness: 0.8),

                // Group 3: Information & Support
                _sectionHeader("Support & Info"),
                _drawerItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  title: "Our Store",
                  onTap: () {
                    Get.back();
                    Get.to(() => const OurStoreScreen());
                  },
                ),
                _drawerItem(
                  icon: Icons.info_outline_rounded,
                  activeIcon: Icons.info_rounded,
                  title: "About Us",
                  onTap: () {
                    Get.back();
                    Get.to(() => AboutUsScreen());
                  },
                ),
                _drawerItem(
                  icon: Icons.phone_outlined,
                  activeIcon: Icons.phone_rounded,
                  title: "Contact Us",
                  onTap: () {
                    Get.back();
                    Get.to(() => const ContactUsScreen());
                  },
                ),
                _drawerItem(
                  icon: Icons.privacy_tip_outlined,
                  activeIcon: Icons.privacy_tip_rounded,
                  title: "Privacy Policy",
                  onTap: () {
                    Get.back();
                    Get.to(() => const PrivecyPolicyScreen());
                  },
                ),
                _drawerItem(
                  icon: Icons.gavel_outlined,
                  activeIcon: Icons.gavel_rounded,
                  title: "Terms & Conditions",
                  onTap: () {
                    Get.back();
                    Get.to(() => const TermsAndConditionScreen());
                  },
                ),
              ],
            ),
          ),

          // ── LOGOUT FOOTER BUTTON & APP VERSION ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 4),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    "Logout Account",
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () => _showLogoutConfirmation(context),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    layoutCtrl.appVersion.value.isNotEmpty
                        ? "App Version v${layoutCtrl.appVersion.value}"
                        : "App Version",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Custom Tile Item ───────────────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required VoidCallback onTap,
    bool isHot = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: ListTile(
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: Icon(icon, color: AppColors.primaryMaroon, size: 22),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isHot)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.goldLight],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "LIVE",
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryMaroon,
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textTertiary,
          size: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }

  // ── Logout confirmation ────────────────────────────────────────────────────
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.backgroundPrimary,
          title: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Logout Account",
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryMaroon,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to log out of your Unnati Jewelers account?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // close dialog synchronously
                OtherMethods.customLog("🔑 [MainLayoutScreen] Logging out... Clearing storage session.");
                await OtherMethods.clearStorage();
                Get.back(); // close drawer
                Get.offAll(() => const LoginScreen()); // route to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
