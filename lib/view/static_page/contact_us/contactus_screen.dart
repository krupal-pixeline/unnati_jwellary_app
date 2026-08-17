import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_colors.dart';
import 'contactus_controller.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // ── Helper to Launch Links Safely ──────────────────────────────────────────
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      try {
        await launchUrl(uri);
      } catch (err) {
        Get.snackbar(
          "Error",
          "Could not open the action link.",
          backgroundColor: AppColors.errorLight,
          colorText: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactUsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primaryMaroon,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Contact Us",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. Upper Section: Contact Form Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildContactFormCard(context, controller),
              ),

              const SizedBox(height: 20),

              // Divider separating Form and Quick Contact Blocks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "OR REACH US VIA",
                        style: GoogleFonts.outfit(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Downside Section: Row of Quick Action Contact Blocks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.phone_in_talk_rounded,
                        title: "Call Us",
                        subtitle: controller.phoneNumber,
                        onTap: () => _launchUrl("tel:${controller.callNumber}"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.email_rounded,
                        title: "Email Us",
                        subtitle: controller.emailAddress,
                        onTap: () => _launchUrl("mailto:${controller.emailAddress}"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Downside Section: Showroom Location Map Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLocationCard(controller),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // ── Bottom Action Row (Book Visit + Chat with Us) ──────────────────────
      bottomNavigationBar: _buildStickyBottomBar(context, controller),
    );
  }

  // ── Quick Action Card (Call / Email) ───────────────────────────────────────
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: Icon(icon, color: AppColors.primaryMaroon, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Showroom Address Card ──────────────────────────────────────────────────
  Widget _buildLocationCard(ContactUsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primaryMaroon, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Visit Our Showroom",
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.showroomAddress,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Store Hours",
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      controller.showroomHours,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  final String query = Uri.encodeComponent("Unnati Jewelers Bhavnagar");
                  _launchUrl("https://www.google.com/maps/search/?api=1&query=$query");
                },
                icon: const Icon(Icons.directions_rounded, size: 16),
                label: Text(
                  "Navigate",
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact Form Card ──────────────────────────────────────────────────────
  Widget _buildContactFormCard(BuildContext context, ContactUsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Send Message",
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Drop us a line and our manager will contact you within 24 hours.",
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Full Name Input
            _buildTextField(
              controller: controller.nameController,
              label: "Full Name",
              hint: "Enter your name",
              prefixIcon: Icons.person_outline_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter your name";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email Input
            _buildTextField(
              controller: controller.emailController,
              label: "Email Address",
              hint: "Enter your email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter your email";
                }
                if (!GetUtils.isEmail(val.trim())) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Phone Input
            _buildTextField(
              controller: controller.phoneController,
              label: "Phone Number",
              hint: "Enter 10-digit number",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter your phone number";
                }
                if (val.trim().length != 10 || !GetUtils.isNum(val.trim())) {
                  return "Please enter a valid 10-digit number";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Subject Input
            _buildTextField(
              controller: controller.subjectController,
              label: "Subject",
              hint: "e.g., Suvarna scheme, gold design",
              prefixIcon: Icons.topic_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter a subject";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Message Input
            _buildTextField(
              controller: controller.messageController,
              label: "Message",
              hint: "Write your message here...",
              prefixIcon: Icons.chat_bubble_outline_rounded,
              maxLines: 4,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter your message";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final bool loading = controller.isLoading.value;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: loading ? null : () => controller.submitForm(),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Send Message",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Styled Text Field Builder ──────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary, fontSize: 12),
            prefixIcon: Icon(prefixIcon, color: AppColors.primaryMaroon.withOpacity(0.7), size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorStyle: GoogleFonts.outfit(fontSize: 11, color: Colors.red),
          ),
        ),
      ],
    );
  }

  // ── Sticky Bottom Action Row (Book Visit + Chat with Us) ───────────────────
  Widget _buildStickyBottomBar(BuildContext context, ContactUsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Button 1: Book Visit (Maroon Gradient Primary)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBookingDialog(context, controller),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMaroon.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.champagneGold,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Book Visit",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Button 2: Chat with Us (WhatsApp Outlined Secondary)
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final String phone = controller.whatsappNumber;
                  final String message = "Hello Unnati Jewelers, I have a query and would like some assistance.";
                  final Uri whatsappUri = Uri.parse(
                    "https://wa.me/$phone?text=${Uri.encodeComponent(message)}"
                  );
                  if (await canLaunchUrl(whatsappUri)) {
                    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      "WhatsApp Error",
                      "Could not launch WhatsApp application.",
                      backgroundColor: AppColors.errorLight,
                      colorText: AppColors.error,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryMaroon, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/whatsapp.png",
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryMaroon,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Chat with Us",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryMaroon,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Showroom Visit Booking Flow Dialog ──────────────────────────────────────
  void _showBookingDialog(BuildContext context, ContactUsController controller) {
    controller.resetBookingState();

    final DateTime today = DateTime.now();
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        final selectedDate = controller.bookingDate;
        final selectedSlot = controller.bookingSlot;
        final isCustomDate = controller.isCustomDate;
        final selectedPurpose = controller.selectedPurpose;
        final selectedBudget = controller.selectedBudget;
        final messageController = controller.bookingMessageController;

        final purposes = [
          'Buying Jewelry',
          'Viewing Collections',
          'Custom Design Inquiry',
          'Jewelry Exchange/Sells',
          'Repairing & Polishing',
          'Other'
        ];

        final budgets = [
          'Under ₹25,000',
          '₹25,000 - ₹50,000',
          '₹50,000 - ₹1,00,000',
          '₹1,00,000 - ₹2,50,000',
          '₹2,50,000 - ₹5,00,000',
          '₹5,00,000+',
          'Not Sure'
        ];

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Schedule Showroom Visit",
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Experience our collections live in-store. Select your preferred date and time slot below.",
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date Selection Row
                  Text(
                    "Select Date",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final currentSelected = selectedDate.value;
                    final bool isToday = currentSelected.year == today.year &&
                        currentSelected.month == today.month &&
                        currentSelected.day == today.day;
                    final bool isTomorrow = currentSelected.year == tomorrow.year &&
                        currentSelected.month == tomorrow.month &&
                        currentSelected.day == tomorrow.day;
                    final bool isOther = !isToday && !isTomorrow && isCustomDate.value;

                    return Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              selectedDate.value = today;
                              isCustomDate.value = false;
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isToday ? AppColors.paleGold.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isToday ? AppColors.primaryGold : AppColors.border.withOpacity(0.4),
                                  width: isToday ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text("Today",
                                      style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isToday ? AppColors.primaryMaroon : AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text("${today.day} ${_getMonthName(today.month)}",
                                      style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              selectedDate.value = tomorrow;
                              isCustomDate.value = false;
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isTomorrow ? AppColors.paleGold.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isTomorrow ? AppColors.primaryGold : AppColors.border.withOpacity(0.4),
                                  width: isTomorrow ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text("Tomorrow",
                                      style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isTomorrow ? AppColors.primaryMaroon : AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text("${tomorrow.day} ${_getMonthName(tomorrow.month)}",
                                      style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: today,
                                firstDate: today,
                                lastDate: today.add(const Duration(days: 30)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryMaroon,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                selectedDate.value = picked;
                                isCustomDate.value = true;
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isOther ? AppColors.paleGold.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isOther ? AppColors.primaryGold : AppColors.border.withOpacity(0.4),
                                  width: isOther ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 11,
                                          color: isOther ? AppColors.primaryMaroon : AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text("Pick Date",
                                          style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isOther ? AppColors.primaryMaroon : AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                      isOther
                                          ? "${currentSelected.day} ${_getMonthName(currentSelected.month)}"
                                          : "Select custom",
                                      style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 14),

                  // Time Slot Selection
                  Text(
                    "Select Time Slot",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final currSlot = selectedSlot.value;

                    return Column(
                      children: [
                        _buildSelectableSlotTile(
                          'Morning (10 AM - 1 PM)',
                          currSlot == 'Morning (10 AM - 1 PM)',
                          Icons.wb_sunny_outlined,
                          () {
                            selectedSlot.value = 'Morning (10 AM - 1 PM)';
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildSelectableSlotTile(
                          'Afternoon (1 PM - 5 PM)',
                          currSlot == 'Afternoon (1 PM - 5 PM)',
                          Icons.wb_cloudy_outlined,
                          () {
                            selectedSlot.value = 'Afternoon (1 PM - 5 PM)';
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildSelectableSlotTile(
                          'Evening (5 PM - 8 PM)',
                          currSlot == 'Evening (5 PM - 8 PM)',
                          Icons.nights_stay_outlined,
                          () {
                            selectedSlot.value = 'Evening (5 PM - 8 PM)';
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 14),

                  // Purpose Dropdown
                  Text(
                    "Purpose of Visit",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedPurpose.value,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                          ),
                        ),
                        items: purposes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.outfit()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedPurpose.value = val;
                        },
                      )),

                  const SizedBox(height: 10),

                  // Estimated Budget Dropdown
                  Text(
                    "Estimated Budget",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedBudget.value,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                          ),
                        ),
                        items: budgets.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.outfit()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedBudget.value = val;
                        },
                      )),

                  const SizedBox(height: 10),

                  // Message (Optional) Text Field
                  Text(
                    "Message (Optional)",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: messageController,
                    maxLines: 2,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Add special instructions or items you want to view...",
                      hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final bool loading = controller.isBookingLoading.value;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMaroon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                final dateStr = "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";
                                
                                String apiTimeSlot = 'Morning';
                                if (selectedSlot.value.startsWith('Afternoon')) {
                                  apiTimeSlot = 'Afternoon';
                                } else if (selectedSlot.value.startsWith('Evening')) {
                                  apiTimeSlot = 'Evening';
                                }

                                final purposeStr = selectedPurpose.value;
                                final budgetStr = selectedBudget.value;
                                final requirementsStr = messageController.text.trim();

                                final success = await controller.bookVisit(
                                  preferredDate: dateStr,
                                  preferredTime: apiTimeSlot,
                                  purposeOfVisit: purposeStr,
                                  estimatedBudget: budgetStr,
                                  additionalRequirements: requirementsStr,
                                );

                                if (success) {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    "Booking Confirmed!",
                                    "Showroom visit scheduled for $dateStr during $apiTimeSlot.",
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    colorText: const Color(0xFF2E7D32),
                                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(15),
                                    duration: const Duration(seconds: 4),
                                  );
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Confirm Appointment",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectableSlotTile(String slotName, bool isSelected, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paleGold.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.border.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryMaroon : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slotName,
                style: GoogleFonts.outfit(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryMaroon,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
