import 'package:dio/dio.dart';

import '../utils/other_methods.dart';

class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final apiName = options.extra["apiName"] ?? "";

    options.extra["startTime"] = DateTime.now();

    OtherMethods.customLog("\n==================== ON_REQUEST API Name = $apiName ========================= :");
    OtherMethods.customLog("🚀 REQUEST: ${options.method} ${options.uri} :");
    OtherMethods.customLog("🧩 HEADERS: ${options.headers} :");
    OtherMethods.customLog("📦 BODY: ${options.data} :");
    OtherMethods.customLog("📅 REQUEST TIME: ${options.extra["startTime"]} :");

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final apiName = response.requestOptions.extra["apiName"] ?? "UNKNOWN_API";
    final startTime = response.requestOptions.extra["startTime"];

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;

    OtherMethods.customLog("\n==================== ON_RESPONSE API Name = $apiName ========================= :");
    OtherMethods.customLog("⏱️ TIME: ${duration}ms");
    OtherMethods.customLog("📅 TIMESTAMP: $startTime -> $endTime :");
    OtherMethods.customLog("🔙 RESPONSE: ${response.statusCode} ${response.statusMessage} :");
    OtherMethods.customLog("📦 BODY: ${response.data}");

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiName = err.requestOptions.extra["apiName"] ?? "UNKNOWN_API";

    OtherMethods.customLog("\n==================== ON_ERROR API Name = $apiName ========================= :");
    OtherMethods.customLog("❌ ERROR: ${err.message}");
    OtherMethods.customLog("📦 RESPONSE: ${err.response?.data}");

    super.onError(err, handler);
  }
}