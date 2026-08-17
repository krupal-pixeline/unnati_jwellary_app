// ============================================================
//  Unnati — Profile Models
// ============================================================

class CustomerProfile {
  final String id;
  String fullName;
  String mobileNumber;
  String emailAddress;
  String dateOfBirth;
  String anniversaryDate;
  String city;
  final String referralCode;
  final String? profileImageUrl;
  final DateTime registeredAt;

  CustomerProfile({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.dateOfBirth,
    required this.anniversaryDate,
    required this.city,
    required this.referralCode,
    this.profileImageUrl,
    required this.registeredAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    // Parse DOB ISO string to human readable format (YYYY-MM-DD)
    String rawDob = json['dob'] as String? ?? '';
    if (rawDob.contains('T')) {
      try {
        final dt = DateTime.parse(rawDob).toLocal();
        rawDob = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    // Parse Anniversary Date ISO string
    String rawAnniversary = json['anniversaryDate'] as String? ?? '';
    if (rawAnniversary.contains('T')) {
      try {
        final dt = DateTime.parse(rawAnniversary).toLocal();
        rawAnniversary = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return CustomerProfile(
      id: json['_id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      dateOfBirth: rawDob,
      anniversaryDate: rawAnniversary,
      city: json['city'] as String? ?? '',
      referralCode: json['referralCode'] as String? ?? '',
      profileImageUrl: json['profilePhoto'] as String?,
      registeredAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
      'dob': dateOfBirth,
      'anniversaryDate': anniversaryDate,
      'city': city,
      'referralCode': referralCode,
      'profilePhoto': profileImageUrl,
      'createdAt': registeredAt.toIso8601String(),
    };
  }


  CustomerProfile copyWith({
    String? fullName,
    String? mobileNumber,
    String? emailAddress,
    String? dateOfBirth,
    String? anniversaryDate,
    String? city,
    String? profileImageUrl,
  }) {
    return CustomerProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      city: city ?? this.city,
      referralCode: referralCode,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      registeredAt: registeredAt,
    );
  }
}

// ── Address ─────────────────────────────────────────────────
class CustomerAddress {
  final String id;
  String label;       // e.g. Home, Office, Other
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String pincode;
  bool isDefault;

  CustomerAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });
}

// ── Appointment ─────────────────────────────────────────────
enum AppointmentStatus { confirmed, completed, cancelled, pending }

class AppointmentHistory {
  final String id;
  final String purpose;
  final String date;
  final String timeSlot;
  final AppointmentStatus status;
  final String? notes;

  const AppointmentHistory({
    required this.id,
    required this.purpose,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
  });

  factory AppointmentHistory.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'pending').toLowerCase();
    AppointmentStatus statusEnum;
    if (statusStr == 'confirmed') {
      statusEnum = AppointmentStatus.confirmed;
    } else if (statusStr == 'completed') {
      statusEnum = AppointmentStatus.completed;
    } else if (statusStr == 'cancelled') {
      statusEnum = AppointmentStatus.cancelled;
    } else {
      statusEnum = AppointmentStatus.pending;
    }

    String rawDate = json['preferredDate'] ?? json['date'] ?? json['dateTime'] ?? json['appointmentDate'] ?? '';
    if (rawDate.contains('T')) {
      try {
        final dt = DateTime.parse(rawDate).toLocal();
        rawDate = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
      } catch (_) {}
    }

    final budget = json['estimatedBudget'] as String? ?? '';
    final requirements = json['additionalRequirements'] as String? ?? '';
    String? constructedNotes;
    if (budget.isNotEmpty || requirements.isNotEmpty) {
      final List<String> parts = [];
      if (budget.isNotEmpty) {
        parts.add('Budget: $budget');
      }
      if (requirements.isNotEmpty) {
        parts.add('Note: $requirements');
      }
      constructedNotes = parts.join('  •  ');
    }

    return AppointmentHistory(
      id: json['_id'] as String? ?? '',
      purpose: json['purposeOfVisit'] as String? ?? json['purpose'] as String? ?? 'Jewellery Consultation',
      date: rawDate.isNotEmpty ? rawDate : 'TBD',
      timeSlot: json['preferredTime'] as String? ?? json['timeSlot'] as String? ?? json['time'] as String? ?? 'TBD',
      status: statusEnum,
      notes: constructedNotes,
    );
  }
}

// ── Referral Wallet ─────────────────────────────────────────
enum CommissionStatus { pending, approved, rejected, reversed }

class WalletTransaction {
  final String id;
  final String referredCustomerName;
  final double invoiceValue;
  final double commissionAmount;
  final CommissionStatus status;
  final DateTime date;
  final String type;
  final String description;

  const WalletTransaction({
    required this.id,
    required this.referredCustomerName,
    required this.invoiceValue,
    required this.commissionAmount,
    required this.status,
    required this.date,
    this.type = 'earn',
    this.description = '',
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'earn';
    final amount = (json['amount'] as num? ?? 0).toDouble();
    return WalletTransaction(
      id: json['_id'] as String? ?? '',
      referredCustomerName: json['description'] as String? ?? (typeStr == 'earn' ? 'Earned Bonus' : 'Redeemed Coins'),
      invoiceValue: 0,
      commissionAmount: amount,
      status: typeStr == 'earn' ? CommissionStatus.approved : CommissionStatus.reversed,
      date: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      type: typeStr,
      description: json['description'] as String? ?? '',
    );
  }
}

class ReferralWallet {
  final double approvedBalance;
  final double pendingBalance;
  final double reversedAmount;
  final double totalLifetimeEarning;
  final List<WalletTransaction> transactions;

  const ReferralWallet({
    required this.approvedBalance,
    required this.pendingBalance,
    required this.reversedAmount,
    required this.totalLifetimeEarning,
    required this.transactions,
  });

  factory ReferralWallet.fromJson(Map<String, dynamic> json) {
    final balance = (json['walletBalance'] as num? ?? 0).toDouble();
    final logsList = json['walletLogs'] as List? ?? [];
    final txns = logsList.map((x) => WalletTransaction.fromJson(x as Map<String, dynamic>)).toList();

    double lifetime = 0;
    for (final t in txns) {
      if (t.type == 'earn') {
        lifetime += t.commissionAmount;
      }
    }

    return ReferralWallet(
      approvedBalance: balance,
      pendingBalance: 0,
      reversedAmount: 0,
      totalLifetimeEarning: lifetime,
      transactions: txns,
    );
  }
}

// ── Referral Chain (single-level) ───────────────────────────
class ReferredUser {
  final String id;
  final String name;
  final String city;
  final DateTime joinedAt;
  final int totalPurchases;
  final double totalCommissionGenerated;

  const ReferredUser({
    required this.id,
    required this.name,
    required this.city,
    required this.joinedAt,
    required this.totalPurchases,
    required this.totalCommissionGenerated,
  });
}
