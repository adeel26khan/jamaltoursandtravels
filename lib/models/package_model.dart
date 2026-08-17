class PackageModel {
  final String id;
  final String title;
  final String type; // hajj, umrah, air_ticket
  final String description;
  final int durationDays;
  final int makkahNights;
  final int madinahNights;
  final double priceInr;
  final double gstRate; // percentage e.g. 5.0
  final double? originalPriceInr;
  final String? badge;
  final int maxSeats;
  final int availableSeats;
  final List<String> images;
  final List<String> inclusions;
  final List<String> exclusions;
  final bool isActive;
  final DateTime createdAt;

  PackageModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.durationDays,
    required this.makkahNights,
    required this.madinahNights,
    required this.priceInr,
    this.gstRate = 5.0,
    this.originalPriceInr,
    this.badge,
    this.maxSeats = 50,
    this.availableSeats = 50,
    this.images = const [],
    this.inclusions = const [],
    this.exclusions = const [],
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get gstAmount => priceInr * (gstRate / 100);
  double get totalPriceWithGst => priceInr + gstAmount;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'umrah',
      description: json['description'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 1,
      makkahNights: (json['makkah_nights'] as num?)?.toInt() ?? 0,
      madinahNights: (json['madinah_nights'] as num?)?.toInt() ?? 0,
      priceInr: (json['price_inr'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 5.0,
      originalPriceInr: (json['original_price_inr'] as num?)?.toDouble(),
      badge: json['badge'] as String?,
      maxSeats: (json['max_seats'] as num?)?.toInt() ?? 50,
      availableSeats: (json['available_seats'] as num?)?.toInt() ?? 50,
      images: json['images'] != null ? List<String>.from(json['images'] as List) : [],
      inclusions: json['inclusions'] != null ? List<String>.from(json['inclusions'] as List) : [],
      exclusions: json['exclusions'] != null ? List<String>.from(json['exclusions'] as List) : [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseJson({bool includeId = false}) {
    final data = <String, dynamic>{
      'title': title,
      'type': type,
      'description': description,
      'duration_days': durationDays,
      'makkah_nights': makkahNights,
      'madinah_nights': madinahNights,
      'price_inr': priceInr,
      'gst_rate': gstRate,
      'original_price_inr': originalPriceInr,
      'badge': badge,
      'max_seats': maxSeats,
      'available_seats': availableSeats,
      'images': images,
      'inclusions': inclusions,
      'exclusions': exclusions,
      'is_active': isActive,
    };
    if (includeId && id.length == 36 && !id.startsWith('pkg_')) {
      data['id'] = id;
    }
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'duration_days': durationDays,
      'makkah_nights': makkahNights,
      'madinah_nights': madinahNights,
      'price_inr': priceInr,
      'gst_rate': gstRate,
      'original_price_inr': originalPriceInr,
      'badge': badge,
      'max_seats': maxSeats,
      'available_seats': availableSeats,
      'images': images,
      'inclusions': inclusions,
      'exclusions': exclusions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
