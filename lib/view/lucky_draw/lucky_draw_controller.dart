import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/lucky_draw/lucky_draw_assignment_model.dart';
import '../../model/lucky_draw/lucky_draw_history_model.dart';
import '../../model/lucky_draw/lucky_draw_my_wins_model.dart';
import '../../services/lucky_draw_api_service.dart';
import '../../utils/app_colors.dart';

class LuckyDrawController extends GetxController {
  // ── API Service ────────────────────────────────────────────────────────────
  final _apiService = LuckyDrawApiService();

  // ── Coupon Assignments ──────────────────────────────────────────────────────
  final RxList<LuckyDrawAssignment> assignments = <LuckyDrawAssignment>[].obs;
  final RxBool isAssignmentsLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Lucky Draw History (Past Winners) ──────────────────────────────────────
  final RxList<LuckyDrawHistoryItem> history = <LuckyDrawHistoryItem>[].obs;
  final RxBool isHistoryLoading = false.obs;
  final RxBool isHistoryLoadingMore = false.obs;
  final RxInt historyPage = 1.obs;
  final RxInt historyTotalPages = 1.obs;
  final RxString historyErrorMessage = ''.obs;

  // ── My Wins ────────────────────────────────────────────────────────────────
  final RxList<LuckyDrawWinItem> myWins = <LuckyDrawWinItem>[].obs;
  final RxBool isMyWinsLoading = false.obs;
  final RxString myWinsErrorMessage = ''.obs;

  // ── Celebration State ──────────────────────────────────────────────────────
  final RxBool showCelebration = false.obs;

  // ── Countdown Timer ────────────────────────────────────────────────────────
  final RxString countdownTimer = '05:45:12'.obs;
  int _totalSeconds = 5 * 3600 + 45 * 60 + 12;
  Timer? _timer;

  // ── Available Entry Coupons ────────────────────────────────────────────────
  final List<Map<String, dynamic>> coupons = [
    {
      'id': 'c1',
      'code': 'SILVER_SPIN',
      'name': 'Silver Entry Ticket',
      'price': '₹49',
      'numericPrice': 49,
      'multiplier': '1x Win Chance',
      'badge': 'STARTER',
      'color': 0xFF9E9E9E, // Grey
      'icon': '🎟️',
      'status': 'Activated',
    },
    {
      'id': 'c2',
      'code': 'GOLDEN_SPIN',
      'name': 'Golden Entry Ticket',
      'price': '₹99',
      'numericPrice': 99,
      'multiplier': '3x Win Chance',
      'badge': 'POPULAR',
      'color': 0xFFD4AF37, // Gold
      'icon': '🎫',
      'status': 'Activated',
    },
    {
      'id': 'c3',
      'code': 'ROYAL_GOLD',
      'name': 'Royal Draw Pass',
      'price': '₹199',
      'numericPrice': 199,
      'multiplier': '7x Win Chance',
      'badge': 'BEST VALUE',
      'color': 0xFF6B1D2E, // Maroon
      'icon': '👑',
      'status': 'Deactivated',
    },
    {
      'id': 'c4',
      'code': 'DIAMOND_DRAW',
      'name': 'Imperial Solitaire Pass',
      'price': '₹499',
      'numericPrice': 499,
      'multiplier': '20x Win Chance',
      'badge': 'VIP ONLY',
      'color': 0xFF0D0D0D, // Black
      'icon': '💎',
      'status': 'Deactivated',
    },
  ];

  // ── Main Coupon & Sub Coupons from Backend ──────────────────────────────────
  final Map<String, dynamic> mainCoupon = {
    'id': 'mc_4821',
    'code': 'MEGA_DRAW_JULY',
    'name': 'Weekly Mega Gold Draw',
    'description': 'Participate to win the grand 10g 24K Gold Coin prize!',
    'drawRef': '#LDK-4821',
    'drawDate': '12 July 2026',
    'prize': '10g 24K Gold Coin',
    'totalCoupons': 10,
    'activeCoupons': 6,
    'badge': 'MEGA DRAW',
    'color': 0xFF6B1D2E, // Maroon primary
    'icon': '🏆',
    'subCoupons': [
      {
        'id': 'sc_01',
        'ticketNo': 'TKT-77821',
        'name': 'Silver Entry Ticket',
        'price': '₹49',
        'code': 'SILVER_SPIN',
        'multiplier': '1x Win Chance',
        'badge': 'STARTER',
        'color': 0xFF9E9E9E, // Grey
        'icon': '🎟️',
        'status': 'Activated',
        'purchaseDate': '05 July, 11:30 AM',
      },
      {
        'id': 'sc_02',
        'ticketNo': 'TKT-99102',
        'name': 'Golden Entry Ticket',
        'price': '₹99',
        'code': 'GOLDEN_SPIN',
        'multiplier': '3x Win Chance',
        'badge': 'POPULAR',
        'color': 0xFFD4AF37, // Gold
        'icon': '🎫',
        'status': 'Activated',
        'purchaseDate': '05 July, 02:15 PM',
      },
      {
        'id': 'sc_03',
        'ticketNo': 'TKT-88432',
        'name': 'Royal Draw Pass',
        'price': '₹199',
        'code': 'ROYAL_GOLD',
        'multiplier': '7x Win Chance',
        'badge': 'BEST VALUE',
        'color': 0xFF6B1D2E, // Maroon
        'icon': '👑',
        'status': 'Deactivated',
        'purchaseDate': '06 July, 10:00 AM',
      },
      {
        'id': 'sc_04',
        'ticketNo': 'TKT-11982',
        'name': 'Imperial Solitaire Pass',
        'price': '₹499',
        'code': 'DIAMOND_DRAW',
        'multiplier': '20x Win Chance',
        'badge': 'VIP ONLY',
        'color': 0xFF0D0D0D, // Black
        'icon': '💎',
        'status': 'Deactivated',
        'purchaseDate': '06 July, 11:45 AM',
      },
      {
        'id': 'sc_05',
        'ticketNo': 'TKT-12248',
        'name': 'Silver Entry Ticket',
        'price': '₹49',
        'code': 'SILVER_SPIN',
        'multiplier': '1x Win Chance',
        'badge': 'STARTER',
        'color': 0xFF9E9E9E,
        'icon': '🎟️',
        'status': 'Activated',
        'purchaseDate': '06 July, 01:20 PM',
      },
      {
        'id': 'sc_06',
        'ticketNo': 'TKT-33421',
        'name': 'Golden Entry Ticket',
        'price': '₹99',
        'code': 'GOLDEN_SPIN',
        'multiplier': '3x Win Chance',
        'badge': 'POPULAR',
        'color': 0xFFD4AF37,
        'icon': '🎫',
        'status': 'Activated',
        'purchaseDate': '06 July, 03:40 PM',
      },
      {
        'id': 'sc_07',
        'ticketNo': 'TKT-55612',
        'name': 'Silver Entry Ticket',
        'price': '₹49',
        'code': 'SILVER_SPIN',
        'multiplier': '1x Win Chance',
        'badge': 'STARTER',
        'color': 0xFF9E9E9E,
        'icon': '🎟️',
        'status': 'Activated',
        'purchaseDate': '06 July, 04:10 PM',
      },
      {
        'id': 'sc_08',
        'ticketNo': 'TKT-99876',
        'name': 'Golden Entry Ticket',
        'price': '₹99',
        'code': 'GOLDEN_SPIN',
        'multiplier': '3x Win Chance',
        'badge': 'POPULAR',
        'color': 0xFFD4AF37,
        'icon': '🎫',
        'status': 'Activated',
        'purchaseDate': '06 July, 05:00 PM',
      },
      {
        'id': 'sc_09',
        'ticketNo': 'TKT-44122',
        'name': 'Royal Draw Pass',
        'price': '₹199',
        'code': 'ROYAL_GOLD',
        'multiplier': '7x Win Chance',
        'badge': 'BEST VALUE',
        'color': 0xFF6B1D2E,
        'icon': '👑',
        'status': 'Deactivated',
        'purchaseDate': '06 July, 05:30 PM',
      },
      {
        'id': 'sc_10',
        'ticketNo': 'TKT-55102',
        'name': 'Imperial Solitaire Pass',
        'price': '₹499',
        'code': 'DIAMOND_DRAW',
        'multiplier': '20x Win Chance',
        'badge': 'VIP ONLY',
        'color': 0xFF0D0D0D,
        'icon': '💎',
        'status': 'Deactivated',
        'purchaseDate': '06 July, 06:12 PM',
      },
    ],
  };

  // ── User Active Tickets ─────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> userTickets = <Map<String, dynamic>>[
    {
      'ticketNo': 'TKT-77821',
      'code': 'SILVER_SPIN',
      'name': 'Silver Entry Ticket',
      'purchaseDate': 'Today, 11:30 AM',
      'status': 'Active',
    }
  ].obs;

  // ── Recent Draw Winners ────────────────────────────────────────────────────
  final List<Map<String, dynamic>> recentWinners = [
    {
      'date': '02 July 2026',
      'ticketNo': 'TKT-90182',
      'winner': 'Ramesh S. (Ahmedabad)',
      'prize': '',
    },
    {
      'date': '28 June 2026',
      'ticketNo': 'TKT-44120',
      'winner': 'Anjali P. (Surat)',
      'prize': '',
    },
    {
      'date': '24 June 2026',
      'ticketNo': 'TKT-31298',
      'winner': 'Vikram G. (Vadodara)',
      'prize': '',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
    refreshAllData();
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      fetchAssignments(),
      fetchHistory(),
      fetchMyWins(),
    ]);
  }

  Future<void> fetchAssignments() async {
    try {
      isAssignmentsLoading.value = true;
      errorMessage.value = '';
      final response = await _apiService.getAssignments();
      assignments.value = response.data;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isAssignmentsLoading.value = false;
    }
  }

  Future<void> fetchHistory({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isHistoryLoadingMore.value || historyPage.value >= historyTotalPages.value) return;
      try {
        isHistoryLoadingMore.value = true;
        historyErrorMessage.value = '';
        final nextPage = historyPage.value + 1;
        final response = await _apiService.getHistory(page: nextPage);
        history.addAll(response.data);
        historyPage.value = nextPage;
        if (response.pagination != null) {
          historyTotalPages.value = response.pagination!.pages;
        }
      } catch (e) {
        historyErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      } finally {
        isHistoryLoadingMore.value = false;
      }
    } else {
      try {
        isHistoryLoading.value = true;
        historyErrorMessage.value = '';
        final response = await _apiService.getHistory(page: 1);
        history.value = response.data;
        historyPage.value = 1;
        if (response.pagination != null) {
          historyTotalPages.value = response.pagination!.pages;
        }
      } catch (e) {
        historyErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      } finally {
        isHistoryLoading.value = false;
      }
    }
  }

  Future<void> fetchMyWins() async {
    try {
      isMyWinsLoading.value = true;
      myWinsErrorMessage.value = '';
      final response = await _apiService.getMyWins();
      // Filter wins to only keep ones where drawDate is within the last 7 days
      myWins.value = response.data.where((win) => win.isWithinLast7Days).toList();
    } catch (e) {
      myWinsErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isMyWinsLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        _totalSeconds--;
        final h = (_totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final m = ((_totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
        final s = (_totalSeconds % 60).toString().padLeft(2, '0');
        countdownTimer.value = '$h:$m:$s';
      } else {
        _timer?.cancel();
      }
    });
  }

  // ── Buy Ticket Simulation ──────────────────────────────────────────────────
  void purchaseTicket(Map<String, dynamic> coupon) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to buy the "${coupon['name']}" for ${coupon['price']}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroonPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back(); // Dismiss confirm dialog
                        _finalizePurchase(coupon);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finalizePurchase(Map<String, dynamic> coupon) {
    // Generate a random ticket number
    final randomDigits = (10000 + (90000 * (DateTime.now().millisecond / 1000))).toInt();
    final newTicketNo = 'TKT-$randomDigits';

    // Add to active inventory list
    userTickets.insert(0, {
      'ticketNo': newTicketNo,
      'code': coupon['code'],
      'name': coupon['name'],
      'purchaseDate': 'Just now',
      'status': 'Active',
    });

    // Show Success Dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ticket Purchased!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ticket number is $newTicketNo. The draw results will be updated under recent winners when completed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroonPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Great!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
