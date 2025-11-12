import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../fiches/form_pedago_dialog.dart';

class FichePedagoWidget extends StatefulWidget {
  const FichePedagoWidget({super.key});

  @override
  State<FichePedagoWidget> createState() => _FichePedagoWidgetState();
}

class _FichePedagoWidgetState extends State<FichePedagoWidget> {
  String _searchQuery = '';
  String? _currentUserUid;
  String? _currentUserRole;
  String? _currentUserRegion;

  final Color primaryColor = const Color(0xFF004AAD); // Bleu
  final Color secondaryColor = const Color(0xFFFFC107); // Jaune

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
      _currentUserRegion = data?['region'];
    });
  }

  Future<void> _deleteFiche(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer"),
        content: const Text("Supprimer cette fiche pédagogique ?"),
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

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('fiches_pedago')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fiche supprimée.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserUid == null || _currentUserRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Ligne recherche + bouton +
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom/module/thème...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const PedagoFormDialog(),
                    ),
                    tooltip: "Ajouter une fiche",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Contenu
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fiches_pedago')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final query = _searchQuery.toLowerCase();
                    final idAme =
                        (data['identifiant'] ?? '').toString().toLowerCase();
                    final nom = (data['nom'] ?? '').toString().toLowerCase();
                    final prenom =
                        (data['prenom'] ?? '').toString().toLowerCase();
                    final module =
                        (data['moduleLibelle'] ?? '').toString().toLowerCase();
                    final theme =
                        (data['titreSeance'] ?? '').toString().toLowerCase();
                    final isMine = data['createdBy'] == _currentUserUid;
                    final isAdmin = _currentUserRole == 'admin';

                    return (idAme.contains(query) ||
                    nom.contains(query) ||
                    prenom.contains(query) ||
                    module.contains(query) ||
                    theme.contains(query)) &&
                    (isAdmin || isMine || (data['region'] != null && data['region'] == _currentUserRegion));

                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text("Aucune fiche trouvée."));
                  }

                  return isMobile
                      ? _buildMobileList(docs)
                      : _buildDesktopTable(docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ TABLEAU (desktop)
  Widget _buildDesktopTable(List<QueryDocumentSnapshot> docs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 1300,
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text(
                "Liste des fiches pédagogiques",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              rowsPerPage: 5,
              columnSpacing: 20,
              columns: [
                _col("Identifiant"),
                _col("Nom"),
                _col("Prénom"),
                _col("Module"),
                _col("Thème"),
                _col("Durée"),
                _col("Créé le"),
                _col("Actions"),
              ],
              source: _FicheDataSource(
                docs: docs,
                currentUserUid: _currentUserUid!,
                currentUserRole: _currentUserRole!,
                currentUserRegion: _currentUserRegion,
                primaryColor: primaryColor,
                onDelete: (id) => _deleteFiche(context, id),
                onView: (data) => _showFicheDetails(context, data),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: SizedBox(
        width: 120,
        child: Text(label,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ✅ LISTE (mobile)
  Widget _buildMobileList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final docId = docs[index].id;
        final isMine = data['createdBy'] == _currentUserUid;
        final isAdmin = _currentUserRole == 'admin';
        final canEditOrDelete = isAdmin || isMine;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text("${data['nom'] ?? ''} ${data['prenom'] ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identifiant : ${data['identifiant'] ?? ''}"),
                Text("Module : ${data['moduleLibelle'] ?? ''}"),
                Text("Thème : ${data['titreSeance'] ?? ''}"),
                Text("Durée : ${data['dureeHeure'] ?? '?'} h"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: primaryColor),
                  onPressed: () => _showFicheDetails(context, data),
                ),
                if (canEditOrDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFiche(context, docId),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFicheDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Détails de la fiche"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((e) {
              final label = e.key;
              final value = e.value?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("$label : $value"),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}

class _FicheDataSource extends DataTableSource {
  final List<QueryDocumentSnapshot> docs;
  final String currentUserUid;
  final String currentUserRole;
  final String? currentUserRegion;
  final Color primaryColor;
  final void Function(String) onDelete;
  final void Function(Map<String, dynamic>) onView;

  _FicheDataSource({
    required this.docs,
    required this.currentUserUid,
    required this.currentUserRole,
  required this.currentUserRegion,
    required this.primaryColor,
    required this.onDelete,
    required this.onView,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= docs.length) return null;
    final doc = docs[index];
    final data = doc.data() as Map<String, dynamic>;
    final isMine = data['createdBy'] == currentUserUid;
    final isAdmin = currentUserRole == 'admin';
    final canEditOrDelete = isAdmin || isMine;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(data['identifiant'] ?? '')),
        DataCell(Text(data['nom'] ?? '')),
        DataCell(Text(data['prenom'] ?? '')),
        DataCell(Text(data['moduleLibelle'] ?? '')),
        DataCell(Text(data['titreSeance'] ?? '')),
        DataCell(Text("${data['dureeHeure'] ?? '?'} h")),
        DataCell(Text(
          (data['timestamp'] is Timestamp)
              ? (data['timestamp'] as Timestamp)
                  .toDate()
                  .toString()
                  .split('.')[0]
              : '',
        )),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, color: primaryColor),
              onPressed: () => onView(data),
            ),
            if (canEditOrDelete)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(doc.id),
              ),
          ],
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
