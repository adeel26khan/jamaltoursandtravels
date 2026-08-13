class PilgrimModel {
  final String id;
  final String bookingId;
  final String fullName;
  final String? passportNumber;
  final DateTime? dateOfBirth;
  final String? gender; // male, female
  final String relation; // Self, Spouse, Child, Parent, Other

  PilgrimModel({
    required this.id,
    required this.bookingId,
    required this.fullName,
    this.passportNumber,
    this.dateOfBirth,
    this.gender,
    this.relation = 'Self',
  });

  factory PilgrimModel.fromJson(Map<String, dynamic> json) {
    return PilgrimModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      passportNumber: json['passport_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      relation: json['relation'] as String? ?? 'Self',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'full_name': fullName,
      'passport_number': passportNumber,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'relation': relation,
    };
  }
}
