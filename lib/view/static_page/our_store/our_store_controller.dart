import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/base_api_services.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/other_methods.dart';
import 'our_store_model.dart';

class OurStoreController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<OurStoreModel?> storeData = Rx<OurStoreModel?>(null);

  final BaseApiService _baseApi = BaseApiService();

  @override
  void onInit() {
    super.onInit();
    fetchStoreDetails();
  }

  Future<void> fetchStoreDetails() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      OtherMethods.customLog('🌐 [OUR_STORE] Fetching Store Details...');

      final Map<String, dynamic> response = await _baseApi.getRequest(
        url: AppUrls.storeDetails,
        apiName: 'STORE_DETAILS',
      );

      if (response['success'] == true && response['data'] != null) {
        storeData.value = OurStoreModel.fromJson(response['data'] as Map<String, dynamic>);
        OtherMethods.customLog('✅ [OUR_STORE] Successfully fetched store details.');
      } else {
        throw Exception('Invalid response received from server.');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unable to load store details.\nPlease check your internet connection and try again.';
      OtherMethods.customLog('❌ [OUR_STORE] Error → $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Make Phone Call ────────────────────────────────────────────────────────
  Future<void> makePhoneCall() async {
    final phone = storeData.value?.phone ?? '+916351630432';
    final cleanNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      OtherMethods.customLog('❌ Error launching dialer: $e');
      Get.snackbar(
        "Phone Call",
        "Unable to launch phone dialer for $phone",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Send Email ─────────────────────────────────────────────────────────────
  Future<void> sendEmail() async {
    final email = storeData.value?.email ?? 'support@unnatijewellers.com';
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry regarding Unnati Jewellers',
      },
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      OtherMethods.customLog('❌ Error launching email app: $e');
      Get.snackbar(
        "Email Inquiry",
        "Unable to open mail client for $email",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Open Google Maps Location ──────────────────────────────────────────────
  Future<void> openMap() async {
    final address = storeData.value?.address ??
        'GROUND FLOOR, SHOP NO.2, SHANTI SKY, WAGHAVADI ROAD, PARIMAL CHOWK, Bhavnagar, Gujarat, 364001';
    final encodedQuery = Uri.encodeComponent(address.replaceAll('\n', ' '));
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleMapsUrl);
      }
    } catch (e) {
      OtherMethods.customLog('❌ Error launching Google Maps: $e');
      Get.snackbar(
        "Navigation Error",
        "Unable to open Google Maps navigation.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
