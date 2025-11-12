import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'fiche_pedago_Widget.dart'; // ← Le nouveau fichier avec le tableau

class FichePedagoPage extends LayoutWidget {
  const FichePedagoPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Fiches Pédagogiques';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530, width: double.maxFinite, child: FichePedagoWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
