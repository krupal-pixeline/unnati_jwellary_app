import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../utils/app_urls.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RAW RATE MODEL
// ─────────────────────────────────────────────────────────────────────────────
class RawRate {
  final double bid;
  final double ask;
  final double high;
  final double low;

  RawRate({
    required this.bid,
    required this.ask,
    required this.high,
    required this.low,
  });

  factory RawRate.fromJson(Map<String, dynamic> json) {
    return RawRate(
      bid: _d(json['bid']),
      ask: _d(json['ask']),
      high: _d(json['high']),
      low: _d(json['low']),
    );
  }

  static double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class MetalRates {
  final double gold24k;
  final double gold22k;
  final double gold20k;
  final double gold18k;
  final double gold14k;
  final double silver999;
  final double silver925;
  final double silverOrdinary;

  // Raw Rates
  final RawRate? goldUSD;
  final RawRate? silverUSD;
  final RawRate? inr;
  final RawRate? goldCBE;
  final RawRate? silverChennai;

  final DateTime? apiTime;

  MetalRates({
    required this.gold24k,
    required this.gold22k,
    required this.gold20k,
    required this.gold18k,
    required this.gold14k,
    required this.silver999,
    required this.silver925,
    required this.silverOrdinary,
    this.goldUSD,
    this.silverUSD,
    this.inr,
    this.goldCBE,
    this.silverChennai,
    this.apiTime,
  });

  factory MetalRates.fromJson(Map<String, dynamic> json) {
    final gold = (json['goldCalculated'] as Map?) ?? {};
    final silver = (json['silverCalculated'] as Map?) ?? {};
    final raw = (json['rawRates'] as Map?) ?? {};

    return MetalRates(
      gold24k: _d(gold['k24']),
      gold22k: _d(gold['k22']),
      gold20k: _d(gold['k20']),
      gold18k: _d(gold['k18']),
      gold14k: _d(gold['k14']),
      silver999: _d(silver['s999']),
      silver925: _d(silver['s925']),
      silverOrdinary: _d(silver['ordinary']),
      goldUSD: raw['goldUSD'] != null ? RawRate.fromJson(Map<String, dynamic>.from(raw['goldUSD'] as Map)) : null,
      silverUSD: raw['silverUSD'] != null ? RawRate.fromJson(Map<String, dynamic>.from(raw['silverUSD'] as Map)) : null,
      inr: raw['inr'] != null ? RawRate.fromJson(Map<String, dynamic>.from(raw['inr'] as Map)) : null,
      goldCBE: raw['goldCBE'] != null ? RawRate.fromJson(Map<String, dynamic>.from(raw['goldCBE'] as Map)) : null,
      silverChennai: raw['silverChennai'] != null ? RawRate.fromJson(Map<String, dynamic>.from(raw['silverChennai'] as Map)) : null,
      apiTime: json['apiTime'] != null ? DateTime.tryParse(json['apiTime'].toString()) : null,
    );
  }

  static double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY POINT
// ─────────────────────────────────────────────────────────────────────────────
class RateHistoryPoint {
  final DateTime time;
  final double gold24k;
  final double silver999;

  RateHistoryPoint({
    required this.time,
    required this.gold24k,
    required this.silver999,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class LiveRateService {
  static const String _baseUrl = 'https://api.unnatijewellers.com';
  static const String _apiBase = '$_baseUrl/api/v1';

  io.Socket? _socket;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'x-api-key': AppUrls.apiKey,
      'Accept': 'application/json',
    },
  ));

  // ── REST: Latest Rates ────────────────────────────────────────────────────
  Future<MetalRates?> getLatestRates() async {
    try {
      final response = await _dio.get('$_apiBase/live-rates/latest');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return MetalRates.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('LiveRateService.getLatestRates error: $e');
    }
    return null;
  }

  // ── REST: History ────────────────────────────────────────────────────────
  Future<List<RateHistoryPoint>> getHistory({int limit = 100, String group = 'none'}) async {
    try {
      final response = await _dio.get(
        '$_apiBase/live-rates/history',
        queryParameters: {'limit': limit, 'group': group},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        final list = body['data'] as List? ?? [];
        final points = <RateHistoryPoint>[];
        for (final item in list) {
          final doc = (item['doc'] as Map?) ?? item as Map;
          final gold = (doc['goldCalculated'] as Map?) ?? {};
          final silver = (doc['silverCalculated'] as Map?) ?? {};
          final createdAt = doc['createdAt']?.toString() ?? '';
          final time = DateTime.tryParse(createdAt) ?? DateTime.now();
          points.add(RateHistoryPoint(
            time: time,
            gold24k: MetalRates._d(gold['k24']),
            silver999: MetalRates._d(silver['s999']),
          ));
        }
        points.sort((a, b) => a.time.compareTo(b.time));
        return points;
      }
    } catch (e) {
      debugPrint('LiveRateService.getHistory error: $e');
    }
    return [];
  }

  // ── Socket.io ────────────────────────────────────────────────────────────
  void initSocket({
    required void Function(MetalRates rates) onRatesUpdated,
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) {
    _socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected');
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
      onDisconnected?.call();
    });

    _socket!.on('metal-rates-update', (payload) {
      try {
        Map<String, dynamic> data;
        if (payload is String) {
          data = jsonDecode(payload) as Map<String, dynamic>;
        } else {
          data = Map<String, dynamic>.from(payload as Map);
        }
        if (data['success'] == true && data['data'] != null) {
          final rates = MetalRates.fromJson(data['data'] as Map<String, dynamic>);
          onRatesUpdated(rates);
        }
      } catch (e) {
        debugPrint('Socket payload parse error: $e');
      }
    });

    _socket!.connect();
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
