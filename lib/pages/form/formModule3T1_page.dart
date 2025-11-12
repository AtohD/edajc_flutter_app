import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EvaluationFormPage6 extends StatefulWidget {
  final String module;
  final String theme;
  final DocumentSnapshot? document;

  const EvaluationFormPage6({
    required this.module,
    required this.theme,
    this.document,
    super.key,
  });

  @override
  State<EvaluationFormPage6> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage6> {
  final _formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final heureController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final idController = TextEditingController();
  final nomenseignantController = TextEditingController();

  String? selectedVille;
  String? q1, q2, q3, q4, q5, q6;
  final Map<String, String> bonnesReponses = {
    'q1': 'Sur la Parole de CHRIST et les conseils de DIEU',
    'q2': 'Attendre la réponse de DIEU venant du Père spirituel',
    'q3': 'La foi qui est basée sur la convoitise et non sur la parole de DIEU',
    'q4': 'Tenir ferme et braver les épreuves',
    'q5': 'En persévérant en la Parole de DIEU, en bannissant le doute',
    'q5s': 'En priant avec la Parole que DIEU nous a donnée',
    'q6':
        'La foi est une ferme assurance des choses qu\'on espère et ce qu\'on espère doit venir de la Parole de DIEU',
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
                          "(THÈME : LA FOI)",
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
                        "Sur quoi ou sur qui doit être basée notre foi ?",
                        [
                          'Nos pensées',
                          'Sur tout ce qu\'on entend des parents',
                          'Sur la Parole de CHRIST et les conseils de DIEU',
                          'Sur les conseils des parents et des frères en Christ',
                          'Je ne sais pas',
                        ],
                        q1,
                        (val) => setState(() => q1 = val),
                      ),
                      buildRadioQuestion(
                        " Que faire quand DIEU, par le Père spirituel nous fait une promesse de mariage ?",
                        [
                          'S\'attacher à celle pour qui son cœur bat',
                          'Se mettre à chercher celle qu\'on aime',
                          'Se focaliser sur nos rêves',
                          'Attendre la réponse de DIEU venant du Père spirituel',
                          'Je ne sais pas',
                        ],
                        q2,
                        (val) => setState(() => q2 = val),
                      ),
                      buildRadioQuestion(
                        "Quel est la foi diabolique ?",
                        [
                          'C\'est croire en satan',
                          'La foi qui est basée sur la convoitise et non sur la parole de DIEU',
                          'C\'est croire aux statues',
                          'C\'est croire en un homme',
                          'Je ne sais pas',
                        ],
                        q3,
                        (val) => setState(() => q3 = val),
                      ),
                      buildRadioQuestion(
                        "Que faire lors des épreuves ?",
                        [
                          'Abandonner la main de DIEU',
                          'Aller chez les féticheurs',
                          'Fuir les épreuves et se fâcher contre DIEU',
                          'Tenir ferme et braver les épreuves',
                          'Je ne sais pas',
                        ],
                        q4,
                        (val) => setState(() => q4 = val),
                      ),
                      buildRadioQuestion(
                        "Comment entretenir la foi ?",
                        [
                          'En murmurant, en se plaignant',
                          'En nous basant sur les documents scolaires',
                          'En persévérant en la Parole de DIEU, en bannissant le doute',
                          'En écoutant les conseils des parents',
                          'En priant avec la Parole que DIEU nous a donnée',
                          'Je ne sais pas',
                        ],
                        q5,
                        (val) => setState(() => q5 = val),
                      ),
                      buildRadioQuestion(
                        "Quelle est la véritable foi ?",
                        [
                          'Croire en quelque chose',
                          'La foi est une ferme assurance des choses qu\'on espère et ce qu\'on espère doit venir de la Parole de DIEU',
                          'Croire en ses propres convictions',
                          'Croire en ce que nous voyons',
                          'Je ne sais pas',
                        ],
                        q6,
                        (val) => setState(() => q6 = val),
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
                                'ville': selectedVille,
                                'q1': q1,
                                'q2': q2,
                                'q3': q3,
                                'q4': q4,
                                'q5': q5,
                                'q6': q6,
                              };

                              int note = 0;
                              if (q1 == bonnesReponses['q1']) note++;
                              if (q2 == bonnesReponses['q2']) note++;
                              if (q3 == bonnesReponses['q3']) note++;
                              if (q4 == bonnesReponses['q4']) note++;
                              if (q5 == bonnesReponses['q5'] ||
                                  q5 == bonnesReponses['q5s']) {
                                note++;
                              }
                              if (q6 == bonnesReponses['q6']) note++;

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
                                    "Bravo, vous avez obtenu $note / 6.\nContinuez comme ça !";
                                color = Colors.green;
                              } else {
                                title = "📘 Résultat";
                                message =
                                    "Vous avez obtenu $note / 6.\nNe vous découragez pas, continuez à apprendre !";
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
