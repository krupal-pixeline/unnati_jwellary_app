import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class OtherMethods {

  static void customLog(String message) {
    debugPrint('\x1B[34m$message\x1B[0m');
  }

  static String removeHtmlTags(String? text) {
    if (text == null || text.isEmpty) {
      return "";
    }

    return text.replaceAll(RegExp(r'<[^>]*>'), '\n').replaceAll(RegExp(r'\n+'), '\n\n').replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&').trim();
  }

  // TODO --------------------- STORAGE -------------------------------

  // TODO  Storage
  static final GetStorage _storage = GetStorage();
  // SAVE DATA
  static Future<void> setStorage({required String key, required dynamic value}) async {
    try {
      final encodedValue = jsonEncode(value);

      await _storage.write(key, encodedValue);

      // customLog("✅ Stored [$key] = $encodedValue");
    } catch (e) {
      customLog("❌ Storage Write Error: $e");
    }
  }

  // GET DATA
  static dynamic getStorage(String key) {
    try {
      final value = _storage.read(key);

      if (value == null) return null;

      final decodedValue = jsonDecode(value);

      // customLog("✅ Read [$key] = $decodedValue");

      return decodedValue;
    } catch (e) {
      customLog("❌ Storage Read Error: $e");

      return null;
    }
  }

  // REMOVE KEY
  static Future<void> removeStorage(String key) async {
    try {
      await _storage.remove(key);

      // customLog("✅ Removed [$key]");
    } catch (e) {
      customLog("❌ Remove Error: $e");
    }
  }

  // CLEAR STORAGE
  static Future<void> clearStorage() async {
    try {
      await _storage.erase();

      // customLog("✅ Storage Cleared");
    } catch (e) {
      customLog("❌ Clear Storage Error: $e");
    }
  }

  String formatAudioDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) {
      return "0s";
    }

    final duration = Duration(seconds: totalSeconds);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    }

    if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    }

    return "${seconds}s";
  }


}
