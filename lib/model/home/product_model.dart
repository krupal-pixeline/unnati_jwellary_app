class ProductResponseModel {
  final bool success;
  final List<ProductDataModel> data;

  ProductResponseModel({
    required this.success,
    required this.data,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<ProductDataModel> dataList = list != null
        ? list.map((i) => ProductDataModel.fromJson(i)).toList()
        : [];
    return ProductResponseModel(
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

class ProductDataModel {
  final String id;
  final String productName;
  final String description;
  final String metalType;
  final String purity;
  final double? weight;
  final String gender;
  final List<String> images;
  final List<String> tags;
  final double? rating;
  final int? reviews;
  final String categoryName;
  final String subCategoryName;
  final double? calculatedPrice;
  final double? baseRate;
  final double? metalValue;
  final double? makingCharge;
  final String? makingChargeType;
  final double? makingChargeValue;
  final double? otherCharge;
  final String? otherChargeType;
  final double? otherChargeValue;
  final double? gst;
  final String? gstType;
  final double? gstValue;
  final List<ProductSpecificationModel> specifications;

  ProductDataModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.metalType,
    required this.purity,
    this.weight,
    required this.gender,
    required this.images,
    required this.tags,
    this.calculatedPrice,
    this.baseRate,
    this.metalValue,
    this.makingCharge,
    this.makingChargeType,
    this.makingChargeValue,
    this.otherCharge,
    this.otherChargeType,
    this.otherChargeValue,
    this.gst,
    this.gstType,
    this.gstValue,
    this.rating,
    this.reviews,
    required this.categoryName,
    required this.subCategoryName,
    required this.specifications,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List?;
    List<String> imgs = imagesList != null
        ? imagesList.map((i) => i.toString()).toList()
        : [];
    var tagsList = json['tags'] as List?;
    List<String> tgs = tagsList != null
        ? tagsList.map((i) => i.toString()).toList()
        : [];

    var specificationsList = json['specifications'] as List?;
    List<ProductSpecificationModel> specs = specificationsList != null
        ? specificationsList.map((i) => ProductSpecificationModel.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    final categoryObj = json['category'];
    final String catName = categoryObj is Map
        ? (categoryObj['categoryName']?.toString() ?? 'Necklace')
        : 'Necklace';

    final subCategoryObj = json['subCategory'];
    final String subCatName = subCategoryObj is Map
        ? (subCategoryObj['subCategoryName']?.toString() ?? '')
        : '';

    return ProductDataModel(
      id: json['_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      metalType: json['metalType']?.toString() ?? '',
      purity: json['purity']?.toString() ?? '',
      weight: json['weight'] != null ? (double.tryParse(json['weight'].toString())) : null,
      gender: json['gender']?.toString() ?? '',
      images: imgs,
      tags: tgs,
      calculatedPrice: json['calculatedPrice'] != null ? (double.tryParse(json['calculatedPrice'].toString())) : null,
      baseRate: json['baseRate'] != null ? (double.tryParse(json['baseRate'].toString())) : null,
      metalValue: json['metalValue'] != null ? (double.tryParse(json['metalValue'].toString())) : null,
      makingCharge: json['makingCharge'] != null ? (double.tryParse(json['makingCharge'].toString())) : null,
      makingChargeType: json['makingChargeType']?.toString(),
      makingChargeValue: json['makingChargeValue'] != null ? (double.tryParse(json['makingChargeValue'].toString())) : null,
      otherCharge: json['otherCharge'] != null ? (double.tryParse(json['otherCharge'].toString())) : null,
      otherChargeType: json['otherChargeType']?.toString(),
      otherChargeValue: json['otherChargeValue'] != null ? (double.tryParse(json['otherChargeValue'].toString())) : null,
      gst: json['gst'] != null ? (double.tryParse(json['gst'].toString())) : null,
      gstType: json['gstType']?.toString(),
      gstValue: json['gstValue'] != null ? (double.tryParse(json['gstValue'].toString())) : null,
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString())) : null,
      reviews: json['reviews'] as int?,
      categoryName: catName,
      subCategoryName: subCatName,
      specifications: specs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': productName,
      'description': description,
      'metalType': metalType,
      'weight': weight,
      'gender': gender,
      'images': images,
      'tags': tags,
      'calculatedPrice': calculatedPrice,
      'baseRate': baseRate,
      'metalValue': metalValue,
      'makingCharge': makingCharge,
      'makingChargeType': makingChargeType,
      'makingChargeValue': makingChargeValue,
      'otherCharge': otherCharge,
      'otherChargeType': otherChargeType,
      'otherChargeValue': otherChargeValue,
      'gst': gst,
      'gstType': gstType,
      'gstValue': gstValue,
      'rating': rating,
      'reviews': reviews,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'specifications': specifications.map((s) => s.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUiMap() {
    // Handle dynamic network image
    final String displayImage = images.isNotEmpty ? images.first : '';
    
    // Indian Currency formatting (e.g. 1,04,726)
    String displayPrice = '₹0';
    if (calculatedPrice != null) {
      final double val = calculatedPrice!;
      final String valStr = val.toStringAsFixed(0);
      if (valStr.length <= 3) {
        displayPrice = '₹$valStr';
      } else {
        final String lastThree = valStr.substring(valStr.length - 3);
        final String other = valStr.substring(0, valStr.length - 3);
        final String formattedOther = other.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        displayPrice = '₹$formattedOther,$lastThree';
      }
    }

    return {
      'id': id,
      'name': productName,
      'price': displayPrice,
      'category': categoryName,
      'subCategoryName': subCategoryName,
      'originalPrice': '', // API does not return MRP
      'weight': weight != null ? '${weight}g' : null,
      'karat': purity.isNotEmpty ? purity : null,
      'purity': purity.isNotEmpty ? purity : null,
      'metal': metalType.isNotEmpty ? metalType : null,
      'gender': gender.isNotEmpty ? gender : null,
      'image': displayImage,
      'rating': rating,
      'reviews': reviews,
      'isWishlisted': false,
      'badge': tags.contains('best sellers')
          ? 'BESTSELLER'
          : (tags.contains('new arrivals') ? 'NEW' : null),
      'description': description,
      'baseRate': baseRate,
      'metalValue': metalValue,
      'makingCharge': makingCharge,
      'makingChargeType': makingChargeType,
      'makingChargeValue': makingChargeValue,
      'otherCharge': otherCharge,
      'otherChargeType': otherChargeType,
      'otherChargeValue': otherChargeValue,
      'gst': gst,
      'gstType': gstType,
      'gstValue': gstValue,
      'calculatedPrice': calculatedPrice,
      'specifications': specifications.map((s) => s.toJson()).toList(),
    };
  }
}

class ProductDetailResponseModel {
  final bool success;
  final ProductDataModel data;

  ProductDetailResponseModel({
    required this.success,
    required this.data,
  });

  factory ProductDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponseModel(
      success: json['success'] as bool? ?? false,
      data: ProductDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ProductSpecificationModel {
  final String name;
  final String value;

  ProductSpecificationModel({required this.name, required this.value});

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    return ProductSpecificationModel(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
