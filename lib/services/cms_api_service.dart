import '../services/base_api_services.dart';
import '../utils/other_methods.dart';

class CmsApiService {
  static final CmsApiService _instance = CmsApiService._internal();
  factory CmsApiService() => _instance;
  CmsApiService._internal();

  final BaseApiService _baseApi = BaseApiService();

  /// GET – Check if app is under maintenance
  /// Returns `true` if under maintenance, `false` otherwise.
  Future<bool> checkUnderMaintenance() async {
    const apiName = 'CHECK_MAINTENANCE';
    try {
      OtherMethods.customLog('🛠️ [$apiName] Checking app maintenance status...');
      final response = await _baseApi.getRequest(
        url: 'cms/maintenance',
        apiName: apiName,
      );

      final isMaintenance = response['underMaintenance'] as bool? ?? false;
      OtherMethods.customLog('🛠️ [$apiName] Response underMaintenance: $isMaintenance');
      return isMaintenance;
    } catch (e) {
      OtherMethods.customLog('⚠️ [$apiName] Maintenance check failed: $e. Defaulting to false.');
      return false;
    }
  }

  /// GET – Check app version from server
  Future<AppVersionInfo?> getAppVersion() async {
    const apiName = 'CHECK_APP_VERSION';
    try {
      OtherMethods.customLog('📱 [$apiName] Checking app version status...');
      final response = await _baseApi.getRequest(
        url: 'cms/app-version',
        apiName: apiName,
      );

      return AppVersionInfo.fromJson(response);
    } catch (e) {
      OtherMethods.customLog('⚠️ [$apiName] App version check failed: $e.');
      return null;
    }
  }
}

class AppVersionInfo {
  final bool success;
  final String appVersion;
  final bool isUpdateRequired;

  AppVersionInfo({
    required this.success,
    required this.appVersion,
    required this.isUpdateRequired,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      success: json['success'] as bool? ?? false,
      appVersion: json['appVersion'] as String? ?? '',
      isUpdateRequired: json['isUpdateRequired'] as bool? ?? false,
    );
  }
}
