import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> favoriteRecipes;
  final List<String> createdRecipes;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    List<String>? favoriteRecipes,
    List<String>? createdRecipes,
    this.isAdmin = false,
    required this.createdAt,
    this.lastLoginAt,
  }) : favoriteRecipes = favoriteRecipes ?? [],
       createdRecipes = createdRecipes ?? [];

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
      createdRecipes: List<String>.from(data['createdRecipes'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt:
          data['lastLoginAt'] != null
              ? (data['lastLoginAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteRecipes': favoriteRecipes,
      'createdRecipes': createdRecipes,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? favoriteRecipes,
    List<String>? createdRecipes,
    bool? isAdmin,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      createdRecipes: createdRecipes ?? this.createdRecipes,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
