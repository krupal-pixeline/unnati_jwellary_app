class BannerResponseModel {
  final bool success;
  final int count;
  final List<BannerDataModel> data;

  BannerResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<BannerDataModel> dataList = list != null
        ? list.map((i) => BannerDataModel.fromJson(i)).toList()
        : [];
    return BannerResponseModel(
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

class BannerDataModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String btnText;
  final String linkType;
  final String linkTarget;
  final bool active;
  final String databaseId;

  BannerDataModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.btnText,
    required this.linkType,
    required this.linkTarget,
    required this.active,
    required this.databaseId,
  });

  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
    return BannerDataModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      btnText: json['btnText']?.toString() ?? '',
      linkType: json['linkType']?.toString() ?? '',
      linkTarget: json['linkTarget']?.toString() ?? '',
      active: json['active'] as bool? ?? false,
      databaseId: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'btnText': btnText,
      'linkType': linkType,
      'linkTarget': linkTarget,
      'active': active,
      '_id': databaseId,
    };
  }
}
