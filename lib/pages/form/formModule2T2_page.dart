import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EvaluationFormPage5 extends StatefulWidget {
  final String module;
  final String theme;
  final DocumentSnapshot? document;

  const EvaluationFormPage5({
    required this.module,
    required this.theme,
    this.document,
    super.key,
  });

  @override
  State<EvaluationFormPage5> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage5> {
  final _formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final heureController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final idController = TextEditingController();
  final nomenseignantController = TextEditingController();

  String? selectedVille;
  String? q1, q2, q3, q4, q5;
  final Map<String, String> bonnesReponses = {
    'q1': 'Un état, une disposition spirituelle',
    'q2': 'Le PERE',
    'q3': 'Par le sang de JESUS',
    'q3s': 'Par ordonnance',
    'q3t': 'Le sang des animaux dans l\'Ancien Testament',
    'q4': 'Elle se fait par le Sang de JESUS',
    'q4s':
        'C\'est le fait de respecter les recommandations que DIEU nous donne',
    'q5': 'Charnel',
    'q5s': 'Spirituel',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      heureController.text = TimeOfDay.fromDateTime(DateTime.now()).format(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("Évaluation de l'apprenant(e)")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(24),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "ÉVALUATION DE L’APPRENANT(E)",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.blue,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          "(THÈME : LA SANCTIFICATION)",
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return Row(
                              children: [
                                Expanded(
                                  child: buildDateField(dateController, "Date"),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child:
                                      buildTimeField(heureController, "Heure"),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                buildDateField(dateController, "Date"),
                                const SizedBox(height: 10),
                                buildTimeField(heureController, "Heure"),
                              ],
                            );
                          }
                        },
                      ),

                      buildField(nomController, "Nom de l’apprenant(e)"),
                      buildField(prenomController, "Prénoms de l’apprenant(e)"),
                      buildField(idController, "Identifiant de l’apprenant(e)"),
                      buildField(
                          nomenseignantController, "Nom de l’enseignant(e)"),
                      const SizedBox(height: 10),
                      const Divider(),

                      // QUESTIONS RADIO

                      buildRadioQuestion(
                        "La sanctification est :",
                        [
                          'Ne pas se souiller avec une femme',
                          'Un état, une disposition spirituelle',
                          'C\'est se laver dans une eau',
                          'C\'est d\'être béni',
                          'Je ne sais pas',
                        ],
                        q1,
                        (val) => setState(() => q1 = val),
                      ),
                      buildRadioQuestion(
                        "Qui est le détenteur de la sainteté ?",
                        [
                          'Le pape',
                          'Le pasteur',
                          'JESUS',
                          'Le PERE',
                          'Je ne sais pas',
                        ],
                        q2,
                        (val) => setState(() => q2 = val),
                      ),
                      buildRadioQuestion(
                        "LES DIFFÉRENTES TYPES DE SANCTIFICATION",
                        [
                          'C\'est prendre des ablutions',
                          'Par le sang de JESUS',
                          'Par ordonnance',
                          'Le sang des animaux dans l\'Ancien Testament',
                          'Je ne sais pas',
                        ],
                        q3,
                        (val) => setState(() => q3 = val),
                      ),
                      buildRadioQuestion(
                        "Quelles sont les caractéristiques de la sanctification par ordonnance",
                        [
                          'Elle se fait par le Sang de JESUS',
                          'Elle se fait de progrès en progrès',
                          'C\'est le fait de respecter les recommandations que DIEU nous donne',
                          'C\'est une éducation scolaire',
                          'Je ne sais pas',
                        ],
                        q4,
                        (val) => setState(() => q4 = val),
                      ),
                      buildRadioQuestion(
                        "Quels sont les différents types de péchés ?",
                        [
                          'Charnel',
                          'Spirituel',
                          'Par ordonnance',
                          'L\'amour de l\'argent',
                          'Je ne sais pas',
                        ],
                        q5,
                        (val) => setState(() => q5 = val),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final Map<String, dynamic> data = {
                                'date': dateController.text,
                                'heure': heureController.text,
                                'nom': nomController.text,
                                'prenoms': prenomController.text,
                                'idame': idController.text,
                                'nomenseignant': nomenseignantController.text,
                                'q1': q1,
                                'q2': q2,
                                'q3': q3,
                                'q4': q4,
                                'q5': q5,
                              };

                              int note = 0;
                              if (q1 == bonnesReponses['q1']) note++;
                              if (q2 == bonnesReponses['q2']) note++;
                              if (q3 == bonnesReponses['q3'] ||
                                  q3 == bonnesReponses['q3s'] ||
                                  q3 == bonnesReponses['q3t']) {
                                note++;
                              }
                              if (q4 == bonnesReponses['q4'] ||
                                  q4 == bonnesReponses['q4s']) {
                                note++;
                              }
                              if (q5 == bonnesReponses['q5'] ||
                                  q5 == bonnesReponses['q5s']) {
                                note++;
                              }

                              data['note'] = note;

                              // 🔐 Ajout de l’UID Firebase
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                data['uid'] = user.uid;
                              }

                              data['module'] = widget.module;
                              data['theme'] = widget.theme;

                              // 🔥 Enregistrement dans Firestore
                              final ref =
                                FirebaseFirestore.instance.collection('evaluations');

                              if (widget.document == null) {
                                // Nouvelle fiche → on ajoute les infos de créateur
                                if (user != null) {
                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get();
                                  final userRegion =
                                      userDoc.data()?['region'] ?? '';

                                  data.addAll({
                                    "uid": user.uid,
                                    "createdByUid": user.uid,
                                    "createdBy": user.email ?? '',
                                    "region": userRegion,
                                    "createdAt": FieldValue.serverTimestamp(),
                                  });
                                }

                                await ref.add(data);
                              } else {
                                // Modification → ne change pas createdByUid ni region
                                await ref.doc(widget.document!.id).update(data);
                              }

                              // ✅ Affichage stylisé du résultat
                              String message;
                              Color color;
                              String title;

                              if (note >= 3) {
                                title = "🎉 Félicitations !";
                                message =
                                    "Bravo, vous avez obtenu $note / 5.\nContinuez comme ça !";
                                color = Colors.green;
                              } else {
                                title = "📘 Résultat";
                                message =
                                    "Vous avez obtenu $note / 5.\nNe vous découragez pas, continuez à apprendre !";
                                color = Colors.orange;
                              }

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                  title: Row(
                                    children: [
                                      Icon(Icons.school, color: color),
                                      const SizedBox(width: 8),
                                      Text(title,
                                          style: TextStyle(color: color)),
                                    ],
                                  ),
                                  content: Text(
                                    message,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: color,
                                      ),
                                      child: const Text("Fermer"),
                                    )
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // ✅ couleur du bouton
                            foregroundColor: Colors.white, // ✅ couleur du texte
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Soumettre",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(TextEditingController controller, String label,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Champ requis' : null,
      ),
    );
  }

  Widget buildRadioQuestion(
    String question,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...options.map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: value,
                onChanged: onChanged,
                activeColor: Colors.blue,
              )),
        ],
      ),
    );
  }

  Widget buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Champ requis' : null,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  Widget buildTimeField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          suffixIcon: const Icon(Icons.access_time, color: Colors.grey),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Champ requis' : null,
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controller.text = picked.format(context);
          }
        },
      ),
    );
  }
}
