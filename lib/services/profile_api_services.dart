import 'package:dio/dio.dart';
import '../utils/app_key_names.dart';
import '../utils/other_methods.dart';
import '../view/profile/profile_model.dart';
import 'base_api_services.dart';

class ProfileApiService {
  static final ProfileApiService _instance = ProfileApiService._internal();

  factory ProfileApiService() => _instance;

  ProfileApiService._internal();

  final BaseApiService _baseApi = BaseApiService();

  // ── Helper to build extra headers with Bearer token ───────────────────────
  Map<String, dynamic>? _getAuthHeaders() {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    if (token != null && token.toString().isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  // ── GET Profile ────────────────────────────────────────────────────────────
  Future<CustomerProfile> getProfile() async {
    const apiName = 'GET_PROFILE';
    try {
      OtherMethods.customLog('👤 [$apiName] Fetching customer profile...');
      final response = await _baseApi.getRequest(
        url: 'customers/profile',
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final p = CustomerProfile.fromJson(data);
      OtherMethods.customLog('👤 [$apiName] Profile loaded for customer: ${p.fullName}');
      return p;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── PUT Profile (Updates metadata and optional photo) ──────────────────────
  Future<CustomerProfile> updateProfile({
    required String fullName,
    required String emailAddress,
    required String dob,
    required String anniversaryDate,
    required String city,
    String? localImagePath,
  }) async {
    const apiName = 'UPDATE_PROFILE';
    try {
      OtherMethods.customLog('👤 [$apiName] Starting profile update: name=$fullName, email=$emailAddress, city=$city');
      // Build fields
      final fields = <String, dynamic>{
        'fullName': fullName,
        'emailAddress': emailAddress,
        'dob': dob,
        'city': city,
      };

      // Only include anniversary if it is selected and non-empty
      if (anniversaryDate.isNotEmpty) {
        fields['anniversaryDate'] = anniversaryDate;
      }

      dynamic body;

      if (localImagePath != null && localImagePath.isNotEmpty) {
        OtherMethods.customLog('👤 [$apiName] Profile photo chosen for upload: $localImagePath');
        final fileName = localImagePath.split('/').last;
        fields['profilePhoto'] = await MultipartFile.fromFile(
          localImagePath,
          filename: fileName,
        );
        body = FormData.fromMap(fields);
      } else {
        body = fields;
      }

      final response = await _baseApi.putRequest(
        url: 'customers/profile',
        body: body,
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final p = CustomerProfile.fromJson(data);
      OtherMethods.customLog('👤 [$apiName] Profile updated successfully! New photo: ${p.profileImageUrl}');
      return p;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── GET Referrals ─────────────────────────────────────────────────────────
  Future<ReferralWallet> getReferrals() async {
    const apiName = 'GET_REFERRALS';
    try {
      OtherMethods.customLog('👤 [$apiName] Fetching referral transactions & wallet logs...');
      final response = await _baseApi.getRequest(
        url: 'customers/referrals',
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final w = ReferralWallet.fromJson(data);
      OtherMethods.customLog('👤 [$apiName] Referrals loaded! Balance: ₹${w.approvedBalance.toInt()}, logsCount: ${w.transactions.length}');
      return w;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── GET Appointments ───────────────────────────────────────────────────────
  Future<List<AppointmentHistory>> getAppointments() async {
    const apiName = 'GET_APPOINTMENTS';
    try {
      OtherMethods.customLog('👤 [$apiName] Fetching showroom visits appointment history list...');
      final response = await _baseApi.getRequest(
        url: 'customers/appointments',
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final listData = response['data'] as List? ?? [];
      final list = listData
          .map((item) => AppointmentHistory.fromJson(item as Map<String, dynamic>))
          .toList();
      OtherMethods.customLog('👤 [$apiName] Appointments loaded! count: ${list.length}');
      return list;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── POST Book Appointment ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> bookAppointment({
    required String preferredDate,
    required String preferredTime,
    required String purposeOfVisit,
    required String estimatedBudget,
    required String additionalRequirements,
    required String productId,
  }) async {
    const apiName = 'BOOK_APPOINTMENT';
    try {
      OtherMethods.customLog('👤 [$apiName] Booking showroom visit: date=$preferredDate, slot=$preferredTime, purpose=$purposeOfVisit');
      final body = {
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'purposeOfVisit': purposeOfVisit,
        'estimatedBudget': estimatedBudget,
        'additionalRequirements': additionalRequirements,
        'product': productId,
      };

      final response = await _baseApi.postRequest(
        url: 'appointments',
        body: body,
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      OtherMethods.customLog('👤 [$apiName] Showroom visit booked successfully! Response code: ${response['success']}');
      return response;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── PUT FCM Token ─────────────────────────────────────────────────────────
  Future<void> updateFcmToken(String fcmToken) async {
    const apiName = 'UPDATE_FCM_TOKEN';
    try {
      final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
      if (token == null || token.toString().isEmpty) {
        OtherMethods.customLog('ℹ️ [$apiName] User not logged in, skipping server FCM token update.');
        return;
      }

      OtherMethods.customLog('🔔 [$apiName] Updating FCM token on server...');
      final response = await _baseApi.putRequest(
        url: 'customers/fcm-token',
        body: {'fcmToken': fcmToken},
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      OtherMethods.customLog('✅ [$apiName] FCM Token updated successfully: ${response['message']}');
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
    }
  }
}
