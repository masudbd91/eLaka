// lib/models/listing_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String subcategory;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String neighborhood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final List<String> tags;
  final double ratings;
  final int reviewCount;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.neighborhood,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.tags,
    required this.ratings,
    required this.reviewCount,
    required String location,
    required List<String> images,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null
              ? DateTime.parse(map['createdAt'].toString())
              : DateTime.now()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'].toString())
              : DateTime.now()),
      status: map['status'] ?? ListingStatus.available.value,
      tags: List<String>.from(map['tags'] ?? []),
      ratings: (map['ratings'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      location: '',
      images: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'subcategory': subcategory,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'neighborhood': neighborhood,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'tags': tags,
      'ratings': ratings,
      'reviewCount': reviewCount,
    };
  }

  // Add a copyWith method for easy updates
  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? subcategory,
    List<String>? imageUrls,
    String? sellerId,
    String? sellerName,
    String? neighborhood,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? tags,
    double? ratings,
    int? reviewCount,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      neighborhood: neighborhood ?? this.neighborhood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      ratings: ratings ?? this.ratings,
      reviewCount: reviewCount ?? this.reviewCount,
      location: '',
      images: [],
    );
  }
}

enum ListingStatus { available, sold, reserved, deleted }

extension ListingStatusExtension on ListingStatus {
  String get value {
    switch (this) {
      case ListingStatus.available:
        return 'available';
      case ListingStatus.sold:
        return 'sold';
      case ListingStatus.reserved:
        return 'reserved';
      case ListingStatus.deleted:
        return 'deleted';
    }
  }

  static ListingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return ListingStatus.available;
      case 'sold':
        return ListingStatus.sold;
      case 'reserved':
        return ListingStatus.reserved;
      case 'deleted':
        return ListingStatus.deleted;
      default:
        return ListingStatus.available;
    }
  }
}
