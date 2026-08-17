import 'dart:io';
import 'package:dio/dio.dart';
import '../model/swarnim/my_scheme_model.dart';
import '../utils/app_key_names.dart';
import '../utils/app_urls.dart';
import '../utils/other_methods.dart';
import 'base_api_services.dart';

class SwarnimSchemeApiService {
  static final SwarnimSchemeApiService _instance =
      SwarnimSchemeApiService._internal();

  factory SwarnimSchemeApiService() => _instance;

  SwarnimSchemeApiService._internal();

  final BaseApiService _baseApi = BaseApiService();

  Map<String, dynamic>? _getAuthHeaders() {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    if (token != null && token.toString().isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  /// POST – Send OTP to Mobile Number for Swarnim Scheme
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    const apiName = 'SWARNIM_SEND_OTP';
    try {
      OtherMethods.customLog(
        '📲 [$apiName] Sending OTP to mobile: $mobileNumber',
      );
      final response = await _baseApi.postRequest(
        url: AppUrls.swarnimSendOtp,
        body: {'mobileNumber': mobileNumber},
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      OtherMethods.customLog('📲 [$apiName] Response: $response');
      return response;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  /// POST – Verify OTP Code for Swarnim Scheme
  Future<Map<String, dynamic>> verifyOtp(
    String mobileNumber,
    String otp,
  ) async {
    const apiName = 'SWARNIM_VERIFY_OTP';
    try {
      OtherMethods.customLog(
        '📲 [$apiName] Verifying OTP for mobile: $mobileNumber, OTP: $otp',
      );
      final response = await _baseApi.postRequest(
        url: AppUrls.swarnimVerifyOtp,
        body: {'mobileNumber': mobileNumber, 'otp': otp},
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      OtherMethods.customLog('📲 [$apiName] Response: $response');
      return response;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  /// POST – Register Swarnim Scheme (Multipart Form Data)
  Future<Map<String, dynamic>> registerScheme({
    required String planType, // 'amount-based' or 'gold-based'
    required String accountHolderName,
    required String emailId,
    required String mobileNumber,
    required File livePhoto,
    required String aadhaarNumber, // e.g. "XXXX-XXXX-8901"
    required String panCardNumber, // e.g. "XXXXX678H"
    required String monthlyAmount,
    required String durationMonths,
    required String address,
    String? goldType, // e.g. "22K"
  }) async {
    const apiName = 'SWARNIM_REGISTER_SCHEME';
    try {
      final fileName = livePhoto.path.split('/').last.split('\\').last;

      final Map<String, dynamic> formMap = {
        'planType': planType,
        'accountHolderName': accountHolderName,
        'emailId': emailId,
        'mobileNumber': mobileNumber,
        'livePhoto': await MultipartFile.fromFile(
          livePhoto.path,
          filename: fileName,
        ),
        'aadhaarNumber': aadhaarNumber,
        'panCardNumber': panCardNumber,
        'monthlyAmount': monthlyAmount,
        'durationMonths': durationMonths,
        'address': address,
      };

      if (goldType != null && goldType.isNotEmpty) {
        formMap['goldType'] = goldType;
      }

      final formData = FormData.fromMap(formMap);

      OtherMethods.customLog(
        '📲 [$apiName] Registering scheme: planType=$planType, name=$accountHolderName, mobile=$mobileNumber, aadhaar=$aadhaarNumber, pan=$panCardNumber, goldType=$goldType',
      );

      final response = await _baseApi.postRequest(
        url: AppUrls.swarnimRegister,
        body: formData,
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      OtherMethods.customLog('📲 [$apiName] Response: $response');
      return response;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  /// GET – Fetch My Active Swarnim Schemes List
  Future<MySchemesResponse> getMySchemes() async {
    const apiName = 'SWARNIM_GET_MY_SCHEMES';
    try {
      OtherMethods.customLog('📲 [$apiName] Fetching my active schemes...');
      final responseJson = await _baseApi.getRequest(
        url: AppUrls.swarnimMySchemes,
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final mySchemesRes = MySchemesResponse.fromJson(responseJson);
      OtherMethods.customLog('✅ [$apiName] Loaded ${mySchemesRes.data.length} schemes successfully.');
      return mySchemesRes;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  /// GET – Fetch Single Swarnim Scheme Details by ID
  Future<MySchemeModel> getSchemeDetails(String schemeId) async {
    const apiName = 'SWARNIM_GET_SCHEME_DETAILS';
    try {
      OtherMethods.customLog('📲 [$apiName] Fetching details for scheme: $schemeId');
      final responseJson = await _baseApi.getRequest(
        url: '${AppUrls.baseUrl}swarnim-schemes/$schemeId',
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final dataMap = responseJson['data'] as Map<String, dynamic>? ?? responseJson;
      final model = MySchemeModel.fromJson(dataMap);
      OtherMethods.customLog('✅ [$apiName] Scheme details loaded for: ${model.schemeIdCode}');
      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }
}
