import 'package:flutter/material.dart';

class DetailsEnseignementPage extends StatelessWidget {
  final Map<String, dynamic> evaluation;
  const DetailsEnseignementPage({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final reponses = Map<String, dynamic>.from(evaluation["reponses"] ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text("Détails de l'évaluation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info("Nom", evaluation["nom"]),
                info("Prénoms", evaluation["prenoms"]),
                info("Date", evaluation["date"]),
                info("Heure", evaluation["heure"]),
                info("Module", evaluation["numero_module"]),
                info("Enseignement", evaluation["enseignement"]),
                info("Points forts", evaluation["point fort enseignement"]),
                info("Points faibles", evaluation["point faible enseignement"]),
                info("Idées d'amélioration", evaluation["idee amelioration"]),
                const Divider(height: 30),
                const Text(
                  "Réponses aux questions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...reponses.entries.map(
                  (entry) => ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label : ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
