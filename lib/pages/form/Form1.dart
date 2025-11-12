import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EvaluationFormPage extends StatefulWidget {
  const EvaluationFormPage({super.key});

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final heureController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final id1Controller = TextEditingController();
  final id2Controller = TextEditingController();

  String? selectedVille;
  String? q1, q2, q3, q4, q5, q6;
  final Map<String, String> bonnesReponses = {
    'q1': 'La repentance',
    'q2': 'Préparer le chemin du Seigneur',
    'q3': 'Pour donner du crédit au baptême de Jean Baptiste',
    'q4': 'Baptême de JESUS',
    'q5': 'Par la Parole',
    'q5s': 'Par imposition des mains',
    'q6': 'C\'est Le Sang de JESUS',
  };

  final villes = [
    'ABIDJAN',
    'ABENGOUROU',
    'DAOUKRO',
    'BOUAKE',
    'YOPOUGON',
    'AUTRE'
  ];

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
                          "(THÈME : LE BAPTÊME QUI SAUVE)",
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
                      buildField(
                          id1Controller, "Identifiant de l’apprenant(e)"),
                      buildField(
                          id2Controller, "Identifiant de l’enseignant(e)"),
                      const SizedBox(height: 10),
                      const Text("Ville / Commune",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...villes.map((ville) => RadioListTile<String>(
                            title: Text(ville),
                            value: ville,
                            groupValue: selectedVille,
                            onChanged: (val) {
                              setState(() {
                                selectedVille = val;
                              });
                            },
                          )),
                      const Divider(),

                      // QUESTIONS RADIO
                      buildRadioQuestion(
                        "Que signifie le Baptême d'eau de Jean-Baptiste ?",
                        [
                          'Accepter JESUS',
                          'Avoir le SAINT-ESPRIT',
                          'La repentance',
                          'Avoir la bénédiction',
                          'Je ne sais pas',
                        ],
                        q1,
                        (val) => setState(() => q1 = val),
                      ),
                      buildRadioQuestion(
                        "Quel était le rôle de Jean-Baptiste ?",
                        [
                          'Sauver le Monde',
                          'Donner le SAINT-ESPRIT',
                          'Prier pour les juifs',
                          'Préparer le chemin du Seigneur',
                          'Je ne sais pas',
                        ],
                        q2,
                        (val) => setState(() => q2 = val),
                      ),
                      buildRadioQuestion(
                        "Pourquoi JESUS s'est fait baptiser ?",
                        [
                          'Parce qu\'IL a péché',
                          'Pour donner du crédit au baptême de Jean Baptiste',
                          'Pour donner sa vie DIEU',
                          'Pour avoir le SAINT-ESPRIT',
                          'Je ne sais pas',
                        ],
                        q3,
                        (val) => setState(() => q3 = val),
                      ),
                      buildRadioQuestion(
                        "Quel est le vrai Baptême qui accorde le Salut ?",
                        [
                          'Baptême de Moïse',
                          'Baptême des sacrificateurs',
                          'Baptême de Jean-Baptiste',
                          'Baptême de JESUS',
                          'Je ne sais pas',
                        ],
                        q4,
                        (val) => setState(() => q4 = val),
                      ),
                      buildRadioQuestion(
                        "Comment recevoir le véritable Baptême de JESUS ?",
                        [
                          'Par l\'eau',
                          'Par huile',
                          'Par la Parole',
                          'Par le SAINT-ESPRIT',
                          'Par imposition des mains',
                          'Je ne sais pas',
                        ],
                        q5,
                        (val) => setState(() => q5 = val),
                      ),
                      buildRadioQuestion(
                        "Quel est le baptême de JESUS ?",
                        [
                          'C\'est de se faire plonger dans une eau (lagune, rivière, piscine etc.)',
                          'C\'est le baptême par aspersion',
                          'C\'est Le Sang de JESUS',
                          'C\'est donner sa vie à JESUS',
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
                                'id1': id1Controller.text,
                                'id2': id2Controller.text,
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

                              // 🔥 Enregistrement dans Firestore
                              await FirebaseFirestore.instance
                                  .collection('evaluations')
                                  .add(data);

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
