import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser == null) return;

    try {
      final userData = await _firebaseService.getUserProfile(
        _firebaseUser!.uid,
      );
      if (userData != null) {
        _user = UserModel.fromFirestore(userData as DocumentSnapshot);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _firebaseService.signUp(email, password);

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createUserProfile(user.id, user.toMap());

      _user = user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.signIn(email, password);
      await _loadUserData();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.signOut();
      _user = null;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = _user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      await _firebaseService.createUserProfile(_user!.id, updatedUser.toMap());
      _user = updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
