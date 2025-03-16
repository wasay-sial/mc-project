import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication methods
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User profile methods
  Future<void> createUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // Recipe methods
  Future<String> uploadRecipeImage(String userId, String imagePath) async {
    final ref = _storage.ref().child('recipes/$userId/${DateTime.now()}.jpg');
    final uploadTask = await ref.putFile(File(imagePath));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> addRecipe(Map<String, dynamic> recipe) async {
    final docRef = await _firestore.collection('recipes').add(recipe);
    return docRef.id;
  }

  Stream<QuerySnapshot> getRecipes() {
    return _firestore
        .collection('recipes')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateRecipeStatus(String recipeId, String status) async {
    await _firestore.collection('recipes').doc(recipeId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
