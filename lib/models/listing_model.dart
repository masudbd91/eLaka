// File: lib/models/listing_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingStatus { active, sold, deleted }

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
  final DateTime createdAt;
  final DateTime updatedAt;
  final ListingStatus status;

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
    required this.tags,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    required this.updatedAt,
    this.status = ListingStatus.active,
  });

  // Convert ListingModel to Map for Firestore
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
      'createdAt': createdAt.toUtc(),
      'updatedAt': updatedAt.toUtc(),
      'status': status.toString().split('.').last,
    };
  }

  // Create ListingModel from Firestore document
  factory ListingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ListingModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      neighborhood: map['neighborhood'] ?? '',
      location: map['location'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'].toString()))
          : DateTime.now(),
      status: map['status'] != null
          ? ListingStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => ListingStatus.active,
      )
          : ListingStatus.active,
    );
  }

  // Create a copy of this ListingModel with given fields replaced with new values
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
    DateTime? createdAt,
    DateTime? updatedAt,
    ListingStatus? status,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
