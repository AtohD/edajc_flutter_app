import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'fiche_suivi_ame_dialog.dart';
import 'package:intl/intl.dart'; 

class SuiviAmeWidget extends StatefulWidget {
  const SuiviAmeWidget({super.key});

  @override
  State<SuiviAmeWidget> createState() => _SuiviAmeWidgetState();
}

class _SuiviAmeWidgetState extends State<SuiviAmeWidget> {
  String _searchQuery = '';
  String? _currentUserRole;
  String? _currentUserUid;
  String? _currentUserRegion;

  // 🎨 Palette identique au modèle de référence
  final Color primaryColor = const Color(0xFF004AAD); // Bleu du logo
  final Color secondaryColor = const Color(0xFFFFC107); // Jaune du logo

  // Role helpers (class-level getters)
  bool get isAdmin => _currentUserRole == 'admin';
  bool get isAssistant =>
    _currentUserRole == 'Assistant générale' ||
    _currentUserRole == 'Directeur regionale'||
    _currentUserRole == 'Assistant accueil';
  bool get isTeacher =>
    _currentUserRole == 'Enseignant de recyclage' ||
    _currentUserRole == 'Enseignant titulaire';
  bool get canCreate => isAdmin || isAssistant;

  // 🔹 Fonctions centralisées pour les droits
  bool canEditAction(Map<String, dynamic> data) {
    final sameRegion = data['region'] == _currentUserRegion;
    final isMine = data['createdByUid'] == _currentUserUid;
    return isAdmin || isMine || ((isAssistant || isTeacher) && sameRegion);
  }

  bool canDeleteAction(Map<String, dynamic> data) {
    final sameRegion = data['region'] == _currentUserRegion;
    final isMine = data['createdByUid'] == _currentUserUid;
    return isAdmin || isMine || (isAssistant && sameRegion);
  }


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

  Future<void> _deleteFiche(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Supprimer cette fiche de suivi ?"),
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
          .collection('suivi_ames')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fiche supprimée.")),
        );
      }
    }
  }

  void _openFormDialog({DocumentSnapshot? doc}) {
    showDialog(
      context: context,
      builder: (_) => SuiviAmeFormDialog(document: doc),
    );
  }

  void _showDetails(Map<String, dynamic> data) {
    final displayData = Map<String, dynamic>.from(data);

    // 🔹 Détection du téléphone et identifiant
    final mobileVal = displayData['telephoneAme']?.toString() ?? '';
    displayData['telephoneAme'] = mobileVal.isNotEmpty ? mobileVal : 'N/A';
    displayData['identifiantAme'] = displayData['identifiantAme'] ?? mobileVal;

    // 🔹 Ordre d’affichage
    final orderedKeys = [
      'identifiantAme',
      'nomAme',
      'prenomsAme',
      'telephoneAme',
      'fonctionAme',
      'metierAme',
      'region',
      'niveauEtudes',
      'connaissanceAme',
      'estIllLettre',
      'premiereCure',
      'premiereDelivrance',
      'motifsVisite',
      'testimony',
      'createdBy',
      'createdByUid',
      'createdAt',
      'enseignements',
    ];

    final List<Widget> fields = [];

    for (var key in orderedKeys) {
      if (!displayData.containsKey(key)) continue;
      var value = displayData[key];

      // 🔹 Formatage des dates Firestore
      if (value is Timestamp) {
        value = DateFormat('dd/MM/yyyy à HH:mm').format(value.toDate());
      }

      // 🔹 Formatage des booléens
      if (value is bool) {
        value = value ? 'Oui' : 'Non';
      }

      // 🔹 Formatage des listes
      if (value is List) {
        value = value.join(', ');
      }

      // 🔹 Formatage des enseignements (Map complexe)
      if (key == 'enseignements' && value is Map) {
        value = value.entries.map((e) {
          final s = e.key;
          final v = e.value;
          if (v is Map) {
            return "$s → Enseignant: ${v['enseignant'] ?? '-'}, "
                "Enseignement: ${v['enseignement'] ?? '-'}, "
                "Observation: ${v['observation'] ?? '-'}";
          }
          return "$s : $v";
        }).join('\n');
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
                  "${_formatAmeLabel(key)} :",
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
          "Détails de l'Âme",
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

  /// 🏷️ Labels en français pour les champs
  String _formatAmeLabel(String key) {
    switch (key) {
      case 'identifiantAme':
        return 'Identifiant';
      case 'nomAme':
        return 'Nom';
      case 'prenomsAme':
        return 'Prénoms';
      case 'telephoneAme':
        return 'Téléphone';
      case 'fonctionAme':
        return 'Fonction';
      case 'metierAme':
        return 'Métier';
      case 'region':
        return 'Région';
      case 'niveauEtudes':
        return 'Niveau d\'études';
      case 'connaissanceAme':
        return 'Connaissance';
      case 'estIllLettre':
        return 'Est illettré';
      case 'premiereCure':
        return 'Première cure';
      case 'premiereDelivrance':
        return 'Première délivrance';
      case 'motifsVisite':
        return 'Motifs de visite';
      case 'enseignements':
        return 'Enseignements';
      case 'createdAt':
        return 'Date de création';
      case 'createdBy':
        return 'Créé par (email)';
      case 'createdByUid':
        return 'UID du créateur';
      default:
        return key;
    }
  }


  @override
Widget build(BuildContext context) {
  if (_currentUserRole == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final isMobile = MediaQuery.of(context).size.width < 800;

  return Scaffold(
    appBar: AppBar(title: const Text("Suivi des Âmes")),
    backgroundColor: Colors.grey[100],
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Ligne avec champ recherche + bouton +
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, prénom ou identifiant',
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
                  onPressed: canCreate ? () => _openFormDialog() : null,
                  tooltip: "Ajouter une fiche",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 📊 Tableau / Liste
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suivi_ames')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final query = _searchQuery.toLowerCase();

                  final isMine = data['createdByUid'] == _currentUserUid;
                  final sameRegion = data['region'] == _currentUserRegion;

                  final identifiant =
                      (data['identifiantAme'] ?? '').toString().toLowerCase();
                  final nom = (data['nomAme'] ?? '').toString().toLowerCase();
                  final prenoms =
                      (data['prenomsAme'] ?? '').toString().toLowerCase();

                  final matches = nom.contains(query) ||
                      prenoms.contains(query) ||
                      identifiant.contains(query);

                  // ✅ un utilisateur voit ses fiches + celles de sa région + admin voit tout
                  return matches && (isAdmin || isMine || sameRegion);
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


  // ✅ TABLEAU POUR GRAND ÉCRAN — style identique au modèle
  Widget _buildDesktopTable(List<QueryDocumentSnapshot> docs) {
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
                "Liste des fiches de suivi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
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
                    child: Text("Prénoms",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 140,
                    child: Text("Téléphone",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text("Fonction",
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
              source: SuiviAmeDataSource(
                docs: docs,
                onView: (data) => _showDetails(data),
                onEdit: (doc) => _openFormDialog(doc: doc),
                onDelete: (id) => _deleteFiche(id),
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

  // ✅ LISTE POUR MOBILE — même logique d’actions/permissions que le modèle
  Widget _buildMobileList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;

        final canEdit = canEditAction(data);
        final canDelete = canDeleteAction(data);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              "${data['nomAme'] ?? ''} ${data['prenomsAme'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identifiant : ${data['identifiantAme'] ?? ''}"),
                Text("Téléphone : ${data['telephoneAme'] ?? ''}"),
                Text("Fonction : ${data['fonctionAme'] ?? ''}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: primaryColor),
                  onPressed: () => _showDetails(data),
                ),
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _openFormDialog(doc: doc),
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFiche(doc.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


}

// 🔧 DataTableSource au style du modèle de référence
class SuiviAmeDataSource extends DataTableSource {
  final List<QueryDocumentSnapshot> docs;
  final void Function(Map<String, dynamic> data) onView;
  final void Function(DocumentSnapshot doc) onEdit;
  final void Function(String id) onDelete;
  final String currentUserRole;
  final String currentUserUid;
  final String? currentUserRegion;
  final Color primaryColor;

  SuiviAmeDataSource({
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
    final doc = docs[index];
    final data = doc.data() as Map<String, dynamic>;

    // 🔹 Droits centralisés
    final sameRegion = data['region'] == currentUserRegion;
    final isMine = data['createdByUid'] == currentUserUid;

    final bool isAssistant = currentUserRole == 'Assistant générale' || currentUserRole == 'Assistant accueil';
    final bool isTeacher = currentUserRole == 'Enseignant de recyclage' || currentUserRole == 'Enseignant titulaire';

    final canEdit = currentUserRole == 'admin' || isMine || ((isAssistant || isTeacher) && sameRegion);
    final canDelete = currentUserRole == 'admin' || isMine || (isAssistant && sameRegion);

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(data['identifiantAme'] ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Text(data['nomAme'] ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Text(data['prenomsAme'] ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Text(data['telephoneAme'] ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Text(data['fonctionAme'] ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, color: primaryColor),
              onPressed: () => onView(data),
              tooltip: 'Voir',
            ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(doc),
                tooltip: 'Modifier',
              ),
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(doc.id),
                tooltip: 'Supprimer',
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
