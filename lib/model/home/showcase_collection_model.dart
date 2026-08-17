import 'product_model.dart';

class ShowcaseCollection {
  final String id;
  final String title;
  final String description;
  final String backgroundImage;
  final List<ProductDataModel> products;

  ShowcaseCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.backgroundImage,
    required this.products,
  });

  factory ShowcaseCollection.fromJsonList(List<dynamic> list) {
    final collectionJson = list.firstWhere(
      (item) => item is Map && item.containsKey('title'),
      orElse: () => null,
    );

    if (collectionJson == null) {
      throw Exception("Collection info not found in showcase data");
    }

    final List<ProductDataModel> productsList = [];
    for (var item in list) {
      if (item is Map && item.containsKey('productName')) {
        productsList.add(ProductDataModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return ShowcaseCollection(
      id: collectionJson['id']?.toString() ?? collectionJson['_id']?.toString() ?? '',
      title: collectionJson['title']?.toString() ?? '',
      description: collectionJson['description']?.toString() ?? '',
      backgroundImage: collectionJson['backgroundImage']?.toString() ?? '',
      products: productsList,
    );
  }
}
