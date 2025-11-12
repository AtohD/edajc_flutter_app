import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  // Couleurs cohérentes avec UserManagementWidget
  final Color primaryColor = const Color(0xFF004AAD); // Bleu
  final Color secondaryColor =
      const Color(0xFFFFC107); // Jaune (non utilisé ici)

  String? _currentUserUid;
  String? _currentUserRole;
  String? _currentUserRegion;
  List<String> _createdUserIds = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ✅ LOGIQUE ORIGINALE CONSERVÉE
  int getNoteMax(String theme) {
    final themeLower = theme.toLowerCase();

    if (['le baptème qui sauve', 'la foi', 'l\'adoration']
        .contains(themeLower)) {
      return 6;
    }
    if (['la prière 1', 'la prière 2'].contains(themeLower)) {
      return 4;
    }
    if (['jesus créateur de l\'univers', 'la sanctification', 'le saint-esprit']
        .contains(themeLower)) {
      return 5;
    }
    return 5; // défaut
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  // ✅ LOGIQUE ORIGINALE CONSERVÉE
  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Charger le document Firestore du user connecté
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return; // pas de document, on sort

    final data = doc.data()!; // récupère les infos du user

    // Charger tous les utilisateurs créés par cet utilisateur OU lui-même
    final snapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .where('createdByUid', isEqualTo: user.uid)
        .get();

    final snapshot2 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    final allDocs = [...snapshot1.docs, ...snapshot2.docs];
    final userIds = allDocs.map((doc) => doc.id).toList();

    // ✅ Tout mettre dans un seul setState pour éviter le double rebuild
    setState(() {
      _currentUserUid = user.uid;
      _currentUserRole = data['role'] ?? 'invité';
      _currentUserRegion = data['region'];
      _createdUserIds = userIds;
    });
  }


  // ✅ LOGIQUE ORIGINALE CONSERVÉE
  Query _evaluationsQuery() {
    final col = FirebaseFirestore.instance.collection('evaluations');

    // Admin can read everything
    if (_currentUserRole == 'admin') return col;

    // Assistant can read by region
    if (_currentUserRole == 'assistant' && _currentUserRegion != null) {
      return col.where('region', isEqualTo: _currentUserRegion);
    }

    // Default: try to read evaluations for created users or self.
    // Use `whereIn` when there are <= 10 ids (Firestore limit). Otherwise
    // fall back to reading only the current user's evaluations to avoid
    // requesting the whole collection (which Firestore rules may forbid).
    final ids = List<String>.from(_createdUserIds);
    if (ids.isNotEmpty && ids.length <= 10) {
      return col.where('uid', whereIn: ids);
    }

    // Fallback to current user only
    return col.where('uid', isEqualTo: _currentUserUid);
  }

  Stream<List<Map<String, dynamic>>> _loadEvaluations() {
    if (_currentUserUid == null) return const Stream.empty();

    final query = _evaluationsQuery();
    final stream = query.snapshots();

    return stream.map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isUserLoaded = _currentUserUid != null &&
        _currentUserRole != null &&
        _createdUserIds.isNotEmpty;

    return Scaffold(
      // On garde l'AppBar (ta page l'avait déjà)
      appBar: AppBar(title: const Text("Évaluations des Apprenants")),
      backgroundColor: Colors.grey[100],
      body: !isUserLoaded
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _loadEvaluations(),
              builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur : ${snapshot.error}"));
                    }

                    final evaluations = snapshot.data ?? [];
                    if (evaluations.isEmpty) {
                      return const Center(
                          child: Text("Aucune évaluation trouvée."));
                    }

                    // 🔎 Filtrage identique à ton code
                    final filtered = evaluations.where((e) {
                      final idame = (e['idame'] ?? '').toString().toLowerCase();
                      final nom = (e['nom'] ?? '').toString().toLowerCase();
                      final prenoms =
                          (e['prenoms'] ?? '').toString().toLowerCase();
                      final module =
                          (e['module'] ?? '').toString().toLowerCase();
                      final theme = (e['theme'] ?? '').toString().toLowerCase();

                      return idame.contains(_searchQuery) ||
                          nom.contains(_searchQuery) ||
                          prenoms.contains(_searchQuery) ||
                          module.contains(_searchQuery) ||
                          theme.contains(_searchQuery);
                    }).toList();

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Barre de recherche stylée (même style que UserManagementWidget)
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Rechercher par id, nom, prénoms, module ou thème...',
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
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () =>
                                          _searchController.clear(),
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🖥️ Desktop (PaginatedDataTable) / 📱 Mobile (List)
                          Expanded(
                            child: isMobile
                                ? _buildMobileList(filtered)
                                : _buildDesktopTable(filtered),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // ✅ TABLEAU POUR GRAND ÉCRAN — même esprit que UserManagementWidget
  Widget _buildDesktopTable(List<Map<String, dynamic>> evaluations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 1300, // largeur fixe pour un rendu stable
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text(
                "Liste des évaluations",
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
                    width: 110,
                    child: Text("Date",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 90,
                    child: Text("Heure",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 140,
                    child: Text("Module",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 180,
                    child: Text("Thème",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text("Note",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              source: _EvaluationsDataSource(
                evaluations: evaluations,
                primaryColor: primaryColor,
                getNoteMax: getNoteMax,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ LISTE POUR MOBILE — même rendu que tes autres pages
  Widget _buildMobileList(List<Map<String, dynamic>> evaluations) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: evaluations.length,
      itemBuilder: (context, index) {
        final e = evaluations[index];
        final note = (e['note'] ?? 0) as num;
        final theme = (e['theme'] ?? '').toString();
        final noteMax = getNoteMax(theme);
        final color = note >= noteMax * 0.6 ? Colors.green : Colors.orange;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              "${e['nom'] ?? ''} ${e['prenoms'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID : ${e['idame'] ?? ''}"),
                Text("Module : ${e['module'] ?? ''}"),
                Text("Thème : ${e['theme'] ?? ''}"),
                Text("Date : ${e['date'] ?? ''}  à ${e['heure'] ?? ''}"),
              ],
            ),
            trailing: Text(
              "${note.toString()}/$noteMax",
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        );
      },
    );
  }
}

// 📊 DataSource pour le tableau Desktop (sans actions)
class _EvaluationsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> evaluations;
  final Color primaryColor;
  final int Function(String) getNoteMax;

  _EvaluationsDataSource({
    required this.evaluations,
    required this.primaryColor,
    required this.getNoteMax,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= evaluations.length) return null;
    final e = evaluations[index];

    final idame = (e['idame'] ?? '').toString();
    final nom = (e['nom'] ?? '').toString();
    final prenoms = (e['prenoms'] ?? '').toString();
    final date = (e['date'] ?? '').toString();
    final heure = (e['heure'] ?? '').toString();
    final module = (e['module'] ?? '').toString();
    final theme = (e['theme'] ?? '').toString();

    final note = (e['note'] ?? 0) as num;
    final noteMax = getNoteMax(theme);
    final color = note >= noteMax * 0.6 ? Colors.green : Colors.orange;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(SizedBox(
            width: 120, child: Text(idame, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120, child: Text(nom, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 120, child: Text(prenoms, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 110, child: Text(date, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 90, child: Text(heure, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 140, child: Text(module, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
            width: 180, child: Text(theme, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
          width: 100,
          child: Text(
            "${note.toString()}/$noteMax",
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => evaluations.length;
  @override
  int get selectedRowCount => 0;
}
