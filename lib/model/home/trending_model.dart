class TrendingResponseModel {
  final bool success;
  final int count;
  final List<TrendingDataModel> data;

  TrendingResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory TrendingResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<TrendingDataModel> dataList = list != null
        ? list.map((i) => TrendingDataModel.fromJson(i)).toList()
        : [];
    return TrendingResponseModel(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((v) => v.toJson()).toList(),
    };
  }
}

class TrendingDataModel {
  final String id;
  final String productId;
  final String title;
  final String subtitle;
  final String databaseId;

  TrendingDataModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.databaseId,
  });

  factory TrendingDataModel.fromJson(Map<String, dynamic> json) {
    return TrendingDataModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      databaseId: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'subtitle': subtitle,
      '_id': databaseId,
    };
  }
}
