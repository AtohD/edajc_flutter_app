import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/user_service.dart';

class UserListProvider extends ChangeNotifier {
  final UserService _service = UserService();

  List<UserProfileModel> _users = [];
  bool _isLoading = false;

  List<UserProfileModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    _users = await _service.fetchUsers();

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Nouvelle version avec `uid` obligatoire
  Future<void> addUser(String uid, UserProfileModel user) async {
    await _service.addUser(uid, user);
    await loadUsers();
  }

  Future<void> updateUser(String uid, UserProfileModel user) async {
    await _service.updateUser(uid, user);
    await loadUsers();
  }

  Future<void> deleteUser(String uid) async {
    await _service.deleteUser(uid);
    await loadUsers();
  }
}
