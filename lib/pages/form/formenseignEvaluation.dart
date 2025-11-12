import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormEnseignement extends StatefulWidget {
  final DocumentSnapshot? document;

  const FormEnseignement({
    this.document,
    super.key,
  });

  @override
  State<FormEnseignement> createState() => _FormEnseignementState();
}

class _FormEnseignementState extends State<FormEnseignement> {
  final _formKey = GlobalKey<FormState>();

  // Champs textes
  final dateController = TextEditingController();
  final heureController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final idController = TextEditingController();
  final nomenseignantController = TextEditingController();
  final numeromodController = TextEditingController();
  final libmodController = TextEditingController();
  final enseignController = TextEditingController();
  final strongpointenseignController = TextEditingController();
  final weakpointenseignController = TextEditingController();
  final improveideaController = TextEditingController();

  // Stockage des réponses des questions radio
  final Map<String, String?> reponses = {};

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

  // Liste des questions avec leurs clés
  final List<Map<String, dynamic>> questions = [
    {
      "key": "q1",
      "text":
          "1. Le contenu du cours est satisfaisant pour mon évolution spirituelle"
    },
    {
      "key": "q2",
      "text":
          "2. J'ai compris les objectifs et l'importance de cet enseignement."
    },
    {"key": "q3", "text": "3. J'ai compris le programme de cet enseignement"},
    {
      "key": "q4",
      "text":
          "4. Je sais ce que je dois apprendre et sur quoi je serais jugé à l'évaluation."
    },
    {
      "key": "q5",
      "text":
          "5. Les ressources nécessaires me semblent appropriées et disponibles."
    },
    {
      "key": "q6",
      "text":
          "6. Le cours est bien équilibré entre éléments de théorie et exemples bibliques."
    },
    {
      "key": "q7",
      "text":
          "7. Le volume horaire reflète l'importance de l'enseignement dispensé"
    },
    {
      "key": "q8",
      "text":
          "8. L'enseignant présente l'enseignement de façon claire et structurée."
    },
    {"key": "q9", "text": "9. Les supports de cours me sont utiles."},
    {
      "key": "q10",
      "text": "10. L'enseignant s'assure que les notions sont bien assimilées."
    },
    {"key": "q11", "text": "11. L'enseignant utilise un vocabulaire adapté."},
    {
      "key": "q12",
      "text": "12. L'enseignant identifie les besoins des apprenants."
    },
    {"key": "q13", "text": "13. L'enseignant(e) est sympathique."},
    {"key": "q14", "text": "14. L'enseignant(e) est compréhensif(ve)."},
    {"key": "q15", "text": "15. L'enseignant(e) est patient(e)."},
    {"key": "q16", "text": "16. L'enseignant(e) est tolérant(e)."},
    {"key": "q17", "text": "17. L'enseignant(e) est courtois(e)."},
    {
      "key": "q18",
      "text": "18. L'enseignant(e) donne le goût et le plaisir d'apprendre."
    },
    {"key": "q19", "text": "19. L'enseignant cherche à améliorer son cours."},
    {
      "key": "q20",
      "text":
          "20. Mon degré global de satisfaction vis-à-vis de cet enseignement."
    },
  ];

  final List<String> options = [
    "pas d'accord",
    "plutôt pas d'accord",
    "plutôt d'accord",
    "d'accord",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("Évaluation de l'enseignement")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(24),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          "EVALUATION DE L'ENSEIGNEMENT",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.blue,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Champs classiques
                      buildDateField(dateController, "Date"),
                      buildTimeField(heureController, "Heure"),
                      buildField(nomController, "Nom de l’apprenant(e)"),
                      buildField(prenomController, "Prénoms de l’apprenant(e)"),
                      buildField(idController, "Identifiant de l’apprenant(e)"),
                      buildField(
                          nomenseignantController, "Nom de l’enseignant(e)"),
                      buildField(numeromodController, "Numéro du Module"),
                      buildField(libmodController, "Libellé du Module"),
                      buildField(enseignController, "Enseignement"),

                      const SizedBox(height: 10),
                      const Divider(),

                      // 🔹 Génération dynamique des questions
                      ...questions
                          .map((q) => buildRadioQuestion(q["text"], q["key"])),

                      const SizedBox(height: 20),
                      const Divider(),
                      buildField(strongpointenseignController,
                          "Points forts de cet enseignement"),
                      buildField(weakpointenseignController,
                          "Points faibles de cet enseignement"),
                      buildField(
                          improveideaController, "Vos idées d'amélioration"),

                      const SizedBox(height: 10),

                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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

  // ✅ Champs texte sans obligation
  Widget buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
      ),
    );
  }

  // ✅ Sélection Date
  Widget buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = "${picked.year}-${picked.month}-${picked.day}";
        }
      },
    );
  }

  // ✅ Sélection Heure
  Widget buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
      onTap: () async {
        final picked = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (picked != null) controller.text = picked.format(context);
      },
    );
  }

  // ✅ Question avec Radio autonome
  Widget buildRadioQuestion(String question, String key) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ...options.map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: reponses[key],
                    onChanged: (val) {
                      setState(() => reponses[key] = val);
                    },
                    activeColor: Colors.blue,
                  )),
            ],
          ),
        );
      },
    );
  }

  // ✅ Soumission vers Firestore
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    bool allAnswered = questions.every((q) => reponses[q["key"]] != null);
    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez répondre à toutes les questions")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      "date": dateController.text,
      "heure": heureController.text,
      "nom": nomController.text,
      "prenoms": prenomController.text,
      "id_apprenant": idController.text,
      "nom_enseignant": nomenseignantController.text,
      "numero_module": numeromodController.text,
      "libelle_module": libmodController.text,
      "enseignement": enseignController.text,
      "point fort enseignement": strongpointenseignController.text,
      "point faible enseignement": weakpointenseignController.text,
      "idee amelioration": improveideaController.text,
      "reponses": reponses,
      "createdAt": FieldValue.serverTimestamp(),
    };

    final ref = FirebaseFirestore.instance.collection('enseignevaluations');

    if (widget.document == null) {
      // Nouvelle fiche → on ajoute les infos de créateur
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userRegion = userDoc.data()?['region'] ?? '';

      data.addAll({
        "createdByUid": user.uid,
        "createdBy": user.email ?? '',
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
}
