class HomeCategoryResponseModel {
  final bool success;
  final List<HomeCategoryModel> data;

  HomeCategoryResponseModel({
    required this.success,
    required this.data,
  });

  factory HomeCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<HomeCategoryModel> dataList = list != null
        ? list.map((i) => HomeCategoryModel.fromJson(i)).toList()
        : [];
    return HomeCategoryResponseModel(
      success: json['success'] as bool? ?? false,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((v) => v.toJson()).toList(),
    };
  }
}

class HomeCategoryModel {
  final String id;
  final String categoryName;
  final String image;
  final int displayOrder;
  final int productCount;
  final bool isActive;

  HomeCategoryModel({
    required this.id,
    required this.categoryName,
    required this.image,
    required this.displayOrder,
    required this.productCount,
    required this.isActive,
  });

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      id: json['_id']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      displayOrder: json['displayOrder'] as int? ?? 1,
      productCount: json['productCount'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryName': categoryName,
      'image': image,
      'displayOrder': displayOrder,
      'productCount': productCount,
      'isActive': isActive,
    };
  }
}
