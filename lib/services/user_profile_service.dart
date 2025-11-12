import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserProfileModel?> getUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('Utilisateur non connecté (UID null)');
        return null;
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print('Profil utilisateur non trouvé dans Firestore pour UID : $uid');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        print('Données du document Firestore null pour UID : $uid');
        return null;
      }

      return UserProfileModel.fromMap(data, uid: doc.id);
    } catch (e, stackTrace) {
      print('Erreur lors de la récupération du profil utilisateur : $e');
      print(stackTrace);
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
