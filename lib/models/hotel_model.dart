class HotelModel {
  final String id;
  final String name;
  final String city; // Makkah or Madinah
  final int starRating;
  final String? image;
  final String distanceFromHaram;

  HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.starRating,
    this.image,
    required this.distanceFromHaram,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? 'Makkah',
      starRating: (json['star_rating'] as num?)?.toInt() ?? 5,
      image: json['image'] as String?,
      distanceFromHaram: json['distance_from_haram'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'star_rating': starRating,
      'image': image,
      'distance_from_haram': distanceFromHaram,
    };
  }
}
