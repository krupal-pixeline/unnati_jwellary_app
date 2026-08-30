class AppUrls {
  // =====================================================
  // BASE URL
  // =====================================================
  static const String baseUrl = 'https://api.unnatijewellers.com/api/v1/';

  // =====================================================
  // API KEY (x-api-key header)
  static const String apiKey =
      'Au7Kv7L7LhtLcS5XTABzc2S55aybYnZnkMQeG5gOOQuW83TVQk5v2CLdjfmN/rrSu4q1gMjAJ7WsDXVrP4/ZYQ==';

  // =====================================================
  // AUTH ENDPOINTS
  // =====================================================
  /// POST  – Send OTP to mobile number (Login)
  static const String login = '${baseUrl}customers/login';

  /// POST  – Verify OTP & receive auth token
  static const String verifyOtp = '${baseUrl}customers/verify-otp';

  /// POST  – Refresh Access Token (body: { "refreshToken": "..." })
  static const String refreshToken = '${baseUrl}customers/refresh-token';

  /// POST  – Register new customer (sends OTP after registration)
  static const String register = '${baseUrl}customers/register';

  /// POST  – Resend OTP to a mobile number (body: { "mobileNumber": "..." })
  static const String resendOtp = '${baseUrl}customers/resend-otp';

  /// PUT  – Update customer FCM token
  static const String updateFcmToken = '${baseUrl}customers/fcm-token';

  /// GET  – Get active banners for home screen
  static const String banners = '${baseUrl}cms/banners?active=true';

  /// GET  – Get all categories
  static const String categories = '${baseUrl}categories';

  /// GET  – Get trending items for home screen
  static const String trending = '${baseUrl}cms/trending';

  /// GET  – Get instagram styling reels for home screen
  static const String styling = '${baseUrl}cms/styling';

  /// GET  – Get products list (accepts query parameters like tag, category, etc.)
  static const String products = '${baseUrl}products';

  /// GET  – Get subcategories by parent category ID prefix
  static const String subCategoriesByCategory = '${baseUrl}subcategories/category/';

  /// GET  – Get product details by ID prefix
  static const String productDetail = '${baseUrl}products/';

  /// GET / POST / DELETE – Wishlist endpoint
  static const String wishlist = '${baseUrl}wishlist';

  /// GET – Terms & Conditions HTML content
  static const String termsAndConditions = '${baseUrl}cms/terms';

  /// GET – Privacy Policy HTML content
  static const String privacyPolicy = '${baseUrl}cms/privacy';

  /// GET – Store Details CMS content
  static const String storeDetails = '${baseUrl}cms/store';

  /// GET – Maintenance Status CMS content
  static const String maintenance = '${baseUrl}cms/maintenance';

  /// GET – App Version CMS content
  static const String appVersion = '${baseUrl}cms/app-version';

  /// Play Store App URL
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.unnati.jewellers&hl=en_IN';

  /// GET – Lucky Draw Assignments (coupons/my-assignments)
  static const String luckyDrawAssignments = '${baseUrl}coupons/my-assignments';

  /// GET – Lucky Draw History list (lucky-draws)
  static const String luckyDraws = '${baseUrl}lucky-draws';

  /// GET – My Coupons by Batch ID (coupons/my-coupons?batchId=...)
  static const String myCoupons = '${baseUrl}coupons/my-coupons';

  /// GET – My Wins (lucky-draws/my-wins)
  static const String myWins = '${baseUrl}lucky-draws/my-wins';

  /// POST – Swarnim Schemes Send OTP
  static const String swarnimSendOtp = '${baseUrl}swarnim-schemes/send-otp';

  /// POST – Swarnim Schemes Verify OTP
  static const String swarnimVerifyOtp = '${baseUrl}swarnim-schemes/verify-otp';

  /// POST – Swarnim Schemes Register
  static const String swarnimRegister = '${baseUrl}swarnim-schemes/register';

  /// GET – My Active Swarnim Schemes list
  static const String swarnimMySchemes = '${baseUrl}swarnim-schemes/my-schemes';
}