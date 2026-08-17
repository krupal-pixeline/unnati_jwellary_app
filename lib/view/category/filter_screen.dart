import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';


class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Tabs
  final List<String> _tabs = [
    'Price range',
    'Metal type',
    'Gender',
    'Weight range',
  ];

  int _selectedTabIndex = 0;

  // Selection states
  final RxString _selectedSubId = 'all'.obs;
  final Rx<RangeValues> _selectedPriceRange = const RangeValues(0.0, 500000.0).obs;
  final RxList<String> _selectedMaterials = <String>[].obs;
  final RxString _selectedGender = 'All'.obs;
  final Rx<RangeValues> _selectedWeightRange = const RangeValues(1.0, 2000.0).obs;

  // Parent Selection and Expansion states for Gold/Silver
  final RxBool _isGoldSelected = false.obs;
  final RxBool _isSilverSelected = false.obs;
  final RxBool _isGoldExpanded = true.obs;
  final RxBool _isSilverExpanded = true.obs;

  // Manual Text Controllers for Price
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final List<String> _genderOptions = [
    'All',
    'Women',
    'Men',
    'Unisex',
    'Kids',
  ];

  @override
  void initState() {
    super.initState();

    // Load initial filter states from arguments
    final args = Get.arguments as Map<String, dynamic>;
    _selectedSubId.value = args['selectedSubId'] ?? 'all';

    // Price: only populate if a filter was actually applied (non-null from parent)
    final minPrice = args['minPrice'] as double?;
    final maxPrice = args['maxPrice'] as double?;
    if (minPrice != null) {
      _selectedPriceRange.value = RangeValues(minPrice, maxPrice ?? 500000.0);
      _minPriceController.text = minPrice.toStringAsFixed(0);
    } else {
      _minPriceController.text = '';
    }
    if (maxPrice != null) {
      _selectedPriceRange.value = RangeValues(minPrice ?? 0.0, maxPrice);
      _maxPriceController.text = maxPrice.toStringAsFixed(0);
    } else {
      _maxPriceController.text = '';
    }

    final materials = args['materials'] as List<String>? ?? [];
    _selectedMaterials.assignAll(materials);

    final goldSubtypes = ['14K', '18K', '20K', '22K', '24K'];
    final silverSubtypes = ['silver999', 'silver925', 'silver-ordinary', 'silver'];

    // Default: both unselected; populate only from passed-in materials
    _isGoldSelected.value = materials.isNotEmpty &&
        (materials.contains('gold') || materials.any((m) => goldSubtypes.contains(m)));
    _isSilverSelected.value = materials.isNotEmpty &&
        (materials.contains('silver') || materials.any((m) => silverSubtypes.contains(m)));

    _selectedGender.value = args['gender'] as String? ?? 'All';

    final minWeight = args['minWeight'] as double? ?? 1.0;
    final maxWeight = args['maxWeight'] as double? ?? 2000.0;
    _selectedWeightRange.value = RangeValues(
      minWeight.clamp(1.0, 2000.0),
      maxWeight.clamp(1.0, 2000.0),
    );

    // Synchronize price controllers to reactive state
    _minPriceController.addListener(() {
      final val = double.tryParse(_minPriceController.text);
      if (val != null) {
        _selectedPriceRange.value = RangeValues(val, _selectedPriceRange.value.end);
      }
    });
    _maxPriceController.addListener(() {
      final val = double.tryParse(_maxPriceController.text);
      if (val != null) {
        _selectedPriceRange.value = RangeValues(_selectedPriceRange.value.start, val);
      }
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedSubId.value = 'all';
      _selectedPriceRange.value = const RangeValues(0.0, 500000.0);
      _minPriceController.text = '';
      _maxPriceController.text = '';

      _selectedMaterials.clear();
      _isGoldSelected.value = false;
      _isSilverSelected.value = false;
      _isGoldExpanded.value = true;
      _isSilverExpanded.value = true;

      _selectedGender.value = 'All';

      _selectedWeightRange.value = const RangeValues(1.0, 2000.0);
    });
  }

  void _applyFilters() {
    final List<String> finalMaterials = [];
    final goldSubtypes = ['14K', '18K', '20K', '22K', '24K'];
    final silverSubtypes = ['silver999', 'silver925', 'silver-ordinary', 'silver'];

    if (_isGoldSelected.value) {
      final selectedGold = _selectedMaterials.where((m) => goldSubtypes.contains(m)).toList();
      if (selectedGold.isNotEmpty) {
        finalMaterials.addAll(selectedGold);
      } else {
        finalMaterials.add('gold');
      }
    }

    if (_isSilverSelected.value) {
      final selectedSilver = _selectedMaterials.where((m) => silverSubtypes.contains(m)).toList();
      if (selectedSilver.isNotEmpty) {
        finalMaterials.addAll(selectedSilver);
      } else {
        finalMaterials.add('silver');
      }
    }

    // Only send price if user actually typed something
    final minPriceText = _minPriceController.text.trim();
    final maxPriceText = _maxPriceController.text.trim();
    final double? minPriceResult = minPriceText.isNotEmpty ? double.tryParse(minPriceText) : null;
    final double? maxPriceResult = maxPriceText.isNotEmpty ? double.tryParse(maxPriceText) : null;

    Get.back(result: {
      'selectedSubId': _selectedSubId.value,
      'minPrice': minPriceResult,
      'maxPrice': maxPriceResult,
      'materials': finalMaterials,
      'gender': _selectedGender.value,
      'minWeight': _selectedWeightRange.value.start,
      'maxWeight': _selectedWeightRange.value.end,
    });
  }

  bool _hasActiveFilterForTab(int index) {
    switch (index) {
      case 0: // Price range — active if user typed something
        return _minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty;
      case 1: // Metal type — active if gold OR silver is selected
        return _isGoldSelected.value || _isSilverSelected.value || _selectedMaterials.isNotEmpty;
      case 2: // Gender
        return _selectedGender.value != 'All';
      case 3: // Weight range
        return _selectedWeightRange.value.start > 1.0 || _selectedWeightRange.value.end < 2000.0;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryMaroon),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Apply Filter',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            const Divider(color: AppColors.divider, height: 1),
            // Middle section (tabs column + options details panel)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left tab panel ──────────────────────────────────────────
                  Container(
                    width: 125,
                    color: const Color(0xFFFFF7F2),
                    child: ListView.builder(
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isSelected = _selectedTabIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            color: isSelected ? Colors.white : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                            child: Row(
                              children: [
                                if (isSelected)
                                  Container(
                                    width: 3.5,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryMaroon,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                if (isSelected) const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    tab,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryMaroon
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (_hasActiveFilterForTab(index))
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Right options details panel ───────────────────────────────
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: _buildRightPanelContent(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Action Row ────────────────────────────────────────────
            const Divider(color: AppColors.divider, height: 1),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryMaroon, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryMaroon,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMaroon,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns panel content based on selected tab index
  Widget _buildRightPanelContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPriceRangeTab();
      case 1:
        return _buildMetalTypeTab();
      case 2:
        return _buildGenderTab();
      case 3:
        return _buildWeightRangeTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. PRICE RANGE TAB (Column input fields)
  Widget _buildPriceRangeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range Selection',
          style: GoogleFonts.cinzel(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMaroon,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Min Price (₹)',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Max Price (₹)',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 2. METAL TYPE TAB (Row Selection + Expandable sections)
  Widget _buildMetalTypeTab() {
    final goldSubtypes = ['14K', '18K', '20K', '22K', '24K'];
    final silverSubtypes = [
      {'id': 'silver999', 'label': 'silver999'},
      {'id': 'silver925', 'label': 'silver925'},
      {'id': 'silver-ordinary', 'label': 'silver-ordinary'},
      {'id': 'silver', 'label': 'silver'},
    ];

    return Obx(() {
      final isGoldSel = _isGoldSelected.value;
      final isSilverSel = _isSilverSelected.value;
      final isGoldExp = _isGoldExpanded.value;
      final isSilverExp = _isSilverExpanded.value;

      return ListView(
        children: [
          // ── Parent Row selection ─────────────────────────────────────────
          Row(
            children: [
              // GOLD BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _isGoldSelected.toggle();
                    if (!_isGoldSelected.value) {
                      // Remove gold subtypes if deselected
                      _selectedMaterials.removeWhere((m) => goldSubtypes.contains(m));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isGoldSel 
                          ? AppColors.primaryMaroon.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGoldSel 
                            ? AppColors.primaryMaroon 
                            : AppColors.border,
                        width: isGoldSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGoldSel ? Icons.check_circle : Icons.radio_button_off,
                          color: isGoldSel ? AppColors.primaryMaroon : AppColors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'GOLD',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isGoldSel ? AppColors.primaryMaroon : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // SILVER BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _isSilverSelected.toggle();
                    if (!_isSilverSelected.value) {
                      // Remove silver subtypes if deselected
                      final ids = silverSubtypes.map((s) => s['id']!).toList();
                      _selectedMaterials.removeWhere((m) => ids.contains(m));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSilverSel 
                          ? AppColors.primaryMaroon.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSilverSel 
                            ? AppColors.primaryMaroon 
                            : AppColors.border,
                        width: isSilverSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSilverSel ? Icons.check_circle : Icons.radio_button_off,
                          color: isSilverSel ? AppColors.primaryMaroon : AppColors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SILVER',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isSilverSel ? AppColors.primaryMaroon : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Expandable Gold section ──────────────────────────────────────
          if (isGoldSel) ...[
            GestureDetector(
              onTap: () => _isGoldExpanded.toggle(),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GOLD SUBTYPES',
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Icon(
                      isGoldExp 
                          ? Icons.keyboard_arrow_up_rounded 
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryMaroon,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isGoldExp)
              Column(
                children: goldSubtypes.map((karat) {
                  final isSelected = _selectedMaterials.contains(karat);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _selectedMaterials.remove(karat);
                      } else {
                        _selectedMaterials.add(karat);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primaryMaroon,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              if (val == true) {
                                _selectedMaterials.add(karat);
                              } else {
                                _selectedMaterials.remove(karat);
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$karat Gold',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryMaroon : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
          ],

          // ── Expandable Silver section ────────────────────────────────────
          if (isSilverSel) ...[
            GestureDetector(
              onTap: () => _isSilverExpanded.toggle(),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SILVER SUBTYPES',
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Icon(
                      isSilverExp 
                          ? Icons.keyboard_arrow_up_rounded 
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryMaroon,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isSilverExp)
              Column(
                children: silverSubtypes.map((sub) {
                  final id = sub['id']!;
                  final label = sub['label']!;
                  final isSelected = _selectedMaterials.contains(id);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _selectedMaterials.remove(id);
                      } else {
                        _selectedMaterials.add(id);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primaryMaroon,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              if (val == true) {
                                _selectedMaterials.add(id);
                              } else {
                                _selectedMaterials.remove(id);
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryMaroon : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      );
    });
  }

  // 3. GENDER TAB
  Widget _buildGenderTab() {
    return ListView.builder(
      itemCount: _genderOptions.length,
      itemBuilder: (context, i) {
        final opt = _genderOptions[i];
        return Obx(() {
          final isSelected = _selectedGender.value == opt;
          return GestureDetector(
            onTap: () => _selectedGender.value = opt,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: _selectedGender.value,
                    activeColor: AppColors.primaryMaroon,
                    visualDensity: VisualDensity.compact,
                    onChanged: (val) {
                      if (val != null) {
                        _selectedGender.value = val;
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opt,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryMaroon : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // 4. WEIGHT RANGE TAB (Range Slider)
  Widget _buildWeightRangeTab() {
    return Obx(() {
      final range = _selectedWeightRange.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Range Selection',
            style: GoogleFonts.cinzel(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMaroon,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${range.start.toStringAsFixed(1)} gm',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Text(
                'Max: ${range.end.toStringAsFixed(1)} gm',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RangeSlider(
            values: range,
            min: 1.0,
            max: 2000.0,
            activeColor: AppColors.primaryMaroon,
            inactiveColor: AppColors.border,
            labels: RangeLabels(
              '${range.start.toStringAsFixed(1)} gm',
              '${range.end.toStringAsFixed(1)} gm',
            ),
            onChanged: (newRange) {
              _selectedWeightRange.value = newRange;
            },
          ),
        ],
      );
    });
  }
}
