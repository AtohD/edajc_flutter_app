import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'fiche_suivi_ame_Widget.dart'; // ← Le nouveau fichier avec le tableau

class FicheSuiviAmePage extends LayoutWidget {
  const FicheSuiviAmePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Fiches de suivi des ames';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 530, width: double.maxFinite, child: SuiviAmeWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
