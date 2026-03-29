/// Represents a S-GAP platform user (worker or employer).
class User {
  final String id;
  final String name;
  final String phone;
  final String language;
  final String? occupation;
  final String? employerId;
  final String? avatarUrl;
  final String? aadhaarVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.language = 'hi',
    this.occupation,
    this.employerId,
    this.avatarUrl,
    this.aadhaarVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      language: json['language'] as String? ?? 'hi',
      occupation: json['occupation'] as String?,
      employerId: json['employer_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      aadhaarVerified: json['aadhaar_verified'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'language': language,
        'occupation': occupation,
        'employer_id': employerId,
        'avatar_url': avatarUrl,
        'aadhaar_verified': aadhaarVerified,
        'created_at': createdAt.toIso8601String(),
      };

  User copyWith({
    String? name,
    String? phone,
    String? language,
    String? occupation,
    String? employerId,
    String? avatarUrl,
    String? aadhaarVerified,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      occupation: occupation ?? this.occupation,
      employerId: employerId ?? this.employerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      aadhaarVerified: aadhaarVerified ?? this.aadhaarVerified,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, phone: $phone)';
}
