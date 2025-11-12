import 'package:flareline_uikit/components/toolbar/toolbar.dart';
import 'package:flareline_uikit/widget/flareline_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LayoutWidget extends FlarelineLayoutWidget {
  const LayoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      // Attente du chargement des données utilisateur
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return super.build(context);
  }

  @override
  String sideBarAsset(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final role = userProvider.user?.role.toLowerCase().trim() ?? 'user';
    print('MenuBar trouvé : $role');

    switch (role) {
      case 'admin':
        return 'assets/routes/menu_route_admin.json';
      case 'assistant générale':
        return 'assets/routes/menu_route_admin.json';
      case 'directeur regionale':
        return 'assets/routes/menu_route_admin.json';
      case 'assistant accueil':
        return 'assets/routes/menu_route_assistant_accueil.json';
      case 'enseignant titulaire':
        return 'assets/routes/menu_route_enseignant.json';
      case 'enseignant de recyclage':
        return 'assets/routes/menu_route_enseignant.json';
      case 'ame':
        return 'assets/routes/menu_route_ame.json';
      default:
        return 'assets/routes/menu_route_user.json';
    }
  }

  @override
  Widget? toolbarWidget(BuildContext context, bool showDrawer) {
    return ToolBarWidget(
      showMore: showDrawer,
      showChangeTheme: true,
      userInfoWidget: _userInfoWidget(context),
    );
  }

  Widget _userInfoWidget(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.firstName ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(user?.role ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          backgroundImage: AssetImage('assets/user/user-02.png'),
          radius: 22,
        )
      ],
    );
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Center(child: Text("Contenu à définir"));
  }
}
