import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'user_management_widget.dart'; // ← Le nouveau fichier avec le tableau

class UserManagementPage extends LayoutWidget {
  const UserManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Gestion de l\'administration';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 530,
            width: double.maxFinite,
            child: UserManagementWidget()),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
