class ProfileModel {
  final String id;
  final String phone;
  final String? fullName;
  final String? email;
  final String role; // pilgrim or admin
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.phone,
    this.fullName,
    this.email,
    this.role = 'pilgrim',
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'pilgrim',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? phone,
    String? fullName,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
