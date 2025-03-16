import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _selectedCategories = [];

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => _selectedCategories;

  RecipeProvider() {
    _loadRecipes();
  }

  void _loadRecipes() {
    _firebaseService.getRecipes().listen((QuerySnapshot snapshot) {
      _recipes = snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
      _filterRecipes();
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterRecipes();
    notifyListeners();
  }

  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    _filterRecipes();
    notifyListeners();
  }

  void _filterRecipes() {
    if (_searchQuery.isEmpty && _selectedCategories.isEmpty) {
      return;
    }

    _recipes =
        _recipes.where((recipe) {
          bool matchesSearch =
              _searchQuery.isEmpty ||
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              recipe.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          bool matchesCategories =
              _selectedCategories.isEmpty ||
              _selectedCategories.any((cat) => recipe.categories.contains(cat));

          return matchesSearch && matchesCategories;
        }).toList();
  }

  Future<String> addRecipe({
    required String title,
    required String description,
    required String imagePath,
    required String userId,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> categories,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final imageUrl = await _firebaseService.uploadRecipeImage(
        userId,
        imagePath,
      );

      final recipe = Recipe(
        id: '',
        title: title,
        description: description,
        imageUrl: imageUrl,
        userId: userId,
        ingredients: ingredients,
        instructions: instructions,
        categories: categories,
        createdAt: DateTime.now(),
      );

      final recipeId = await _firebaseService.addRecipe(recipe.toMap());
      return recipeId;
    } catch (e) {
      throw Exception('Failed to add recipe: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecipeStatus(String recipeId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.updateRecipeStatus(recipeId, status);
    } catch (e) {
      throw Exception('Failed to update recipe status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
