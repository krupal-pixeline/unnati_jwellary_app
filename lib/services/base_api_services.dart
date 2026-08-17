import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../utils/app_key_names.dart';
import '../utils/app_urls.dart';
import '../utils/other_methods.dart';
import '../view/auth/login/login_screen.dart';
import 'api_logger.dart';

// =====================================================================
//  BaseApiService
//  ────────────────────────────────────────────────────────────────────
//  • Single Dio instance shared by every API service in the app.
//  • Attaches ApiLoggerInterceptor so every request/response/error is
//    printed via OtherMethods.customLog automatically.
//  • Attaches AuthTokenQueuedInterceptor to handle automatic Bearer token
//    injection & 401 Unauthorized token refresh retries.
// =====================================================================

class BaseApiService {
  // ─────────────────────────────────────────
  //  Singleton
  // ─────────────────────────────────────────
  static final BaseApiService _instance = BaseApiService._internal();

  factory BaseApiService() => _instance;

  BaseApiService._internal() {
    _initDio();
  }

  // ─────────────────────────────────────────
  //  Dio instance
  // ─────────────────────────────────────────
  late final Dio _dio;

  // ─────────────────────────────────────────
  //  Initialization
  // ─────────────────────────────────────────
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: _defaultHeaders(),
      ),
    );

    // Attach token refresh & auth queued interceptor
    _dio.interceptors.add(AuthTokenQueuedInterceptor(dio: _dio));

    // Attach the API logger interceptor.
    _dio.interceptors.add(ApiLoggerInterceptor());

    OtherMethods.customLog('✅ BaseApiService → Dio initialized. baseUrl: ${AppUrls.baseUrl}');
  }

  // ─────────────────────────────────────────
  //  Default headers
  // ─────────────────────────────────────────
  Map<String, dynamic> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': AppUrls.apiKey,
    };
  }

  // ─────────────────────────────────────────
  //  Merged headers helper
  //  Merges [extraHeaders] on top of defaults.
  // ─────────────────────────────────────────
  Map<String, dynamic> _mergedHeaders(Map<String, dynamic>? extraHeaders) {
    final headers = Map<String, dynamic>.from(_defaultHeaders());

    final storedToken = OtherMethods.getStorage(AppKeyNames.bearerToken);
    if (storedToken != null && storedToken.toString().isNotEmpty) {
      headers['Authorization'] = 'Bearer $storedToken';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  // ─────────────────────────────────────────
  //  Error handler
  // ─────────────────────────────────────────
  Exception _handleDioError(String apiName, DioException e) {
    OtherMethods.customLog('❌ [$apiName] DioException → type: ${e.type}');
    OtherMethods.customLog('❌ [$apiName] message: ${e.message}');
    OtherMethods.customLog('❌ [$apiName] response: ${e.response?.data}');

    // Prefer server message, fall back to Dio message, fall back to generic.
    final serverMessage =
        e.response?.data is Map ? e.response?.data['message'] as String? : null;

    final displayMessage = serverMessage ?? e.message ?? 'Something went wrong. Please try again.';

    return Exception(displayMessage);
  }

  // =====================================================================
  //  GET
  // =====================================================================
  Future<Map<String, dynamic>> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? extraHeaders,
    String apiName = 'GET_REQUEST',
  }) async {
    try {
      OtherMethods.customLog('🌐 [$apiName] GET → $url');

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: _mergedHeaders(extraHeaders),
          extra: {'apiName': apiName},
        ),
      );

      return _parseResponse(apiName, response);
    } on DioException catch (e) {
      throw _handleDioError(apiName, e);
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Unexpected error: $e');
      throw Exception('Unexpected error occurred. Please try again.');
    }
  }

  // =====================================================================
  //  POST
  // =====================================================================
  Future<Map<String, dynamic>> postRequest({
    required String url,
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? extraHeaders,
    String apiName = 'POST_REQUEST',
  }) async {
    try {
      OtherMethods.customLog('🌐 [$apiName] POST → $url');
      OtherMethods.customLog('📤 [$apiName] Body → $body');

      final response = await _dio.post(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(
          headers: _mergedHeaders(extraHeaders),
          extra: {'apiName': apiName},
        ),
      );

      return _parseResponse(apiName, response);
    } on DioException catch (e) {
      throw _handleDioError(apiName, e);
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Unexpected error: $e');
      throw Exception('Unexpected error occurred. Please try again.');
    }
  }

  // =====================================================================
  //  PUT
  // =====================================================================
  Future<Map<String, dynamic>> putRequest({
    required String url,
    dynamic body,
    Map<String, dynamic>? extraHeaders,
    String apiName = 'PUT_REQUEST',
  }) async {
    try {
      OtherMethods.customLog('🌐 [$apiName] PUT → $url');
      OtherMethods.customLog('📤 [$apiName] Body → $body');

      final response = await _dio.put(
        url,
        data: body,
        options: Options(
          headers: _mergedHeaders(extraHeaders),
          extra: {'apiName': apiName},
        ),
      );

      return _parseResponse(apiName, response);
    } on DioException catch (e) {
      throw _handleDioError(apiName, e);
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Unexpected error: $e');
      throw Exception('Unexpected error occurred. Please try again.');
    }
  }

  // =====================================================================
  //  PATCH
  // =====================================================================
  Future<Map<String, dynamic>> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? extraHeaders,
    String apiName = 'PATCH_REQUEST',
  }) async {
    try {
      OtherMethods.customLog('🌐 [$apiName] PATCH → $url');
      OtherMethods.customLog('📤 [$apiName] Body → $body');

      final response = await _dio.patch(
        url,
        data: body,
        options: Options(
          headers: _mergedHeaders(extraHeaders),
          extra: {'apiName': apiName},
        ),
      );

      return _parseResponse(apiName, response);
    } on DioException catch (e) {
      throw _handleDioError(apiName, e);
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Unexpected error: $e');
      throw Exception('Unexpected error occurred. Please try again.');
    }
  }

  // =====================================================================
  //  DELETE
  // =====================================================================
  Future<Map<String, dynamic>> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? extraHeaders,
    String apiName = 'DELETE_REQUEST',
  }) async {
    try {
      OtherMethods.customLog('🌐 [$apiName] DELETE → $url');

      final response = await _dio.delete(
        url,
        data: body,
        options: Options(
          headers: _mergedHeaders(extraHeaders),
          extra: {'apiName': apiName},
        ),
      );

      return _parseResponse(apiName, response);
    } on DioException catch (e) {
      throw _handleDioError(apiName, e);
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Unexpected error: $e');
      throw Exception('Unexpected error occurred. Please try again.');
    }
  }

  // ─────────────────────────────────────────
  //  Response parser
  //  Validates that the response body is a
  //  Map<String, dynamic> and returns it.
  // ─────────────────────────────────────────
  Map<String, dynamic> _parseResponse(String apiName, Response response) {
    OtherMethods.customLog('✅ [$apiName] Status: ${response.statusCode}');

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    // Unexpected payload shape – log and throw.
    OtherMethods.customLog('⚠️ [$apiName] Unexpected response type: ${data.runtimeType}');
    throw Exception('Unexpected response format from server.');
  }
}

// =====================================================================
//  AuthTokenQueuedInterceptor
//  ────────────────────────────────────────────────────────────────────
//  • Automatically attaches `Authorization: Bearer <token>` to requests.
//  • Intercepts 401 Unauthorized responses and attempts to refresh the
//    access token using stored `refreshToken`.
//  • Retries failed requests seamlessly on successful refresh.
//  • Navigates to LoginScreen if token refresh fails.
// =====================================================================
class AuthTokenQueuedInterceptor extends QueuedInterceptor {
  final Dio dio;

  AuthTokenQueuedInterceptor({required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey('Authorization')) {
      final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
      if (token != null && token.toString().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    if (response?.statusCode == 401 &&
        !err.requestOptions.path.contains('customers/refresh-token')) {
      OtherMethods.customLog(
          '⚠️ [AuthInterceptor] 401 Unauthorized detected on ${err.requestOptions.path}. Refreshing token...');

      final refreshToken = OtherMethods.getStorage(AppKeyNames.refreshToken);

      if (refreshToken != null && refreshToken.toString().isNotEmpty) {
        try {
          // Dedicated Dio instance to execute refresh call without triggering interceptors recursively
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: AppUrls.baseUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'x-api-key': AppUrls.apiKey,
              },
            ),
          );

          final refreshResponse = await refreshDio.post(
            'customers/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          final data = refreshResponse.data;
          final newToken = (data is Map)
              ? (data['token'] as String? ?? data['data']?['token'] as String?)
              : null;
          final newRefreshToken = (data is Map)
              ? (data['refreshToken'] as String? ??
                  data['data']?['refreshToken'] as String?)
              : null;

          if (newToken != null && newToken.isNotEmpty) {
            await OtherMethods.setStorage(
                key: AppKeyNames.bearerToken, value: newToken);
            OtherMethods.customLog(
                '💾 [AuthInterceptor] Access token refreshed & saved.');

            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await OtherMethods.setStorage(
                  key: AppKeyNames.refreshToken, value: newRefreshToken);
              OtherMethods.customLog(
                  '💾 [AuthInterceptor] Refresh token refreshed & saved.');
            }

            // Retry original request with new token
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          }
        } catch (refreshErr) {
          OtherMethods.customLog(
              '❌ [AuthInterceptor] Token refresh failed: $refreshErr');
        }
      }

      // If refresh failed or no refresh token exists, clear session & go to login
      OtherMethods.customLog(
          '🔴 [AuthInterceptor] Session expired or invalid. Redirecting to LoginScreen...');
      await OtherMethods.clearStorage();
      Get.offAll(() => const LoginScreen());
    }

    return handler.next(err);
  }
}
