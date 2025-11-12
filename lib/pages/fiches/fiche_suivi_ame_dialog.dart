import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuiviAmeFormDialog extends StatefulWidget {
  final DocumentSnapshot? document;

  const SuiviAmeFormDialog({super.key, this.document});

  @override
  State<SuiviAmeFormDialog> createState() => _SuiviAmeFormDialogState();
}

class _SuiviAmeFormDialogState extends State<SuiviAmeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final nomAmeController = TextEditingController();
  final prenomsAmeController = TextEditingController();
  final identifiantAmeController = TextEditingController();
  final telephoneAmeController = TextEditingController();
  final fonctionAmeController = TextEditingController();
  final metierAmeController = TextEditingController();
  final connaissanceAmeController = TextEditingController();
  final niveauEtudesController = TextEditingController();
  final motifsVisiteController = TextEditingController();

  bool estIlletre = false;
  bool premiereCure = false;
  bool premiereDelivrance = false;

  final Map<String, Map<String, String>> enseignements = {
    "Seance1": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance2": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance3": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance4": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance5": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance6": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance7": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance8": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance9": {"enseignant": "","enseignement": "", "observation": ""},
    "Seance10": {"enseignant": "","enseignement": "", "observation": ""},
  };

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      final data = widget.document!.data() as Map<String, dynamic>;
      nomAmeController.text = data['nomAme'] ?? '';
      prenomsAmeController.text = data['prenomsAme'] ?? '';
      identifiantAmeController.text = data['identifiantAme'] ?? '';
      telephoneAmeController.text = data['telephoneAme'] ?? '';
      fonctionAmeController.text = data['fonctionAme'] ?? '';
      metierAmeController.text = data['metierAme'] ?? '';
      connaissanceAmeController.text = data['connaissanceAme'] ?? '';
      niveauEtudesController.text = data['niveauEtudes'] ?? '';
      motifsVisiteController.text = data['motifsVisite'] ?? '';
      estIlletre = data['estIlletre'] ?? false;
      premiereCure = data['premiereCure'] ?? false;
      premiereDelivrance = data['premiereDelivrance'] ?? false;

      if (data['enseignements'] != null) {
        data['enseignements'].forEach((key, value) {
          if (enseignements.containsKey(key)) {
            enseignements[key]!['enseignant'] = value['enseignant'] ?? '';
            enseignements[key]!['enseignement'] = value['enseignement'] ?? '';
            enseignements[key]!['observation'] = value['observation'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, dynamic> data = {
      "nomAme": nomAmeController.text,
      "prenomsAme": prenomsAmeController.text,
      "identifiantAme": identifiantAmeController.text,
      "telephoneAme": telephoneAmeController.text,
      "fonctionAme": fonctionAmeController.text,
      "metierAme": metierAmeController.text,
      "connaissanceAme": connaissanceAmeController.text,
      "estIlletre": estIlletre,
      "niveauEtudes": niveauEtudesController.text,
      "premiereCure": premiereCure,
      "premiereDelivrance": premiereDelivrance,
      "motifsVisite": motifsVisiteController.text,
      "enseignements": enseignements,
    };

    final ref = FirebaseFirestore.instance.collection('suivi_ames');

    if (widget.document == null) {
      // Nouvelle fiche → on ajoute les infos de créateur
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userRegion = userDoc.data()?['region'] ?? '';

      data.addAll({
        "uid": user.uid,
        "createdByUid": user.uid,
        "createdBy": user.email,
        "region": userRegion,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await ref.add(data);
    } else {
      // Modification → ne change pas createdByUid ni region
      await ref.doc(widget.document!.id).update(data);
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.document == null
          ? "Ajouter une Fiche Âme"
          : "Modifier la Fiche Âme"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey, // ✅ plus de validateurs
          child: Column(
            children: [
              _buildTextField(nomAmeController, "Nom de l'Âme"),
              _buildTextField(prenomsAmeController, "Prénoms de l'Âme"),
              _buildTextField(identifiantAmeController, "Identifiant"),
              _buildTextField(telephoneAmeController, "Téléphone"),
              _buildTextField(fonctionAmeController, "Fonction"),
              _buildTextField(metierAmeController, "Métier"),
              _buildTextField(
                  connaissanceAmeController, "Nom de la Connaissance"),
              Row(
                children: [
                  Checkbox(
                    value: estIlletre,
                    onChanged: (v) => setState(() => estIlletre = v ?? false),
                  ),
                  const Text("Êtes-vous illettré ?"),
                ],
              ),
              if (!estIlletre)
                _buildTextField(niveauEtudesController, "Niveau d'études"),
              Row(
                children: [
                  Checkbox(
                    value: premiereCure,
                    onChanged: (v) => setState(() => premiereCure = v ?? false),
                  ),
                  const Text("1ère Cure d'Âme ?"),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: premiereDelivrance,
                    onChanged: (v) =>
                        setState(() => premiereDelivrance = v ?? false),
                  ),
                  const Text("1ère Délivrance ?"),
                ],
              ),
              _buildTextField(motifsVisiteController, "Motifs de la Visite"),
              const SizedBox(height: 10),
              const Text("Tableau des Enseignements et Observations",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...enseignements.keys.map((seance) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seance,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextFormField(
                      initialValue: enseignements[seance]!['enseignant'],
                      decoration:
                          const InputDecoration(labelText: "Enseignant"),
                      onChanged: (v) =>
                          enseignements[seance]!['enseignant'] = v,
                    ),
                    TextFormField(
                      initialValue: enseignements[seance]!['enseignement'],
                      decoration:
                          const InputDecoration(labelText: "Enseignement"),
                      onChanged: (v) =>
                          enseignements[seance]!['enseignement'] = v,
                    ),
                    TextFormField(
                      initialValue: enseignements[seance]!['observation'],
                      decoration:
                          const InputDecoration(labelText: "Observation"),
                      onChanged: (v) =>
                          enseignements[seance]!['observation'] = v,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler")),
        ElevatedButton(onPressed: _submit, child: const Text("Enregistrer")),
      ],
    );
  }
}
