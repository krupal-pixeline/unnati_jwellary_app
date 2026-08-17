import 'package:get/get.dart';

import '../../../services/base_api_services.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/other_methods.dart';

class TermsAndConditionController extends GetxController {
  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString htmlContent = ''.obs;

  final BaseApiService _baseApi = BaseApiService();

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  // ── API Call ───────────────────────────────────────────────────────────────
  Future<void> fetchTerms() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    htmlContent.value = '';

    try {
      OtherMethods.customLog('🌐 [TERMS] Fetching Terms & Conditions...');

      final Map<String, dynamic> response = await _baseApi.getRequest(
        url: AppUrls.termsAndConditions,
        apiName: 'TERMS_AND_CONDITIONS',
      );

      if (response['success'] == true && response['data'] != null) {
        htmlContent.value = response['data'].toString();
        OtherMethods.customLog('✅ [TERMS] Successfully fetched Terms HTML content.');
      } else {
        throw Exception('Invalid response received from server.');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unable to load Terms & Conditions.\nPlease check your internet connection and try again.';
      OtherMethods.customLog('❌ [TERMS] Error → $e');
    } finally {
      isLoading.value = false;
    }
  }
}
