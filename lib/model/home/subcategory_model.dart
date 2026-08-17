class SubCategoryResponseModel {
  final bool success;
  final List<SubCategoryDataModel> data;

  SubCategoryResponseModel({
    required this.success,
    required this.data,
  });

  factory SubCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<SubCategoryDataModel> dataList = list != null
        ? list.map((i) => SubCategoryDataModel.fromJson(i)).toList()
        : [];
    return SubCategoryResponseModel(
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

class SubCategoryDataModel {
  final String id;
  final String subCategoryName;
  final String image;
  final bool isActive;

  SubCategoryDataModel({
    required this.id,
    required this.subCategoryName,
    required this.image,
    required this.isActive,
  });

  factory SubCategoryDataModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryDataModel(
      id: json['_id']?.toString() ?? '',
      subCategoryName: json['subCategoryName']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subCategoryName': subCategoryName,
      'image': image,
      'isActive': isActive,
    };
  }
}
