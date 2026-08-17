import '../model/lucky_draw/lucky_draw_assignment_model.dart';
import '../model/lucky_draw/lucky_draw_history_model.dart';
import '../model/lucky_draw/lucky_draw_my_wins_model.dart';
import '../utils/app_key_names.dart';
import '../utils/app_urls.dart';
import '../utils/other_methods.dart';
import 'base_api_services.dart';

class LuckyDrawApiService {
  static final LuckyDrawApiService _instance = LuckyDrawApiService._internal();

  factory LuckyDrawApiService() => _instance;

  LuckyDrawApiService._internal();

  final BaseApiService _baseApi = BaseApiService();

  // ── Helper to build extra headers with Bearer token ───────────────────────
  Map<String, dynamic>? _getAuthHeaders() {
    final token = OtherMethods.getStorage(AppKeyNames.bearerToken);
    if (token != null && token.toString().isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  // ── GET Lucky Draw Assignments ─────────────────────────────────────────────
  Future<LuckyDrawAssignmentResponse> getAssignments({int page = 1, int limit = 10}) async {
    const apiName = 'GET_LUCKY_DRAW_ASSIGNMENTS';
    try {
      OtherMethods.customLog('🎟️ [$apiName] Fetching lucky draw coupon assignments...');
      final response = await _baseApi.getRequest(
        url: AppUrls.luckyDrawAssignments,
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final model = LuckyDrawAssignmentResponse.fromJson(response);
      OtherMethods.customLog('🎟️ [$apiName] Success! Assignments count: ${model.data.length}');
      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── GET Lucky Draw History ─────────────────────────────────────────────────
  Future<LuckyDrawHistoryResponse> getHistory({int page = 1, int limit = 10}) async {
    const apiName = 'GET_LUCKY_DRAW_HISTORY';
    try {
      OtherMethods.customLog('🎟️ [$apiName] Fetching lucky draw history...');
      final response = await _baseApi.getRequest(
        url: AppUrls.luckyDraws,
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );

      final model = LuckyDrawHistoryResponse.fromJson(response);
      OtherMethods.customLog('🎟️ [$apiName] Success! History count: ${model.data.length}');
      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── GET My Coupons by Batch ID ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getMyCoupons(String batchId, {int page = 1, int limit = 10}) async {
    const apiName = 'GET_MY_COUPONS';
    try {
      OtherMethods.customLog('🎟️ [$apiName] Fetching my coupons for batchId: $batchId (page: $page, limit: $limit)');
      final response = await _baseApi.getRequest(
        url: AppUrls.myCoupons,
        queryParams: {
          'batchId': batchId,
          'page': page.toString(),
          'limit': limit.toString(),
        },
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      OtherMethods.customLog('🎟️ [$apiName] Success!');
      return response;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }

  // ── GET My Wins ─────────────────────────────────────────────────────────────
  Future<LuckyDrawMyWinsResponse> getMyWins() async {
    const apiName = 'GET_MY_WINS';
    try {
      OtherMethods.customLog('🎟️ [$apiName] Fetching my wins...');
      final response = await _baseApi.getRequest(
        url: AppUrls.myWins,
        extraHeaders: _getAuthHeaders(),
        apiName: apiName,
      );
      final model = LuckyDrawMyWinsResponse.fromJson(response);
      OtherMethods.customLog('🎟️ [$apiName] Success! Wins count: ${model.data.length}');
      return model;
    } catch (e) {
      OtherMethods.customLog('❌ [$apiName] Error: $e');
      rethrow;
    }
  }
}
