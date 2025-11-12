import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedagoFormDialog extends StatefulWidget {
  final DocumentSnapshot? document;

  const PedagoFormDialog({super.key, this.document});

  @override
  State<PedagoFormDialog> createState() => _PedagoFormDialogState();
}

class _PedagoFormDialogState extends State<PedagoFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs des champs
  final TextEditingController identifiantController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController programmeController = TextEditingController();
  final TextEditingController moduleNumController = TextEditingController();
  final TextEditingController moduleLibelleController = TextEditingController();
  final TextEditingController titreSeanceController = TextEditingController();
  final TextEditingController objectifController = TextEditingController();
  final TextEditingController dureeHeureController = TextEditingController();
  final TextEditingController materielController = TextEditingController();
  final TextEditingController deroulementController = TextEditingController();
  final TextEditingController phaseEnseignementController =
      TextEditingController();
  final TextEditingController phaseEchangeController = TextEditingController();
  final TextEditingController conclusionController = TextEditingController();
  final TextEditingController evaluationController = TextEditingController();

  @override
  void dispose() {
    identifiantController.dispose();
    nomController.dispose();
    prenomController.dispose();
    programmeController.dispose();
    moduleNumController.dispose();
    moduleLibelleController.dispose();
    titreSeanceController.dispose();
    objectifController.dispose();
    dureeHeureController.dispose();
    materielController.dispose();
    deroulementController.dispose();
    phaseEnseignementController.dispose();
    phaseEchangeController.dispose();
    conclusionController.dispose();
    evaluationController.dispose();
    super.dispose();
  }

  void _submit({required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final ficheData = {
      'identifiant': identifiantController.text,
      'nom': nomController.text,
      'prenom': prenomController.text,
      'programme': programmeController.text,
      'moduleNumero': moduleNumController.text,
      'moduleLibelle': moduleLibelleController.text,
      'titreSeance': titreSeanceController.text,
      'objectif': objectifController.text,
      'duree': dureeHeureController.text,
      'materiel': materielController.text,
      'deroulement': deroulementController.text,
      'phaseEnseignement': phaseEnseignementController.text,
      'phaseEchange': phaseEchangeController.text,
      'conclusion': conclusionController.text,
      'evaluation': evaluationController.text,
      'createdBy': user.email ?? '',
      'createdByUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'isDraft': isDraft,
    };

    final col = FirebaseFirestore.instance.collection('fiches_pedago');

    if (widget.document == null) {
      // Nouvelle fiche → on ajoute les infos de créateur
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userRegion = userDoc.data()?['region'] ?? '';

      ficheData.addAll({
        "uid": user.uid,
        "createdByUid": user.uid,
        "createdBy": user.email ?? '',
        "region": userRegion,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await col.add(ficheData);
    } else {
      // Modification → ne change pas createdByUid ni region
      await col.doc(widget.document!.id).update(ficheData);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDraft ? 'Brouillon sauvegardé.' : 'Fiche soumise.'),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Champ requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fiche Pédagogique'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(identifiantController, 'Identifiant'),
              _buildTextField(nomController, 'Nom'),
              _buildTextField(prenomController, 'Prenom'),
              _buildTextField(programmeController, 'Programme'),
              _buildTextField(moduleNumController, 'Numéro du Module'),
              _buildTextField(moduleLibelleController, 'Libellé du Module'),
              _buildTextField(titreSeanceController, 'Titre de la séance'),
              _buildTextField(objectifController, 'Objectif pédagogique'),
              _buildTextField(dureeHeureController, 'Durée (heure)'),
              _buildTextField(materielController, 'Matériel nécessaire'),
              _buildTextField(deroulementController, 'Déroulement de la séance',
                  maxLines: 3),
              _buildTextField(
                  phaseEnseignementController, 'Phase d\'enseignement',
                  maxLines: 2),
              _buildTextField(
                  phaseEchangeController, 'Phase d\'échange et de réflexion',
                  maxLines: 2),
              _buildTextField(conclusionController, 'Conclusion', maxLines: 2),
              _buildTextField(evaluationController, 'Évaluation', maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        OutlinedButton(
          onPressed: () => _submit(isDraft: true),
          child: const Text('Sauvegarder le brouillon'),
        ),
        ElevatedButton(
          onPressed: () => _submit(isDraft: false),
          child: const Text('Soumettre'),
        ),
      ],
    );
  }
}
