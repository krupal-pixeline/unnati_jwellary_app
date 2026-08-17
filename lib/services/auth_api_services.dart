import '../model/auth/login_model.dart';
import '../model/auth/register_model.dart';
import '../model/auth/verify_otp_model.dart';
import '../utils/app_key_names.dart';
import '../utils/app_urls.dart';
import '../utils/other_methods.dart';
import 'base_api_services.dart';


class AuthApiService {

  static final AuthApiService _instance = AuthApiService._internal();

  factory AuthApiService() => _instance;

  AuthApiService._internal();


  final BaseApiService _baseApi = BaseApiService();

  Future<LoginModel> login({required String mobileNumber}) async {
    const String apiName = 'AUTH_LOGIN';

    try {
      OtherMethods.customLog('🔐 [$apiName] Requesting OTP for → $mobileNumber');

      final Map<String, dynamic> body = {
        'mobileNumber': mobileNumber,
      };

      final Map<String, dynamic> responseJson = await _baseApi.postRequest(
        url: AppUrls.login,
        body: body,
        apiName: apiName,
      );

      final LoginModel loginModel = LoginModel.fromJson(responseJson);

      OtherMethods.customLog(' [$apiName] Success → ${loginModel.message}');
      OtherMethods.customLog(' [$apiName] Customer → ${loginModel.customer}');

      return loginModel;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  Future<VerifyOtpModel> verifyOtp({
    required String mobileNumber,
    required String otp,
    String fcmToken = '',
  }) async {
    const String apiName = 'AUTH_VERIFY_OTP';

    try {
      OtherMethods.customLog('🔑 [$apiName] Verifying OTP for → $mobileNumber');

      final Map<String, dynamic> body = {
        'mobileNumber': mobileNumber,
        'otp': otp,
        'fcmToken': fcmToken,
      };

      final Map<String, dynamic> responseJson = await _baseApi.postRequest(
        url: AppUrls.verifyOtp,
        body: body,
        apiName: apiName,
      );

      final VerifyOtpModel verifyOtpModel = VerifyOtpModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success → ${verifyOtpModel.message}');
      OtherMethods.customLog('🎫 [$apiName] Token received → ${verifyOtpModel.token != null ? 'YES' : 'NO'}');
      OtherMethods.customLog('👤 [$apiName] Customer → ${verifyOtpModel.customer}');

      return verifyOtpModel;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  Future<RegisterModel> register({
    required String fullName,
    required String mobileNumber,
    required String emailAddress,
    required DateTime dob,
    DateTime? anniversaryDate,
    required String city,
    required String state,
    String? referralCode,
  }) async {
    const String apiName = 'AUTH_REGISTER';

    try {
      OtherMethods.customLog('📝 [$apiName] Registering customer → $mobileNumber');
      OtherMethods.customLog('📝 [$apiName] Full Name  → $fullName');
      OtherMethods.customLog('📝 [$apiName] DOB        → ${_formatDateForApi(dob)}');

      // Build request body – dates MUST be in YYYY-MM-DD format.
      final Map<String, dynamic> body = {
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'emailAddress': emailAddress,
        'dob': _formatDateForApi(dob),
        'city': city,
        'state': state,
      };

      // anniversaryDate is optional – only include when provided.
      if (anniversaryDate != null) {
        body['anniversaryDate'] = _formatDateForApi(anniversaryDate);
        OtherMethods.customLog('📝 [$apiName] Anniversary → ${_formatDateForApi(anniversaryDate)}');
      }

      // referralCode is optional – only include when provided and non-empty.
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        body['referralCode'] = referralCode.trim().toUpperCase();
        OtherMethods.customLog('📝 [$apiName] Referral Code → ${referralCode.trim().toUpperCase()}');
      }

      OtherMethods.customLog('📤 [$apiName] Request Body → $body');

      final Map<String, dynamic> responseJson = await _baseApi.postRequest(
        url: AppUrls.register,
        body: body,
        apiName: apiName,
      );

      final RegisterModel registerModel = RegisterModel.fromJson(responseJson);

      OtherMethods.customLog('✅ [$apiName] Success → ${registerModel.message}');
      OtherMethods.customLog('👤 [$apiName] Customer → ${registerModel.customer}');
      OtherMethods.customLog('🆔 [$apiName] Customer ID Code → ${registerModel.customer?.customerIdCode}');

      return registerModel;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }


  String _formatDateForApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day'; // e.g. "1995-05-15"
  }


  Future<Map<String, dynamic>> resendOtp({
    required String mobileNumber,
  }) async {
    const String apiName = 'AUTH_RESEND_OTP';

    try {
      OtherMethods.customLog('🔄 [$apiName] Resending OTP for → $mobileNumber');

      final Map<String, dynamic> body = {
        'mobileNumber': mobileNumber,
      };

      final Map<String, dynamic> responseJson = await _baseApi.postRequest(
        url: AppUrls.resendOtp,
        body: body,
        apiName: apiName,
      );

      final bool success = responseJson['success'] as bool? ?? false;
      final String message = responseJson['message'] as String? ?? '';

      OtherMethods.customLog('✅ [$apiName] Success: $success → $message');

      return responseJson;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  /// PUT  – Update Customer FCM Token
  Future<Map<String, dynamic>> updateFcmToken({
    required String fcmToken,
  }) async {
    const String apiName = 'UPDATE_FCM_TOKEN';

    try {
      final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
      Map<String, dynamic>? extraHeaders;
      if (token != null && token.toString().isNotEmpty) {
        extraHeaders = {'Authorization': 'Bearer $token'};
      }

      OtherMethods.customLog('🔥 [$apiName] Updating FCM Token → $fcmToken');

      final Map<String, dynamic> body = {
        'fcmToken': fcmToken,
      };

      final Map<String, dynamic> responseJson = await _baseApi.putRequest(
        url: AppUrls.updateFcmToken,
        body: body,
        extraHeaders: extraHeaders,
        apiName: apiName,
      );

      final bool success = responseJson['success'] as bool? ?? false;
      final String message = responseJson['message'] as String? ?? '';

      OtherMethods.customLog('✅ [$apiName] Success: $success → $message');

      return responseJson;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }

  /// POST  – Refresh Access Token using Refresh Token
  Future<Map<String, dynamic>> refreshTokenApi({
    required String refreshToken,
  }) async {
    const String apiName = 'AUTH_REFRESH_TOKEN';

    try {
      OtherMethods.customLog('🔄 [$apiName] Refreshing token...');

      final Map<String, dynamic> body = {
        'refreshToken': refreshToken,
      };

      final Map<String, dynamic> responseJson = await _baseApi.postRequest(
        url: AppUrls.refreshToken,
        body: body,
        apiName: apiName,
      );

      final String? newToken = responseJson['token'] as String? ?? responseJson['data']?['token'] as String?;
      final String? newRefreshToken = responseJson['refreshToken'] as String? ?? responseJson['data']?['refreshToken'] as String?;

      if (newToken != null && newToken.isNotEmpty) {
        await OtherMethods.setStorage(key: AppKeyNames.bearerToken, value: newToken);
        OtherMethods.customLog('💾 [$apiName] New Access Token saved to storage.');
      }

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await OtherMethods.setStorage(key: AppKeyNames.refreshToken, value: newRefreshToken);
        OtherMethods.customLog('💾 [$apiName] New Refresh Token saved to storage.');
      }

      return responseJson;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error → $e');
      rethrow;
    }
  }
}
