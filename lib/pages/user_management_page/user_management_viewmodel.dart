import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_list_provider.dart';
import 'user_form_dialog.dart';

class UserManagementWidget extends StatefulWidget {
  const UserManagementWidget({super.key});

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  String _searchQuery = '';
  String? _currentUserEmail;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    setState(() {
      _currentUserEmail = user.email;
      _currentUserRole = data?['role'] ?? 'Invité';
    });
  }

  List<UserProfileModel> _getFilteredUsers(List<UserProfileModel> allUsers) {
    final query = _searchQuery.toLowerCase();
    final isAdmin = _currentUserRole == 'admin';

    return allUsers.where((user) {
      final matchesQuery = user.firstName.toLowerCase().contains(query) ||
          user.lastName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      return isAdmin
          ? matchesQuery
          : (user.createdBy == _currentUserEmail && matchesQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<UserListProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredUsers = _getFilteredUsers(provider.users);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher par nom, prénom ou email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() {
                  _searchQuery = value;
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(child: Text("Aucun utilisateur trouvé."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.grey.shade200,
                        ),
                        columnSpacing: 30,
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("Prénom")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Rôle")),
                          DataColumn(label: Text("Crée Par")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: filteredUsers.map((user) {
                          final isAdmin = _currentUserRole == 'admin';
                          final isMyUser = user.createdBy == _currentUserEmail;
                          final isTargetAdmin = user.role == 'admin';
                          final canEditOrDelete =
                              isAdmin || (!isTargetAdmin && isMyUser);
                          return DataRow(cells: [
                            DataCell(Text(user.lastName)),
                            DataCell(Text(user.firstName)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.role)),
                            DataCell(Text(user.createdBy)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () =>
                                      _showUserDetails(context, user),
                                ),
                                if (canEditOrDelete)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _openUserForm(context, user: user),
                                  ),
                                if (canEditOrDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteUser(context, user.uid),
                                  ),
                                if (!canEditOrDelete) const Text("🔒"),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: FloatingActionButton(
                  onPressed: () => _openUserForm(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openUserForm(BuildContext context, {UserProfileModel? user}) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
  }

  void _deleteUser(BuildContext context, String uid) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Supprimer cet utilisateur ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Supprimer")),
        ],
      ),
    );

    if (shouldDelete == true) {
      final provider = context.read<UserListProvider>();
      await provider.deleteUser(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé.')),
        );
      }
    }
  }

  void _showUserDetails(BuildContext context, UserProfileModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Détails de l'utilisateur"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nom : ${user.lastName}"),
              Text("Prénom : ${user.firstName}"),
              Text("Email : ${user.email}"),
              Text("Rôle : ${user.role}"),
              Text("Date de naissance : ${user.birthDate}"),
              Text("Pays : ${user.country}"),
              Text("Région : ${user.region}"),
              Text("Ville de naissance : ${user.cityOfBirth}"),
              Text("Ethnie : ${user.ethnicity}"),
              Text("Situation matrimoniale : ${user.maritalStatus}"),
              Text("Nombre d'enfants : ${user.childrenCount}"),
              Text("Formation : ${user.education}"),
              Text("Profession : ${user.job}"),
              Text("Langues parlées : ${user.languages.join(', ')}"),
              Text("Témoignage : ${user.testimony}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}
