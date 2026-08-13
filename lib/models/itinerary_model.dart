class PackageItineraryModel {
  final String id;
  final String packageId;
  final int dayNumber;
  final String title;
  final String description;
  final String city; // Makkah, Madinah, Transit

  PackageItineraryModel({
    required this.id,
    required this.packageId,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.city,
  });

  factory PackageItineraryModel.fromJson(Map<String, dynamic> json) {
    return PackageItineraryModel(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      dayNumber: (json['day_number'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      city: json['city'] as String? ?? 'Makkah',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'day_number': dayNumber,
      'title': title,
      'description': description,
      'city': city,
    };
  }
}
