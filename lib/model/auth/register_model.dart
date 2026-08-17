// =====================================================================
// Register Model  –  Response of POST /customers/register
// =====================================================================
// Example Response:
// {
//   "success": true,
//   "message": "Verification OTP code generated successfully.",
//   "otp": "371358",
//   "customer": {
//     "id": "6a55090e838037318fb47db1",
//     "fullName": "Rutvik Vaghela",
//     "mobileNumber": "1234567898",
//     "emailAddress": "rutvik12@gmail.com",
//     "customerIdCode": "UJC000001"
//   }
// }
// =====================================================================

class RegisterModel {
  final bool success;
  final String message;

  /// OTP returned by server (may be null in production environments).
  final String? otp;

  /// Newly created customer summary returned after registration.
  final RegisterCustomerModel? customer;

  const RegisterModel({
    required this.success,
    required this.message,
    this.otp,
    this.customer,
  });

  // -------  Factory from JSON  -------
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      otp: json['otp'] as String?,
      customer: json['customer'] != null
          ? RegisterCustomerModel.fromJson(
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
      'RegisterModel(success: $success, message: $message, otp: $otp, customer: $customer)';
}

// =====================================================================
// RegisterCustomerModel – Customer summary inside RegisterModel
// =====================================================================
class RegisterCustomerModel {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;

  /// Unique customer identifier code e.g. "UJC000001"
  final String customerIdCode;

  const RegisterCustomerModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.customerIdCode,
  });

  factory RegisterCustomerModel.fromJson(Map<String, dynamic> json) {
    return RegisterCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      customerIdCode: json['customerIdCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
      'customerIdCode': customerIdCode,
    };
  }

  @override
  String toString() =>
      'RegisterCustomerModel(id: $id, fullName: $fullName, '
      'mobileNumber: $mobileNumber, emailAddress: $emailAddress, '
      'customerIdCode: $customerIdCode)';
}
