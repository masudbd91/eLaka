class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String neighborhood;
  final String imageUrl;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final List<String> favoriteListings;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.neighborhood,
    this.imageUrl = '',
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.favoriteListings = const [],
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      favoriteListings: List<String>.from(map['favoriteListings'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'neighborhood': neighborhood,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'rating': rating,
      'reviewCount': reviewCount,
      'favoriteListings': favoriteListings,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? neighborhood,
    String? imageUrl,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    List<String>? favoriteListings,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      neighborhood: neighborhood ?? this.neighborhood,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      favoriteListings: favoriteListings ?? this.favoriteListings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}