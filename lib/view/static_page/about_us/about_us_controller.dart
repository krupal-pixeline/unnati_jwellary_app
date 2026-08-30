import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/base_api_services.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/other_methods.dart';
import '../our_store/our_store_model.dart';

class AboutUsController extends GetxController {
  // ── Store API Details ──────────────────────────────────────────────────────
  final RxBool isStoreLoading = true.obs;
  final Rx<OurStoreModel?> storeData = Rx<OurStoreModel?>(null);
  final BaseApiService _baseApi = BaseApiService();

  // ── Carousel ─────────────────────────────────────────────────────────────
  final RxInt currentCarouselIndex = 0.obs;


  // ── Legacy Journey Timeline Data (Exact Documented Brand History) ─────────
  final List<Map<String, String>> timelineItems = [
    {
      'year': '1978',
      'title': 'Where It All Began',
      'description':
          'Our Story Began With Silver Bullion Trading, Built On The Enduring Values Of Trust, Integrity, And Lasting Relationships.',
    },
    {
      'year': '1980',
      'title': 'Expanding Our Foundation',
      'description':
          'With Growing Expertise, We Broadened Our Journey Into Gold Bullion, Strengthening Our Presence In The Precious Metals Industry.',
    },
    {
      'year': '1992',
      'title': 'The Beginning Of Our Jewellery Heritage',
      'description':
          'A Defining Milestone Marked Our Transformation Into A Jewellery House, With The Introduction Of Our First Silver Daily Wear Collection.',
    },
    {
      'year': '1996',
      'title': 'Crafting Everyday Elegance',
      'description':
          'Our Gold Daily Wear Collection Was Unveiled, Bringing Together Exceptional Craftsmanship, Timeless Design, And Everyday Sophistication.',
    },
    {
      'year': '2002',
      'title': 'Celebrating Life\'s Cherished Moments',
      'description':
          'Our Silver Bridal Collection Was Introduced, Becoming A Meaningful Part Of Countless Celebrations And Family Traditions.',
    },
    {
      'year': '2010',
      'title': 'A New Chapter In Bridal Excellence',
      'description':
          'The Launch Of Our Gold Bridal Collection Reflected Our Commitment To Creating Jewellery Worthy Of Life\'s Most Treasured Occasions.',
    },
    {
      'year': '2018',
      'title': 'A Complete Jewellery Destination',
      'description':
          'With An Expanded Portfolio And Enhanced Capabilities, We Evolved Into A Full-Fledged Jewellery Destination, Offering Thoughtfully Curated Collections In Gold And Silver.',
    },
    {
      'year': '2025',
      'title': 'A Landmark Transformation',
      'description':
          'The Opening Of Our New Luxury Showroom Marked A Defining Chapter In Our Journey, Offering An Elevated Experience Where Elegance, Craftsmanship, And Trust Come Together.',
    },
    {
      'year': '2026',
      'title': 'Embracing The Digital Era',
      'description':
          'Our Legacy Extended Beyond The Showroom As We Launched Our Digital Presence, Making Our Collections And Personalised Service Accessible To Customers Everywhere.',
    },
  ];

  late final List<RxBool> timelineExpanded;

  @override
  void onInit() {
    super.onInit();
    // First milestone expanded by default, others collapsed
    timelineExpanded = List.generate(timelineItems.length, (index) => (index == 0).obs);
    fetchStoreDetails();
  }

  void updateCarouselIndex(int index) => currentCarouselIndex.value = index;

  void toggleTimelineItem(int index) {
    timelineExpanded[index].value = !timelineExpanded[index].value;
  }

  Future<void> fetchStoreDetails() async {
    try {
      isStoreLoading.value = true;
      final response = await _baseApi.getRequest(
        url: AppUrls.storeDetails,
        apiName: 'ABOUT_US_STORE_DETAILS',
      );
      if (response['success'] == true && response['data'] != null) {
        storeData.value = OurStoreModel.fromJson(response['data'] as Map<String, dynamic>);
        OtherMethods.customLog('✅ [ABOUT_US] Successfully loaded store details.');
      }
    } catch (e) {
      OtherMethods.customLog('❌ [ABOUT_US] Error loading store details: $e');
    } finally {
      isStoreLoading.value = false;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────
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
      OtherMethods.customLog('Error opening map: $e');
    }
  }

  Future<void> openDialer() async {
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
      OtherMethods.customLog('Error opening dialer: $e');
      Get.snackbar(
        "Phone Call",
        "Unable to launch phone dialer for $phone",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openEmail() async {
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
      OtherMethods.customLog('Error opening email: $e');
      Get.snackbar(
        "Email Inquiry",
        "Unable to open mail client for $email",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
