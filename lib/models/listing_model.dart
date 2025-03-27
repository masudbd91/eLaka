// lib/models/listing_model.dart

class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String location;
  final DateTime createdAt;
  final String status; // available, sold, reserved

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.location,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'location': location,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'available',
    );
  }
}
