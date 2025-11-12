import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'ministry_members_widget.dart'; // ← Le nouveau fichier avec le tableau

class MinistryMembersPage extends LayoutWidget {
  const MinistryMembersPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Base de donées du ministere';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530,
            width: double.maxFinite,
            child: MinistryMembersWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
