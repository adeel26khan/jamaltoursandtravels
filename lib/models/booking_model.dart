class BookingModel {
  final String id;
  final String userId;
  final String packageId;
  final String status; // pending, confirmed, cancelled
  final DateTime travelDate;
  final int numPilgrims;
  final double totalAmount;
  final String paymentStatus; // unpaid, partially_paid, paid, refunded
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.packageId,
    this.status = 'pending',
    required this.travelDate,
    this.numPilgrims = 1,
    required this.totalAmount,
    this.paymentStatus = 'unpaid',
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      packageId: json['package_id'] as String,
      status: json['status'] as String? ?? 'pending',
      travelDate: json['travel_date'] != null
          ? DateTime.parse(json['travel_date'] as String)
          : DateTime.now(),
      numPilgrims: (json['num_pilgrims'] as num?)?.toInt() ?? 1,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'status': status,
      'travel_date': travelDate.toIso8601String().split('T').first,
      'num_pilgrims': numPilgrims,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
