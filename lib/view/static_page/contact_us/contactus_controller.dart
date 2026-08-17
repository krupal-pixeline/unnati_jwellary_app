import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unnati_jwelers/services/profile_api_services.dart';
import 'package:unnati_jwelers/utils/app_colors.dart';
import 'package:unnati_jwelers/view/profile/profile_controller.dart';

class ContactUsController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form Field Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final isLoading = false.obs;
  final isBookingLoading = false.obs;

  // Showroom Contact Info
  final String phoneNumber = "+916351630432";
  final String callNumber = "+916351630432";
  final String emailAddress = "unnatijewellers.official@gmail.com";
  final String whatsappNumber = "+916351630432";
  final String showroomAddress = " Ground Floor, Parimal Bungalow, Shanti Sky, Waghawadi Road, Bhavnagar, Gujarat 364001";
  final String showroomHours = "10:00 AM - 08:30 PM (Mon - Sat)\nSunday: By Appointment Only";

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    messageController.dispose();
    bookingMessageController.dispose();
    super.onClose();
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      
      // Simulate contact form message API submission
      await Future.delayed(const Duration(milliseconds: 1500));
      
      isLoading.value = false;
      
      Get.snackbar(
        "Message Sent!",
        "Thank you for contacting Unnati Jewelers. We will get back to you shortly.",
        backgroundColor: AppColors.successLight,
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 4),
      );
      
      // Clear Form Fields
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      subjectController.clear();
      messageController.clear();
    }
  }

  // ── Book Visit API integration ─────────────────────────────────────────────
  Future<bool> bookVisit({
    required String preferredDate,
    required String preferredTime,
    required String purposeOfVisit,
    required String estimatedBudget,
    required String additionalRequirements,
  }) async {
    try {
      isBookingLoading.value = true;
      final api = ProfileApiService();
      await api.bookAppointment(
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        purposeOfVisit: purposeOfVisit,
        estimatedBudget: estimatedBudget,
        additionalRequirements: additionalRequirements,
        productId: ''
      );

      // Refresh profile appointment list if controller exists
      try {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchAppointments();
        }
      } catch (_) {}

      return true;
    } catch (e) {
      Get.snackbar(
        "Booking Failed",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: AppColors.errorLight,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBookingLoading.value = false;
    }
  }

  // ── Showroom Visit Booking State Variables ─────────────────────────────────
  final bookingDate = Rx<DateTime>(DateTime.now());
  final bookingSlot = 'Morning (10 AM - 1 PM)'.obs;
  final isCustomDate = false.obs;
  final isCustomTime = false.obs;
  final customTimeVal = const TimeOfDay(hour: 12, minute: 0).obs;
  final selectedPurpose = 'Buying Jewelry'.obs;
  final selectedBudget = '₹50,000 - ₹1,00,000'.obs;
  final bookingMessageController = TextEditingController();

  void resetBookingState() {
    bookingDate.value = DateTime.now();
    bookingSlot.value = 'Morning (10 AM - 1 PM)';
    isCustomDate.value = false;
    isCustomTime.value = false;
    customTimeVal.value = const TimeOfDay(hour: 12, minute: 0);
    selectedPurpose.value = 'Buying Jewelry';
    selectedBudget.value = '₹50,000 - ₹1,00,000';
    bookingMessageController.clear();
  }
}
