import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'soul_members_widget.dart'; // ← Le nouveau fichier avec le tableau

class SoulMembersPage extends LayoutWidget {
  const SoulMembersPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Gestion des nouvelles âmes';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530, width: double.maxFinite, child: SoulMembersWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
