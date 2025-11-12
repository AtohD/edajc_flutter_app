import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'soul_members_form_dialog.dart';
import 'user_form_dialog.dart';
import 'package:intl/intl.dart'; // 👉 ajoute en haut du fichier

class SoulMembersWidget extends StatefulWidget {
  const SoulMembersWidget({super.key});

  @override
  State<SoulMembersWidget> createState() => _SoulMembersWidgetState();
}

class _SoulMembersWidgetState extends State<SoulMembersWidget> {
  String _searchQuery = '';
  String? _currentUserRole;
  String? _currentUserUid;
  String? _currentUserRegion;
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF004AAD); // Bleu
  final Color secondaryColor = const Color(0xFFFFC107); 
  
  List<Map<String, dynamic>> _combinedDocs = [];
// Jaune

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
      _currentUserRole = data?['role'] ?? 'invité';
      _currentUserRegion = data?['region'] ?? '';
    });
    await _loadCombinedData();
  }

  Future<void> _loadCombinedData() async {
    final soulSnapshot = await FirebaseFirestore.instance
        .collection('soul_members')
        .orderBy('createdAt', descending: true)
        .get();

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Ame')
        .get();

    final souls = soulSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['source'] = 'soul';
      return data;
    }).where((data) {
      // 🔹 filtrer par région
      if (_currentUserRole == 'admin') return true; // Admin voit tout
      if (data['region'] == null) return false; // pas de région = cacher
      return data['region'] == _currentUserRegion;
    }).toList();

    final users = usersSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['source'] = 'user';
      return data;
    }).where((data) {
      if (_currentUserRole == 'admin') return true;
      if (data['region'] == null) return false;
      return data['region'] == _currentUserRegion;
    }).toList();

    setState(() {
      _combinedDocs = [...souls, ...users];
      _isLoading = false;
    });
  }


  Future<void> _deleteSoulMember(String docId, {bool isUser = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Supprimer cette âme ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final collection = isUser ? 'users' : 'soul_members';
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Âme supprimée.")),
        );
        await _loadCombinedData();
      }
    }
  }

  void _openFormDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajout d\'une âme'),
        content: const Text(
            'L’âme que vous souhaitez ajouter possède-t-elle une adresse e-mail ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // ferme ce premier dialogue
              // 👉 si pas de mail
              showDialog(
                context: context,
                builder: (_) => const SoulMembersDialog(),
              ).then((_) => _loadCombinedData());
            },
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // ferme le premier dialogue
              // 👉 si oui, ouvre un autre
              showDialog(
                context: context,
                builder: (_) => const UserFormDialog(),
              ).then((_) => _loadCombinedData());
            },
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> data) {
    // Copie pour éviter de modifier la source originale
    final displayData = Map<String, dynamic>.from(data);

    // 🔹 Détecter le numéro mobile ou contacts.mobile
    String mobileVal = '';
    if (displayData['mobile'] != null && displayData['mobile'].toString().isNotEmpty) {
      mobileVal = displayData['mobile'].toString();
    } else if (displayData['contacts'] is Map && displayData['contacts']['mobile'] != null) {
      mobileVal = displayData['contacts']['mobile'].toString();
    }

    // 🔹 Si 'telephone' est vide, on le crée à partir de 'mobile'
    if ((displayData['telephone'] == null || displayData['telephone'].toString().isEmpty) &&
        mobileVal.isNotEmpty) {
      displayData['telephone'] = mobileVal;
    }

    // 🔹 S'assurer que l'identifiant existe
    displayData['identifiant'] = mobileVal.isNotEmpty ? mobileVal : (displayData['telephone'] ?? '');

    // 🔹 Ordre des champs à afficher
    final orderedKeys = [
      'identifiant',
      'lastName',
      'firstName',
      'telephone',
      'job',
      'region',
      'email',
      'country',
      'cityOfBirth',
      'birthDate',
      'maritalStatus',
      'ethnicity',
      'languages',
      'childrenCount',
      'testimony',
      'createdBy',
      'createdAt',
    ];

    final List<Widget> fields = [];

    for (var key in orderedKeys) {
      if (!displayData.containsKey(key)) continue;
      var value = displayData[key];

      // 🔹 Formatage des dates Firestore
      if (value is Timestamp) {
        value = DateFormat('dd/MM/yyyy à HH:mm').format(value.toDate());
      }

      // 🔹 Formatage des listes
      if (value is List) {
        value = value.join(', ');
      }

      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  "${_formatLabel(key)} :",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  value?.toString() ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Détails du Membre",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields,
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

  /// 🔧 Labels traduits
  String _formatLabel(String key) {
    switch (key) {
      case 'identifiant':
        return 'Identifiant';
      case 'mobile':
        return 'Mobile';
      case 'telephone':
        return 'Téléphone';
      case 'firstName':
        return 'Prénom';
      case 'lastName':
        return 'Nom';
      case 'job':
        return 'Profession';
      case 'region':
        return 'Departement';
      case 'email':
        return 'E-mail';
      case 'country':
        return 'Pays';
      case 'cityOfBirth':
        return 'Ville de naissance';
      case 'birthDate':
        return 'Date de naissance';
      case 'maritalStatus':
        return 'Situation matrimoniale';
      case 'ethnicity':
        return 'Ethnie';
      case 'languages':
        return 'Langues parlées';
      case 'childrenCount':
        return 'Nombre d’enfants';
      case 'testimony':
        return 'Témoignage';
      case 'createdBy':
        return 'Créé par';
      case 'createdAt':
        return 'Date de création';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }




  @override
  Widget build(BuildContext context) {
    // 🔹 Attendre que l'UID et le rôle soient chargés
    if (_currentUserRole == null || _currentUserUid == null) {
      return const Center(child: CircularProgressIndicator());
    }

  final isMobile = MediaQuery.of(context).size.width < 800;

    final filtered = _combinedDocs.where((d) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      final last = (d['lastName'] ?? '').toString().toLowerCase();
      final first = (d['firstName'] ?? '').toString().toLowerCase();
      final mobile = (d['mobile'] ?? '').toString().toLowerCase();
      return last.contains(q) || first.contains(q) || mobile.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Recherche + bouton +
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, prénom',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () => _openFormDialog(),
                    tooltip: "Ajouter une ame",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📊 Tableau / Liste
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator()) // ⏳ en cours
                  : filtered.isEmpty
                      ? const Center(child: Text("Aucune donnée trouvée."))
                      : (isMobile
                          ? _buildMobileList(filtered)
                          : _buildDesktopTable(filtered)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ TABLEAU DESKTOP
  Widget _buildDesktopTable(List<Map<String, dynamic>> docs) {
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
                "Liste des âmes",
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
                    width: 100,
                    child: Text("Departement",
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
              source: SoulMembersDataSource(
                docs: docs,
                onView: (data) => _showDetails(data),
                onEdit: (data) {
                  if (data['source'] == 'user') {
                    showDialog(context: context, builder: (_) => const UserFormDialog());
                  } else {
                    showDialog(context: context, builder: (_) => const SoulMembersDialog());
                  }
                },
                onDelete: (id, isUser) => _deleteSoulMember(id, isUser: isUser),
                currentUserRole: _currentUserRole ?? '',
                currentUserUid: _currentUserUid ?? '',
                currentUserRegion: _currentUserRegion,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ LISTE MOBILE
  Widget _buildMobileList(List<Map<String, dynamic>> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index];

        final isAdmin = _currentUserRole == 'admin';
        final isMine = data['createdByUid'] == _currentUserUid;
        final canEditOrDelete = isAdmin || isMine;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identifiant : ${data['mobile'] ?? ''}"),
                Text("Profession : ${data['job'] ?? ''}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: primaryColor),
                  onPressed: () => _showDetails(data),
                ),
                if (canEditOrDelete)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _openFormDialog(),
                  ),
                if (canEditOrDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSoulMember(data['id'] ?? ''),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🔧 DataTableSource
class SoulMembersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> docs;
  final void Function(Map<String, dynamic> data) onView;
  final void Function(Map<String, dynamic> data) onEdit;
  final void Function(String id, bool isUser) onDelete;
  final String currentUserRole;
  final String currentUserUid;
  final String? currentUserRegion;
  final Color primaryColor;

  SoulMembersDataSource({
    required this.docs,
    required this.onView,
    required this.onEdit,
  required this.onDelete,
    required this.currentUserRole,
    required this.currentUserUid,
    required this.currentUserRegion,
    required this.primaryColor,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= docs.length) return null;
    final data = docs[index];
    final source = data['source']; // 'soul' ou 'user'

  final isAdmin = currentUserRole == 'admin';
  final isMine = data['createdByUid'] == currentUserUid;
  final sameRegion = data['region'] == currentUserRegion;
  final bool isAssistant = currentUserRole == 'Assistant générale' || currentUserRole == 'Assistant accueil';
  final canEditOrDelete = isAdmin || isMine || (isAssistant && sameRegion);

    // 🧩 Normalisation des champs
    final mobile = source == 'user'
        ? (data['contacts']?['mobile'] ?? '')
        : (data['mobile'] ?? '');
    final lastName = data['lastName'] ?? '';
    final firstName = data['firstName'] ?? '';
    final region = data['region'] ?? '';
    final createdBy = data['createdBy'] ?? '';

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(SizedBox(
            width: 180,
            child: Text(mobile, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(lastName, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(firstName, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 180,
            child: Text(region, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120,
            child: Text(createdBy, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.info_outline, color: primaryColor),
                onPressed: () => onView(data),
                tooltip: 'Voir',
              ),
              if (canEditOrDelete)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => onEdit(data),
                  tooltip: 'Modifier',
                ),
              if (canEditOrDelete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(data['id'] ?? '', source == 'user'),
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
  int get rowCount => docs.length;
  @override
  int get selectedRowCount => 0;
}
