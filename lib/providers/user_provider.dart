import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

class UserProvider extends ChangeNotifier {
  UserProfileModel? _user;
  bool _isLoaded = false;

  UserProfileModel? get user => _user;
  bool get isLoaded => _isLoaded;

  // Chargement depuis Firestore
  Future<void> loadUser(String uid) async {
    try {
      _isLoaded = false;
      notifyListeners();

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserProfileModel.fromFirestore(doc);
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      _isLoaded = false;
      rethrow;
    }
  }

  // Mise à jour des infos de l'utilisateur
  Future<void> updateUser(UserProfileModel updatedUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Pour forcer le rafraîchissement
  void clear() {
    _user = null;
    _isLoaded = false;
    notifyListeners();
  }
}
