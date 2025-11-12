import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> usersRef =
      FirebaseFirestore.instance.collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<UserProfileModel>> fetchUsers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final doc = await usersRef.doc(currentUser.uid).get();
    if (!doc.exists) return [];

    final role = doc.data()?['role']?.toString().toLowerCase();

    QuerySnapshot<Map<String, dynamic>> snapshot;

    if (role == 'admin') {
      // Admin voit tous les utilisateurs
      snapshot = await usersRef.get();
    } else if ([
      'directeur regionale',
      'assistant générale',
      'assistant accueil'
    ].contains(role)) {
      // Les assistants/directeurs voient uniquement ceux qu’ils ont créés
      snapshot = await usersRef
          .where('createdByUid', isEqualTo: currentUser.uid)
          .get();
    } else {
      // Les autres voient uniquement eux-mêmes
      snapshot = await usersRef.where('uid', isEqualTo: currentUser.uid).get();
    }

    return snapshot.docs
        .map((doc) => UserProfileModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addUser(String uid, UserProfileModel user) async {
    await usersRef.doc(uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, UserProfileModel user) async {
    await usersRef.doc(uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await usersRef.doc(uid).delete();
  }

  Future<UserProfileModel?> getUserByUid(String uid) async {
    final doc = await usersRef.doc(uid).get();
    if (doc.exists) {
      return UserProfileModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await usersRef.doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role']?.toString();
    }
    return null;
  }

  Future<List<UserProfileModel>> fetchUsersCreatedBy(String uid) async {
    final snapshot = await usersRef.where('createdByUid', isEqualTo: uid).get();
    return snapshot.docs
        .map((doc) => UserProfileModel.fromFirestore(doc))
        .toList();
  }
}
