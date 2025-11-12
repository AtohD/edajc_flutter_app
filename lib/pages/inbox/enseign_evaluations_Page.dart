import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'enseign_evaluations_Widget.dart'; // ← Le nouveau fichier avec le tableau

class EnseignEvaluationsPage extends LayoutWidget {
  const EnseignEvaluationsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Liste des evaluations';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530,
            width: double.maxFinite,
            child: EnseignEvaluationsWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
