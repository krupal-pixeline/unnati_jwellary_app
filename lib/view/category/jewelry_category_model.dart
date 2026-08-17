class JewelryCategory {
  final String id;
  final String name;
  final String subtitle;
  final String imagePath;
  final int productCount;
  final List<String> tags;
  final bool isFeatured;
  final double startingPrice;
  final List<JewelrySubCategory> subCategories;

  const JewelryCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.productCount,
    required this.tags,
    this.isFeatured = false,
    required this.startingPrice,
    this.subCategories = const [],
  });
}

class JewelrySubCategory {
  final String id;
  final String name;
  final String subtitle;
  final String imagePath;
  final List<Map<String, dynamic>> products;

  const JewelrySubCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.products,
  });
}

class FilterOption {
  final String id;
  final String label;
  bool isSelected;
  FilterOption({required this.id, required this.label, this.isSelected = false});
}
