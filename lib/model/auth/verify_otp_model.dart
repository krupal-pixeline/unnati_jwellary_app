// =====================================================================
// Verify OTP Model  –  Response of POST /customers/verify-otp
// =====================================================================
// Example Response:
// {
//   "success": true,
//   "message": "Mobile number verified successfully.",
//   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
//   "customer": {
//     "id": "6a45319e0da6c04e48db3786",
//     "fullName": "Aarav Mehta",
//     "mobileNumber": "9876543210",
//     "emailAddress": "aarav.mehta@email.com",
//     "referralCode": "UNN-53FS8A",
//     "referredBy": null,
//     "walletBalance": 0,
//     "isVerified": true,
//     "fcmToken": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
//   }
// }
// =====================================================================

class VerifyOtpModel {
  final bool success;
  final String message;

  /// JWT bearer token to be stored and sent in subsequent authenticated requests.
  final String? token;

  /// Refresh token to obtain new access tokens when expired.
  final String? refreshToken;

  /// Full customer profile returned after successful OTP verification.
  final VerifyOtpCustomerModel? customer;

  const VerifyOtpModel({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.customer,
  });

  // -------  Factory from JSON  -------
  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      customer: json['customer'] != null
          ? VerifyOtpCustomerModel.fromJson(
              json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  // -------  toJson  -------
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (customer != null) 'customer': customer!.toJson(),
    };
  }

  @override
  String toString() =>
      'VerifyOtpModel(success: $success, message: $message, token: $token, refreshToken: $refreshToken, customer: $customer)';
}

// =====================================================================
// VerifyOtpCustomerModel – Full customer profile inside VerifyOtpModel
// =====================================================================
class VerifyOtpCustomerModel {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;
  final String? referralCode;
  final String? referredBy;
  final double walletBalance;
  final bool isVerified;
  final String? fcmToken;

  const VerifyOtpCustomerModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    this.referralCode,
    this.referredBy,
    required this.walletBalance,
    required this.isVerified,
    this.fcmToken,
  });

  factory VerifyOtpCustomerModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'walletBalance': walletBalance,
      'isVerified': isVerified,
      'fcmToken': fcmToken,
    };
  }

  @override
  String toString() => 'VerifyOtpCustomerModel(id: $id, fullName: $fullName, '
      'mobileNumber: $mobileNumber, emailAddress: $emailAddress, '
      'referralCode: $referralCode, walletBalance: $walletBalance, '
      'isVerified: $isVerified)';
}
