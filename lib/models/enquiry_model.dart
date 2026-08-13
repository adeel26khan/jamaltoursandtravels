class EnquiryModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? packageInterest;
  final DateTime? preferredDate;
  final int numPilgrims;
  final String? message;
  final String status; // new, contacted, closed
  final DateTime createdAt;

  EnquiryModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.packageInterest,
    this.preferredDate,
    this.numPilgrims = 1,
    this.message,
    this.status = 'new',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      packageInterest: json['package_interest'] as String?,
      preferredDate: json['preferred_date'] != null
          ? DateTime.tryParse(json['preferred_date'] as String)
          : null,
      numPilgrims: (json['num_pilgrims'] as num?)?.toInt() ?? 1,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'new',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'package_interest': packageInterest,
      'preferred_date': preferredDate?.toIso8601String().split('T').first,
      'num_pilgrims': numPilgrims,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
