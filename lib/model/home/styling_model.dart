class StylingResponseModel {
  final bool success;
  final int count;
  final List<StylingDataModel> data;

  StylingResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory StylingResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<StylingDataModel> dataList = list != null
        ? list.map((i) => StylingDataModel.fromJson(i)).toList()
        : [];
    return StylingResponseModel(
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

class StylingDataModel {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String databaseId;

  StylingDataModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.databaseId,
  });

  factory StylingDataModel.fromJson(Map<String, dynamic> json) {
    return StylingDataModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      databaseId: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      '_id': databaseId,
    };
  }
}
