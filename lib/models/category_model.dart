// lib/models/category_model.dart

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      description: map['description'],
    );
  }
}
