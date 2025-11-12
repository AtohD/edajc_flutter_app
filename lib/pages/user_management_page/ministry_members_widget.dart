import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_list_provider.dart';
import 'ministry_members_form_dialog.dart';

class MinistryMembersWidget extends StatefulWidget {
  const MinistryMembersWidget({super.key});

  @override
  State<MinistryMembersWidget> createState() => _MinistryMembersWidgetState();
}

class _MinistryMembersWidgetState extends State<MinistryMembersWidget> {
  String _searchQuery = '';
  String? _currentUserRole;
  String? _currentUserUid;

  final Color primaryColor = const Color(0xFF004AAD); // Bleu du logo
  final Color secondaryColor = const Color(0xFFFFC107); // Jaune du logo

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
      _currentUserUid = user.uid;
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
          : (user.createdByUid == _currentUserUid && matchesQuery);
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
        final isMobile = MediaQuery.of(context).size.width < 800;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Ligne avec champ recherche + bouton +
                Row(
                  children: [
                    // Champ recherche stylé
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom, prénom ou email...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Bouton + plus petit et stylé
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () => _openUserForm(context),
                        tooltip: "Ajouter un utilisateur",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tableau
                Expanded(
                  child: isMobile
                      ? _buildMobileList(filteredUsers)
                      : _buildDesktopTable(filteredUsers),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ TABLEAU POUR GRAND ÉCRAN
  Widget _buildDesktopTable(List<UserProfileModel> users) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 1300, // largeur fixe du tableau
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text(
                "Liste des utilisateurs",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              rowsPerPage: 5,
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Identifiant",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Nom",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Prénom",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 180,
                    child: Text("Email",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text("Rôle",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Créé Par",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Actions",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              source: UserDataSource(
                users: users,
                onView: (u) => _showUserDetails(context, u),
                onEdit: (u) => _openUserForm(context, user: u),
                onDelete: (id) => _deleteUser(context, id),
                currentUserRole: _currentUserRole ?? '',
                currentUserUid: _currentUserUid ?? '',
                primaryColor: primaryColor,
                // dans getRow aussi il faudra fixer les tailles
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ LISTE POUR MOBILE
  Widget _buildMobileList(List<UserProfileModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text("${user.firstName} ${user.lastName}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email : ${user.email}"),
                Text("Rôle : ${user.role}"),
                Text("Créé par : ${user.createdBy}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: primaryColor),
                  onPressed: () => _showUserDetails(context, user),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _openUserForm(context, user: user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(context, user.uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openUserForm(BuildContext context, {UserProfileModel? user}) {
    showDialog(
      context: context,
      builder: (_) => MinistryMembersDialog(user: user),
    );
  }

  // _sort removed (unused)

  // _getFieldValue removed (unused)

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
              Text("Identifiant : ${user.contacts['mobile'] ?? ''}"),
              Text("Nom : ${user.lastName}"),
              Text("Prénom : ${user.firstName}"),
              Text("Email : ${user.email}"),
              Text("Mobile : ${user.contacts['mobile'] ?? ''}"),
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

class UserDataSource extends DataTableSource {
  final List<UserProfileModel> users;
  final void Function(UserProfileModel) onView;
  final void Function(UserProfileModel) onEdit;
  final void Function(String) onDelete;
  final String currentUserRole;
  final String currentUserUid;
  final Color primaryColor;

  UserDataSource({
    required this.users,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.currentUserRole,
    required this.currentUserUid,
    required this.primaryColor,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    final isAdmin = currentUserRole == 'admin';
    final isMyUser = user.createdByUid == currentUserUid;
    final isTargetAdmin = user.role == 'admin';
    final canEditOrDelete = isAdmin || (!isTargetAdmin && isMyUser);

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(SizedBox(
            width: 120,
            child: Text(user.contacts['mobile'] ?? '',
                overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(user.lastName, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(user.firstName, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 180,
            child: Text(user.email, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 100,
            child: Text(user.role, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(user.createdBy, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.info_outline, color: primaryColor),
                onPressed: () => onView(user),
                tooltip: 'Voir',
              ),
              if (canEditOrDelete)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => onEdit(user),
                  tooltip: 'Modifier',
                ),
              if (canEditOrDelete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(user.uid),
                  tooltip: 'Supprimer',
                ),
            ],
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}
