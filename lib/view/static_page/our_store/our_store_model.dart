class OurStoreModel {
  final String id;
  final String address;
  final String hoursWeekdays;
  final String hoursSunday;
  final String phone;
  final String email;
  final String mediaType;
  final String imageUrl;

  OurStoreModel({
    required this.id,
    required this.address,
    required this.hoursWeekdays,
    required this.hoursSunday,
    required this.phone,
    required this.email,
    required this.mediaType,
    required this.imageUrl,
  });

  factory OurStoreModel.fromJson(Map<String, dynamic> json) {
    return OurStoreModel(
      id: json['_id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      hoursWeekdays: json['hoursWeekdays']?.toString() ?? '',
      hoursSunday: json['hoursSunday']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'image',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'address': address,
      'hoursWeekdays': hoursWeekdays,
      'hoursSunday': hoursSunday,
      'phone': phone,
      'email': email,
      'mediaType': mediaType,
      'imageUrl': imageUrl,
    };
  }
}
