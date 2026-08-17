// =====================================================================
// Login Model  –  Response of POST /customers/login
// =====================================================================
// Example Response:
// {
//   "success": true,
//   "message": "Login OTP code generated successfully.",
//   "otp": "813442",
//   "customer": {
//     "id": "6a45319e0da6c04e48db3786",
//     "fullName": "Aarav Mehta",
//     "mobileNumber": "9876543210",
//     "emailAddress": "aarav.mehta@email.com"
//   }
// }
// =====================================================================

class LoginModel {
  final bool success;
  final String message;

  /// OTP returned in development/testing environments (may be null in prod).
  final String? otp;

  /// Basic customer info returned alongside the OTP trigger.
  final LoginCustomerModel? customer;

  const LoginModel({
    required this.success,
    required this.message,
    this.otp,
    this.customer,
  });

  // -------  Factory from JSON  -------
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      otp: json['otp'] as String?,
      customer: json['customer'] != null
          ? LoginCustomerModel.fromJson(
              json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  // -------  toJson  -------
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (otp != null) 'otp': otp,
      if (customer != null) 'customer': customer!.toJson(),
    };
  }

  @override
  String toString() =>
      'LoginModel(success: $success, message: $message, otp: $otp, customer: $customer)';
}

// =====================================================================
// LoginCustomerModel – Basic customer object inside LoginModel
// =====================================================================
class LoginCustomerModel {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;

  const LoginCustomerModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
  });

  factory LoginCustomerModel.fromJson(Map<String, dynamic> json) {
    return LoginCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
    };
  }

  @override
  String toString() =>
      'LoginCustomerModel(id: $id, fullName: $fullName, mobileNumber: $mobileNumber, emailAddress: $emailAddress)';
}
