// File: lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String neighborhood;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.neighborhood,
    required this.createdAt,
    required this.lastActive,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'neighborhood': neighborhood,
      'createdAt': createdAt.toUtc(),
      'lastActive': lastActive.toUtc(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] is Timestamp
          ? (map['lastActive'] as Timestamp).toDate()
          : DateTime.parse(map['lastActive'].toString()))
          : DateTime.now(),
    );
  }

  // Create a copy of this UserModel with given fields replaced with new values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? neighborhood,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      neighborhood: neighborhood ?? this.neighborhood,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
