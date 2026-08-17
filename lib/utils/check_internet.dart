import 'dart:io';
import 'package:flutter/foundation.dart';

// Global instance - removed asterisks which were syntax errors
final internetConnectionChecker = InternetConnectionChecker();

class InternetConnectionChecker {
  // Removed asterisks which were causing syntax errors
  bool? _activeConnection = false;
  String? _message = "";

  Future<bool> checkUserConnection() async {
    if (!kIsWeb) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _activeConnection = true;
          _message = "Internet connection is available";
          return true;
        }
      } on SocketException catch (_) {
        _activeConnection = false;
        _message = "No internet connection available";
      }
    } else {
      _activeConnection = true;  // You might want to implement a different check for web
      _message = "Internet connection check not implemented for web";
    }
    return _activeConnection ?? false;
  }

  // Getters for private properties
  bool? get activeConnection => _activeConnection;
  String? get message => _message;
}

// Helper function
Future<bool> checkInternetConnection() async {
  return await internetConnectionChecker.checkUserConnection();
}


// TODO Example Usage
/*
checkInternetFun() async {
  bool isConnected = false;
  isConnected = await checkInternetConnection();
  if (!isConnected) {
    OtherMethod.customLog(
      'no Internet Connection ',
      'Redirect to Internet Screen',
    );
    Get.offAll(
          () => const Internet_Connection_Screen(),
      duration: const Duration(milliseconds: 10),
    );
  }
}*/
