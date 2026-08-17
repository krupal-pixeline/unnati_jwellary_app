import 'package:get/get.dart';

import '../../../services/base_api_services.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/other_methods.dart';

class PrivecyPolicyController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString htmlContent = ''.obs;

  final BaseApiService _baseApi = BaseApiService();

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    htmlContent.value = '';

    try {
      OtherMethods.customLog('🌐 [PRIVACY] Fetching Privacy Policy...');

      final Map<String, dynamic> response = await _baseApi.getRequest(
        url: AppUrls.privacyPolicy,
        apiName: 'PRIVACY_POLICY',
      );

      if (response['success'] == true && response['data'] != null) {
        htmlContent.value = response['data'].toString();
        OtherMethods.customLog('✅ [PRIVACY] Successfully fetched Privacy Policy HTML.');
      } else {
        throw Exception('Invalid response received from server.');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unable to load Privacy Policy.\nPlease check your internet connection and try again.';
      OtherMethods.customLog('❌ [PRIVACY] Error → $e');
    } finally {
      isLoading.value = false;
    }
  }
}
