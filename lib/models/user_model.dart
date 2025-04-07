// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String profileImageUrl;
  final String location;
  final double ratings;
  final int reviewCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.createdAt,
    required this.lastLogin,
    required this.profileImageUrl,
    required this.location,
    required this.ratings,
    required this.reviewCount,
    required String neighborhood,
    required DateTime lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'ratings': ratings,
      'reviewCount': reviewCount,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: map['lastLogin']?.toDate() ?? DateTime.now(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      location: map['location'] ?? '',
      ratings: (map['ratings'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      neighborhood: 'jeshore',
      lastActive: DateTime.now(),
    );
  }
}
