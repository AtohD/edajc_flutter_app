import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'evaluations.dart'; // ← Le nouveau fichier avec le tableau

class EvaluationsWidPage extends LayoutWidget {
  const EvaluationsWidPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Liste des evaluations';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530, width: double.maxFinite, child: EvaluationsPage()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
