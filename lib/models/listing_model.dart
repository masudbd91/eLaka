enum ListingStatus { active, reserved, sold }

class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String subcategory;
  final List<String> imageUrls;
  final String neighborhood;
  final String location;
  final List<String> tags;
  final String sellerId;
  final String sellerName;
  final String sellerImageUrl;
  final bool isSellerVerified;
  final ListingStatus status;
  final int viewCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.imageUrls,
    required this.neighborhood,
    required this.location,
    this.tags = const [],
    required this.sellerId,
    required this.sellerName,
    this.sellerImageUrl = '',
    this.isSellerVerified = false,
    this.status = ListingStatus.active,
    this.viewCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      neighborhood: map['neighborhood'] ?? '',
      location: map['location'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerImageUrl: map['sellerImageUrl'] ?? '',
      isSellerVerified: map['isSellerVerified'] ?? false,
      status: ListingStatus.values.firstWhere(
            (e) => e.toString() == 'ListingStatus.${map['status'] ?? 'active'}',
        orElse: () => ListingStatus.active,
      ),
      viewCount: map['viewCount'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'subcategory': subcategory,
      'imageUrls': imageUrls,
      'neighborhood': neighborhood,
      'location': location,
      'tags': tags,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerImageUrl': sellerImageUrl,
      'isSellerVerified': isSellerVerified,
      'status': status.toString().split('.').last,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? subcategory,
    List<String>? imageUrls,
    String? neighborhood,
    String? location,
    List<String>? tags,
    String? sellerId,
    String? sellerName,
    String? sellerImageUrl,
    bool? isSellerVerified,
    ListingStatus? status,
    int? viewCount,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrls: imageUrls ?? this.imageUrls,
      neighborhood: neighborhood ?? this.neighborhood,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      isSellerVerified: isSellerVerified ?? this.isSellerVerified,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
