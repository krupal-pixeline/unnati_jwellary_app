import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unnati_jwelers/services/profile_api_services.dart';
import 'package:unnati_jwelers/utils/app_colors.dart';
import 'package:unnati_jwelers/view/profile/profile_model.dart';
import '../../utils/app_key_names.dart';
import '../../utils/other_methods.dart';

// ============================================================
//  ProfileController — GetX
//  Manages: Profile view/edit, Addresses, Appointments,
//           Referral Wallet, Referral Chain
// ============================================================

class ProfileController extends GetxController {
  final _apiService = ProfileApiService();

  // ── Loading States ─────────────────────────────────────────
  final RxBool isProfileLoading     = false.obs;
  final RxBool isAddressLoading     = false.obs;
  final RxBool isAppointmentLoading = false.obs;
  final RxBool isWalletLoading      = false.obs;
  final RxBool isChainLoading       = false.obs;
  final RxBool isSavingProfile      = false.obs;

  // ── Edit Mode ──────────────────────────────────────────────
  final RxBool isEditMode = false.obs;

  // ── Data ───────────────────────────────────────────────────
  final Rx<CustomerProfile?> profile              = Rx<CustomerProfile?>(null);
  final RxList<CustomerAddress> addresses         = <CustomerAddress>[].obs;
  final RxList<AppointmentHistory> appointments   = <AppointmentHistory>[].obs;
  final Rx<ReferralWallet?> wallet                = Rx<ReferralWallet?>(null);
  final RxList<ReferredUser> referredUsers        = <ReferredUser>[].obs;

  // ── Selected Profile Image Local Path ──────────────────────
  final RxString selectedImagePath = ''.obs;

  // ── Form Controllers ───────────────────────────────────────
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController dobController;
  late TextEditingController anniversaryController;
  late TextEditingController cityController;
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  // ── Error States ───────────────────────────────────────────
  final RxString profileError     = ''.obs;
  final RxString walletError      = ''.obs;
  final RxString appointmentError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initFormControllers();
    fetchAllProfileData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    anniversaryController.dispose();
    cityController.dispose();
    super.onClose();
  }

  // ── Init helpers ───────────────────────────────────────────
  void _initFormControllers() {
    nameController        = TextEditingController();
    emailController       = TextEditingController();
    dobController         = TextEditingController();
    anniversaryController = TextEditingController();
    cityController        = TextEditingController();
  }

  void _populateFormFromProfile() {
    final p = profile.value;
    if (p == null) return;
    nameController.text        = p.fullName;
    emailController.text       = p.emailAddress;
    dobController.text         = p.dateOfBirth;
    anniversaryController.text = p.anniversaryDate;
    cityController.text        = p.city;
    selectedImagePath.value    = ''; // Reset photo selection
  }

  // ── Fetch All ──────────────────────────────────────────────
  Future<void> fetchAllProfileData() async {
    await Future.wait([
      fetchProfile(),
      fetchAddresses(),
      fetchAppointments(),
      fetchReferralWallet(),
      fetchReferralChain(),
    ]);
  }

  // ── Fetch Profile ──────────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      isProfileLoading.value = true;
      profileError.value = '';
      final p = await _apiService.getProfile();
      profile.value = p;
      await OtherMethods.setStorage(
        key: AppKeyNames.userModel,
        value: p.toJson(),
      );
      _populateFormFromProfile();
    } catch (e) {
      profileError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isProfileLoading.value = false;
    }
  }

  // ── Fetch Addresses ────────────────────────────────────────
  Future<void> fetchAddresses() async {
    try {
      isAddressLoading.value = true;
      // Address API not provided, keeping mock addresses
      addresses.value = [
        CustomerAddress(
          id: 'A1',
          label: 'Home',
          addressLine1: '12, Shanti Nagar Society',
          addressLine2: 'Near Vijay Cross Roads',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380009',
          isDefault: true,
        ),
      ];
    } catch (e) {
      // silent fail
    } finally {
      isAddressLoading.value = false;
    }
  }

  // ── Fetch Appointments ─────────────────────────────────────
  Future<void> fetchAppointments() async {
    try {
      isAppointmentLoading.value = true;
      appointmentError.value = '';
      final list = await _apiService.getAppointments();
      appointments.value = list;
    } catch (e) {
      appointmentError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isAppointmentLoading.value = false;
    }
  }

  // ── Fetch Referral Wallet ──────────────────────────────────
  Future<void> fetchReferralWallet() async {
    try {
      isWalletLoading.value = true;
      walletError.value = '';
      final w = await _apiService.getReferrals();
      wallet.value = w;
    } catch (e) {
      walletError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isWalletLoading.value = false;
    }
  }

  // ── Fetch Referral Chain ───────────────────────────────────
  Future<void> fetchReferralChain() async {
    try {
      isChainLoading.value = true;
      referredUsers.value = [];
    } catch (e) {
      // silent fail
    } finally {
      isChainLoading.value = false;
    }
  }

  // ── Image Picker & Auto Upload ─────────────────────────────
  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 800,
      );
      if (file != null) {
        selectedImagePath.value = file.path;
        await uploadSelectedProfilePhoto();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> uploadSelectedProfilePhoto() async {
    if (selectedImagePath.value.isEmpty) return;

    try {
      isSavingProfile.value = true;
      final currentProfile = profile.value;

      final fullName = nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : (currentProfile?.fullName ?? '');
      final emailAddress = emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : (currentProfile?.emailAddress ?? '');
      final dob = dobController.text.trim().isNotEmpty
          ? dobController.text.trim()
          : (currentProfile?.dateOfBirth ?? '');
      final anniversaryDate = anniversaryController.text.trim().isNotEmpty
          ? anniversaryController.text.trim()
          : (currentProfile?.anniversaryDate ?? '');
      final city = cityController.text.trim().isNotEmpty
          ? cityController.text.trim()
          : (currentProfile?.city ?? '');

      final updated = await _apiService.updateProfile(
        fullName: fullName,
        emailAddress: emailAddress,
        dob: dob,
        anniversaryDate: anniversaryDate,
        city: city,
        localImagePath: selectedImagePath.value,
      );

      profile.value = updated;
      selectedImagePath.value = '';
      _populateFormFromProfile();

      await OtherMethods.setStorage(
        key: AppKeyNames.userModel,
        value: updated.toJson(),
      );

      Get.snackbar(
        'Success',
        'Profile photo updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  void showPhotoSelectionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Photo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryMaroon),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickProfilePhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryMaroon),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickProfilePhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Mode Toggle ───────────────────────────────────────
  void enterEditMode() {
    _populateFormFromProfile();
    isEditMode.value = true;
  }

  void cancelEditMode() {
    _populateFormFromProfile();
    isEditMode.value = false;
  }

  // ── Save Profile ───────────────────────────────────────────
  Future<void> saveProfile() async {
    if (!(profileFormKey.currentState?.validate() ?? false)) return;

    try {
      isSavingProfile.value = true;
      final updated = await _apiService.updateProfile(
        fullName: nameController.text.trim(),
        emailAddress: emailController.text.trim(),
        dob: dobController.text.trim(),
        anniversaryDate: anniversaryController.text.trim(),
        city: cityController.text.trim(),
        localImagePath: selectedImagePath.value.isNotEmpty ? selectedImagePath.value : null,
      );

      profile.value = updated;
      selectedImagePath.value = '';
      isEditMode.value = false;
      _populateFormFromProfile();

      await OtherMethods.setStorage(
        key: AppKeyNames.userModel,
        value: updated.toJson(),
      );

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  // ── Set Default Address ────────────────────────────────────
  void setDefaultAddress(String addressId) {
    for (final addr in addresses) {
      addr.isDefault = addr.id == addressId;
    }
    addresses.refresh();
    Get.snackbar(
      'Updated',
      'Default address changed.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> selectDate(BuildContext context, {required bool isDob}) async {
    final text = isDob ? dobController.text : anniversaryController.text;
    final initialDate = DateTime.tryParse(text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryMaroon,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryMaroon,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      if (isDob) {
        dobController.text = formattedDate;
      } else {
        anniversaryController.text = formattedDate;
      }
    }
  }

  // ── Referral Code Copy ─────────────────────────────────────
  void copyReferralCode() {
    // Clipboard.setData(ClipboardData(text: profile.value?.referralCode ?? ''));
    Get.snackbar(
      'Copied!',
      'Referral code copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String appointmentStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:  return 'Confirmed';
      case AppointmentStatus.completed:  return 'Completed';
      case AppointmentStatus.cancelled:  return 'Cancelled';
      case AppointmentStatus.pending:    return 'Pending';
    }
  }

  String commissionStatusLabel(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:   return 'Pending';
      case CommissionStatus.approved:  return 'Approved';
      case CommissionStatus.rejected:  return 'Rejected';
      case CommissionStatus.reversed:  return 'Redeemed';
    }
  }

  // ── Validators ─────────────────────────────────────────────
  String? validateName(String? val) {
    if (val == null || val.trim().isEmpty) return 'Full name is required';
    if (val.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(val.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validateCity(String? val) {
    if (val == null || val.trim().isEmpty) return 'City is required';
    return null;
  }
}
