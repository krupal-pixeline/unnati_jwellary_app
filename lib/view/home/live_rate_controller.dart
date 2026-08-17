import 'dart:async';
import 'package:get/get.dart';
import '../../services/live_rate_service.dart';

class LiveRateController extends GetxController {
  final _service = LiveRateService();

  // ── Observable State ──────────────────────────────────────────────────────
  final Rx<MetalRates?> rates = Rx<MetalRates?>(null);
  final RxList<RateHistoryPoint> history24h = <RateHistoryPoint>[].obs;
  final RxBool isConnected = false.obs;
  final RxBool isLoading = true.obs;
  
  // Tabs: 'gold' | 'silver' | 'coins'
  final RxString selectedMetal = 'gold'.obs; 
  final RxString selectedKarat = '24K'.obs;
  final RxString lastUpdatedStr = ''.obs;

  // Directions for live flashing ('up', 'down', 'neutral')
  final RxMap<String, String> directions = <String, String>{}.obs;
  final Map<String, Timer> _directionTimers = {};

  // Karats list
  final goldKarats = const ['24K', '22K', '20K', '18K', '14K'];
  final silverKarats = const ['999', '925', 'Ordinary'];

  // Cache of previous rates for comparison
  MetalRates? _prevRates;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    await _fetchLatest();
    await _fetchHistory();
    _connectSocket();
    isLoading.value = false;
  }

  Future<void> refreshData() async {
    await _fetchLatest();
    await _fetchHistory();
  }

  Future<void> _fetchLatest() async {
    final r = await _service.getLatestRates();
    if (r != null) {
      _prevRates = rates.value;
      rates.value = r;
      _updateLastUpdated(r.apiTime);
    }
  }

  Future<void> _fetchHistory() async {
    // Group hourly and limit to 24 to get the last 24 hours of logs
    final history = await _service.getHistory(limit: 24, group: 'hour');
    history24h.assignAll(history);
  }

  void _connectSocket() {
    _service.initSocket(
      onRatesUpdated: (newRates) {
        _prevRates = rates.value;
        _updateDirections(_prevRates, newRates);
        rates.value = newRates;
        _updateLastUpdated(newRates.apiTime);

        // Update history point
        final lastPoint = RateHistoryPoint(
          time: newRates.apiTime ?? DateTime.now(),
          gold24k: newRates.gold24k,
          silver999: newRates.silver999,
        );
        
        // Remove oldest and append newest to keep last 24 points
        if (history24h.isNotEmpty) {
          history24h.removeAt(0);
        }
        history24h.add(lastPoint);
      },
      onConnected: () => isConnected.value = true,
      onDisconnected: () => isConnected.value = false,
    );
  }

  void _updateDirections(MetalRates? oldRates, MetalRates newRates) {
    if (oldRates == null) return;

    _compareAndSet('k24', oldRates.gold24k, newRates.gold24k);
    _compareAndSet('k22', oldRates.gold22k, newRates.gold22k);
    _compareAndSet('k20', oldRates.gold20k, newRates.gold20k);
    _compareAndSet('k18', oldRates.gold18k, newRates.gold18k);
    _compareAndSet('k14', oldRates.gold14k, newRates.gold14k);

    _compareAndSet('s999', oldRates.silver999, newRates.silver999);
    _compareAndSet('s925', oldRates.silver925, newRates.silver925);
    _compareAndSet('ordinary', oldRates.silverOrdinary, newRates.silverOrdinary);

    if (oldRates.goldUSD != null && newRates.goldUSD != null) {
      _compareAndSet('goldUSD', oldRates.goldUSD!.ask, newRates.goldUSD!.ask);
    }
    if (oldRates.silverUSD != null && newRates.silverUSD != null) {
      _compareAndSet('silverUSD', oldRates.silverUSD!.ask, newRates.silverUSD!.ask);
    }
    if (oldRates.inr != null && newRates.inr != null) {
      _compareAndSet('inr', oldRates.inr!.ask, newRates.inr!.ask);
    }
  }

  void _compareAndSet(String key, double oldVal, double newVal) {
    if (oldVal == 0 || newVal == oldVal) return;
    
    final dir = newVal > oldVal ? 'up' : 'down';
    directions[key] = dir;

    // Reset blink state back to neutral after 3 seconds
    _directionTimers[key]?.cancel();
    _directionTimers[key] = Timer(const Duration(seconds: 3), () {
      directions[key] = 'neutral';
    });
  }

  void _updateLastUpdated(DateTime? dt) {
    if (dt == null) {
      lastUpdatedStr.value = 'Just now';
      return;
    }
    final local = dt.toLocal();
    final hour24 = local.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    final h = hour12.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    lastUpdatedStr.value = '$h:$m:$s $period';
  }

  void selectMetal(String metal) {
    selectedMetal.value = metal;
    if (metal == 'gold') {
      selectedKarat.value = '24K';
    } else if (metal == 'silver') {
      selectedKarat.value = '999';
    }
  }

  // ── Price getters ─────────────────────────────────────────────────────────
  double get gold24kPrice => rates.value?.gold24k ?? 0;
  double get gold22kPrice => rates.value?.gold22k ?? 0;
  double get gold20kPrice => rates.value?.gold20k ?? 0;
  double get gold18kPrice => rates.value?.gold18k ?? 0;
  double get gold14kPrice => rates.value?.gold14k ?? 0;
  double get silver999Price => rates.value?.silver999 ?? 0;
  double get silver925Price => rates.value?.silver925 ?? 0;
  double get silverOrdinaryPrice => rates.value?.silverOrdinary ?? 0;

  double priceForKarat(String karat) {
    switch (karat) {
      case '24K': return gold24kPrice;
      case '22K': return gold22kPrice;
      case '20K': return gold20kPrice;
      case '18K': return gold18kPrice;
      case '14K': return gold14kPrice;
      case '999': return silver999Price;
      case '925': return silver925Price;
      case 'Ordinary': return silverOrdinaryPrice;
      default: return 0;
    }
  }

  // High/Low helper calculations for products (karats) using goldCBE or silverChennai high/low ratios
  double lowForKarat(String karat) {
    final rawGold = rates.value?.goldCBE;
    final rawSilver = rates.value?.silverChennai;
    if (rates.value == null) return 0;

    if (karat.startsWith('24') || karat.startsWith('22') || karat.startsWith('20') || karat.startsWith('18') || karat.startsWith('14')) {
      if (rawGold == null || rawGold.ask == 0) return priceForKarat(karat) * 0.99;
      final ratio = priceForKarat(karat) / rawGold.ask;
      return rawGold.low * ratio;
    } else {
      if (rawSilver == null || rawSilver.ask == 0) return priceForKarat(karat) * 0.99;
      final ratio = priceForKarat(karat) / rawSilver.ask;
      return rawSilver.low * ratio;
    }
  }

  double highForKarat(String karat) {
    final rawGold = rates.value?.goldCBE;
    final rawSilver = rates.value?.silverChennai;
    if (rates.value == null) return 0;

    if (karat.startsWith('24') || karat.startsWith('22') || karat.startsWith('20') || karat.startsWith('18') || karat.startsWith('14')) {
      if (rawGold == null || rawGold.ask == 0) return priceForKarat(karat) * 1.01;
      final ratio = priceForKarat(karat) / rawGold.ask;
      return rawGold.high * ratio;
    } else {
      if (rawSilver == null || rawSilver.ask == 0) return priceForKarat(karat) * 1.01;
      final ratio = priceForKarat(karat) / rawSilver.ask;
      return rawGoldHistoryPointRatio(ratio, rawSilver);
    }
  }

  double rawGoldHistoryPointRatio(double ratio, RawRate rawSilver) {
    return rawSilver.high * ratio;
  }

  List<double> get graphPoints {
    if (history24h.isEmpty) return [];
    return history24h.map((p) => selectedMetal.value == 'silver' ? p.silver999 : p.gold24k).toList();
  }

  String formatPrice(double v) {
    if (v == 0) return '—';
    return '₹${v.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';
  }

  String formatPriceNoSymbol(double v) {
    if (v == 0) return '—';
    return v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  void onClose() {
    for (final timer in _directionTimers.values) {
      timer.cancel();
    }
    _service.dispose();
    super.onClose();
  }
}
