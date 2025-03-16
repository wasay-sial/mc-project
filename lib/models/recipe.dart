import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String userId;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userId,
    required this.ingredients,
    required this.instructions,
    required this.categories,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'userId': userId,
      'ingredients': ingredients,
      'instructions': instructions,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Recipe copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? userId,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    String? status,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
