import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'details_enseignement_page.dart';

class EnseignEvaluationsWidget extends StatefulWidget {
  const EnseignEvaluationsWidget({super.key});

  @override
  State<EnseignEvaluationsWidget> createState() =>
      _EnseignEvaluationsWidgetState();
}

class _EnseignEvaluationsWidgetState extends State<EnseignEvaluationsWidget> {
  String? _currentUserUid;
  String? _currentUserRegion;
  List<String> _createdUserIds = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    final region = data?['region'] ?? '';

    // On récupère les users créés par cet utilisateur dans sa région
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdByUid', isEqualTo: user.uid)
        .where('region', isEqualTo: region)
        .get();

    final userIds = snapshot.docs.map((e) => e.id).toList();

    // ✅ Un seul setState : pas de double rebuild
    setState(() {
      _currentUserUid = user.uid;
      _currentUserRegion = region;
      _createdUserIds = userIds;
    });
  }

  Stream<List<Map<String, dynamic>>> _loadEvaluations() {
    if (_createdUserIds.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('enseignevaluations')
        .where('uid', whereIn: _createdUserIds)
        .where('region', isEqualTo: _currentUserRegion) // <- filtrage supplémentaire
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    final isUserLoaded = _currentUserUid != null &&
        _createdUserIds.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Évaluations d'enseignement")),
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

                final filtered = evaluations.where((e) {
                  final nom = (e['nom'] ?? '').toString().toLowerCase();
                  final prenoms = (e['prenoms'] ?? '').toString().toLowerCase();
                  final module =
                      (e['numero_module'] ?? '').toString().toLowerCase();

                  return nom.contains(_searchQuery) ||
                      prenoms.contains(_searchQuery) ||
                      module.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text("Aucune évaluation trouvée."));
                }

                return Column(
                  children: [
                    // 🔍 Barre de recherche stylée
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Rechercher par nom, prénom ou module",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLargeScreen = constraints.maxWidth > 600;

                          if (isLargeScreen) {
                            // 🖥️ Vue desktop : tableau paginé
                            return Card(
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: PaginatedDataTable(
                                header: const Text("Liste des évaluations"),
                                columns: const [
                                  DataColumn(label: Text("Nom")),
                                  DataColumn(label: Text("Prénoms")),
                                  DataColumn(label: Text("Date")),
                                  DataColumn(label: Text("Heure")),
                                  DataColumn(label: Text("Module")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                source:
                                    _EvaluationDataSource(filtered, context),
                                rowsPerPage: 5,
                                columnSpacing: 20,
                              ),
                            );
                          } else {
                            // 📱 Vue mobile : cartes
                            return ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final e = filtered[index];
                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      "${e['nom'] ?? ''} ${e['prenoms'] ?? ''}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Module : ${e['numero_module'] ?? ''}"),
                                        Text(
                                            "Date : ${e['date'] ?? ''} à ${e['heure'] ?? ''}"),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DetailsEnseignementPage(
                                              evaluation: e,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text("Détails"),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// 📊 Source de données pour le tableau (desktop)
class _EvaluationDataSource extends DataTableSource {
  final List<Map<String, dynamic>> evaluations;
  final BuildContext context;

  _EvaluationDataSource(this.evaluations, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= evaluations.length) return null;
    final e = evaluations[index];
    return DataRow(cells: [
      DataCell(Text(e['nom'] ?? '')),
      DataCell(Text(e['prenoms'] ?? '')),
      DataCell(Text(e['date'] ?? '')),
      DataCell(Text(e['heure'] ?? '')),
      DataCell(Text(e['numero_module'] ?? '')),
      DataCell(
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsEnseignementPage(
                  evaluation: e,
                ),
              ),
            );
          },
          child: const Text("Voir détails"),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => evaluations.length;
  @override
  int get selectedRowCount => 0;
}
