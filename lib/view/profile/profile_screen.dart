import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unnati_jwelers/view/profile/profile_controller.dart';
import 'package:unnati_jwelers/view/profile/profile_model.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already bound
    final ctrl = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Obx(() {
        if (ctrl.isProfileLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          );
        }
        if (ctrl.profileError.value.isNotEmpty) {
          return _ErrorView(
            message: ctrl.profileError.value,
            onRetry: ctrl.fetchAllProfileData,
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryMaroon,
          onRefresh: () => ctrl.fetchAllProfileData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _ProfileHeaderBlock(ctrl: ctrl)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Customer Info Card ──────────────────
                      _ProfileInfoCard(ctrl: ctrl),
                      const SizedBox(height: 24),

                      // ── Appointment History ─────────────────
                      _SectionTitle(
                        title: 'Appointment History',
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 12),
                      _AppointmentList(ctrl: ctrl),
                      const SizedBox(height: 24),

                      // ── Referral Wallet ─────────────────────
                      _SectionTitle(
                        title: 'Referral Wallet',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 12),
                      _ReferralWalletCard(ctrl: ctrl),
                      const SizedBox(height: 24),

                      // ── Referral Chain ──────────────────────
                      // _SectionTitle(
                      //   title: 'My Referral Network',
                      //   icon: Icons.people_outline,
                      // ),
                      // const SizedBox(height: 12),
                      // _ReferralChainSection(ctrl: ctrl),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeaderBlock extends StatelessWidget {
  final ProfileController ctrl;
  const _ProfileHeaderBlock({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMaroon,
            AppColors.maroonDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 28, top: 24),
      child: Obx(() {
        final p = ctrl.profile.value;
        if (p == null) return const SizedBox.shrink();
        return Column(
          children: [
            const SizedBox(height: 12),
            // Premium Solid Gold Border Avatar (No double-ring gaps)
            Obx(
              () => GestureDetector(
                onTap: ctrl.isSavingProfile.value
                    ? null
                    : ctrl.showPhotoSelectionBottomSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37), // Solid Luxury Gold Border
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Obx(() {
                          if (ctrl.isSavingProfile.value) {
                            return Container(
                              color: Colors.black38,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD4AF37),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          }
                          final localPath = ctrl.selectedImagePath.value;
                          final imageUrl = p.profileImageUrl;

                          if (localPath.isNotEmpty) {
                            return Image.file(
                              File(localPath),
                              fit: BoxFit.cover,
                            );
                          } else if (imageUrl != null && imageUrl.isNotEmpty) {
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _fallbackAvatar(p.fullName),
                            );
                          } else {
                            return _fallbackAvatar(p.fullName);
                          }
                        }),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 2, bottom: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ctrl.isSavingProfile.value
                          ? const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.primaryMaroon,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: AppColors.primaryMaroon,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              p.fullName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              p.mobileNumber,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // VIP Gold Referral Invite Code Glassmorphic Badge
            if (p.referralCode.isNotEmpty)
              GestureDetector(
                onTap: ctrl.copyReferralCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08), // Elegant glass fill
                    border: Border.all(
                      color: const Color(0xFFD4AF37), // Luxury gold outline
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.referralCode,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _fallbackAvatar(String? name) {
    return Container(
      color: AppColors.backgroundPrimary,
      alignment: Alignment.center,
      child: Text(
        name != null && name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.cinzel(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryMaroon,
        ),
      ),
    );
  }
}

  // ── Profile Info Card (View / Edit) ─────────────────────────
class _ProfileInfoCard extends StatelessWidget {
  final ProfileController ctrl;
  const _ProfileInfoCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: ctrl.isEditMode.value
            ? _EditProfileForm(ctrl: ctrl)
            : _ViewProfileDetails(ctrl: ctrl),
      ),
    );
  }
}

class _ViewProfileDetails extends StatelessWidget {
  final ProfileController ctrl;
  const _ViewProfileDetails({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final p = ctrl.profile.value;
    if (p == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, color: AppColors.primaryMaroon, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: ctrl.enterEditMode,
              icon: const Icon(Icons.edit_rounded, size: 14, color: AppColors.primaryGold),
              label: Text(
                'Edit',
                style: GoogleFonts.outfit(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Mobile',
          value: p.mobileNumber,
        ),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email Address',
          value: p.emailAddress,
        ),
        _InfoRow(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: p.dateOfBirth,
        ),
        _InfoRow(
          icon: Icons.favorite_border,
          label: 'Anniversary Date',
          value: p.anniversaryDate,
        ),
        _InfoRow(
          icon: Icons.location_city_outlined,
          label: 'City',
          value: p.city,
        ),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Member Since',
          value: '${p.registeredAt.day} ${_monthName(p.registeredAt.month)} ${p.registeredAt.year}',
          showDivider: false,
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class _EditProfileForm extends StatelessWidget {
  final ProfileController ctrl;
  const _EditProfileForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ctrl.profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Edit Profile', Icons.edit_outlined),
          const SizedBox(height: 16),
          _UnnatiTextField(
            controller: ctrl.nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: ctrl.validateName,
          ),
          const SizedBox(height: 14),
          // Mobile — read only
          _UnnatiTextField(
            controller: TextEditingController(
              text: ctrl.profile.value?.mobileNumber ?? '',
            ),
            label: 'Mobile Number',
            icon: Icons.phone_outlined,
            readOnly: true,
            helperText: 'Mobile number cannot be changed.',
          ),
          const SizedBox(height: 14),
          _UnnatiTextField(
            controller: ctrl.emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: ctrl.validateEmail,
          ),
          const SizedBox(height: 14),
          _UnnatiTextField(
            controller: ctrl.dobController,
            label: 'Date of Birth',
            icon: Icons.cake_outlined,
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => ctrl.selectDate(context, isDob: true),
          ),
          const SizedBox(height: 14),
          _UnnatiTextField(
            controller: ctrl.anniversaryController,
            label: 'Anniversary Date',
            icon: Icons.favorite_border,
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => ctrl.selectDate(context, isDob: false),
          ),
          const SizedBox(height: 14),
          _UnnatiTextField(
            controller: ctrl.cityController,
            label: 'City',
            icon: Icons.location_city_outlined,
            validator: ctrl.validateCity,
          ),
          const SizedBox(height: 20),
          // Warning Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mobile number cannot be changed. Contact support if needed.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.cancelEditMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: ctrl.isSavingProfile.value
                        ? null
                        : ctrl.saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: ctrl.isSavingProfile.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Appointment History ──────────────────────────────────────
class _AppointmentList extends StatelessWidget {
  final ProfileController ctrl;
  const _AppointmentList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isAppointmentLoading.value) {
        return const _ShimmerList(count: 3);
      }
      if (ctrl.appointmentError.value.isNotEmpty) {
        return _ErrorState(message: ctrl.appointmentError.value);
      }
      if (ctrl.appointments.isEmpty) {
        return _EmptyState(
          message: 'No appointments booked yet.',
          icon: Icons.event_busy_outlined,
        );
      }
      return Column(
        children: ctrl.appointments
            .map(
              (apt) => _AppointmentTile(
                appointment: apt,
                statusLabel: ctrl.appointmentStatusLabel(apt.status),
              ),
            )
            .toList(),
      );
    });
  }
}

class _AppointmentTile extends StatelessWidget {
  final AppointmentHistory appointment;
  final String statusLabel;
  const _AppointmentTile({
    required this.appointment,
    required this.statusLabel,
  });

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return AppColors.pending;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.pending:
        return AppColors.warning;
    }
  }

  Color _statusBgColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return AppColors.pendingLight;
      case AppointmentStatus.completed:
        return AppColors.successLight;
      case AppointmentStatus.cancelled:
        return AppColors.errorLight;
      case AppointmentStatus.pending:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.goldDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.purpose,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.date}  •  ${appointment.timeSlot}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (appointment.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBgColor(appointment.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor(appointment.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Referral Wallet Card ─────────────────────────────────────
class _ReferralWalletCard extends StatelessWidget {
  final ProfileController ctrl;
  const _ReferralWalletCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isWalletLoading.value) {
        return const _ShimmerList(count: 2);
      }
      if (ctrl.walletError.value.isNotEmpty) {
        return _ErrorState(message: ctrl.walletError.value);
      }
      final w = ctrl.wallet.value;
      if (w == null) return const SizedBox.shrink();

      return Column(
        children: [
          // Wallet Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Referral Wallet',
                          style: TextStyle(
                            color: AppColors.textOnDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Redeemable at store only',
                          style: TextStyle(
                            color: AppColors.grey.withOpacity(0.8),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '₹${w.approvedBalance.toInt()}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Transactions
          ...w.transactions.map(
            (txn) => _TransactionTile(
              txn: txn,
              statusLabel: ctrl.commissionStatusLabel(txn.status),
            ),
          ),
        ],
      );
    });
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction txn;
  final String statusLabel;
  const _TransactionTile({required this.txn, required this.statusLabel});

  Color _statusColor(CommissionStatus s) {
    switch (s) {
      case CommissionStatus.approved:
        return AppColors.approved;
      case CommissionStatus.pending:
        return AppColors.warning;
      case CommissionStatus.rejected:
        return AppColors.rejected;
      case CommissionStatus.reversed:
        return AppColors.reversed;
    }
  }

  Color _statusBg(CommissionStatus s) {
    switch (s) {
      case CommissionStatus.approved:
        return AppColors.successLight;
      case CommissionStatus.pending:
        return AppColors.warningLight;
      case CommissionStatus.rejected:
        return AppColors.errorLight;
      case CommissionStatus.reversed:
        return const Color(0xFFF3E5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              color: AppColors.goldDark,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.referredCustomerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Date •  ${txn.date.day}/${txn.date.month}/${txn.date.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ ₹${txn.commissionAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textGold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusBg(txn.status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(txn.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Referral Chain Section ───────────────────────────────────
class _ReferralChainSection extends StatelessWidget {
  final ProfileController ctrl;
  const _ReferralChainSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isChainLoading.value) {
        return const _LoadingRow();
      }
      if (ctrl.referredUsers.isEmpty) {
        return _EmptyState(
          message: 'No referrals yet. Share your code and start earning!',
          icon: Icons.group_add_outlined,
        );
      }
      return Column(
        children: [
          // Summary row
          Row(
            children: [
              _ChainStat(
                label: 'Total Referred',
                value: '${ctrl.referredUsers.length}',
                icon: Icons.people,
              ),
              const SizedBox(width: 10),
              _ChainStat(
                label: 'Active Buyers',
                value:
                    '${ctrl.referredUsers.where((u) => u.totalPurchases > 0).length}',
                icon: Icons.shopping_bag_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Chain visual
          ...ctrl.referredUsers.asMap().entries.map(
            (entry) => _ReferralUserTile(
              user: entry.value,
              index: entry.key,
              isLast: entry.key == ctrl.referredUsers.length - 1,
            ),
          ),
        ],
      );
    });
  }
}

class _ChainStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ChainStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralUserTile extends StatelessWidget {
  final ReferredUser user;
  final int index;
  final bool isLast;
  const _ReferralUserTile({
    required this.user,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.goldSoft,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${user.city}  •  Joined ${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${user.totalCommissionGenerated.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textGold,
                      ),
                    ),
                    Text(
                      '${user.totalPurchases} purchase${user.totalPurchases != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────

Widget _cardHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: AppColors.primaryMaroon, size: 20),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryMaroon, size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryMaroon, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value.isNotEmpty ? value : 'Not provided',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.border.withOpacity(0.4),
            height: 1,
            thickness: 0.8,
          ),
      ],
    );
  }
}

class _UnnatiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final String? hint;
  final String? helperText;
  final VoidCallback? onTap;

  const _UnnatiTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.hint,
    this.helperText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        helperStyle: const TextStyle(color: AppColors.warning, fontSize: 11),
        filled: true,
        fillColor: readOnly ? AppColors.lightGrey : AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.error, fontSize: 13),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final int count;
  const _ShimmerList({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
