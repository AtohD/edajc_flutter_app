import 'package:flutter/material.dart';
import 'package:flareline/deferred_widget.dart';

// Import des pages en deferred
import 'package:flareline/pages/splash/splash_screen.dart' deferred as splash;
import 'package:flareline/pages/alerts/alert_page.dart' deferred as alert;
import 'package:flareline/pages/auth/sign_in/sign_in_page.dart'
    deferred as signIn;
import 'package:flareline/pages/auth/sign_up/sign_up_page.dart'
    deferred as signUp;
import 'package:flareline/pages/auth/register_admin_page.dart'
    deferred as registerAdmin;
import 'package:flareline/pages/auth/first_Connexion.dart'
    deferred as firstConnexion;
import 'package:flareline/pages/button/button_page.dart' deferred as button;
import 'package:flareline/pages/user_management_page/user_management_page.dart'
    deferred as usermanagement;
import 'package:flareline/pages/user_management_page/soul_members_page.dart'
    deferred as soulmembers2;
import 'package:flareline/pages/user_management_page/ministry_members_page.dart'
    deferred as ministrymembers;
import 'package:flareline/pages/chart/chart_page.dart' deferred as chart;

import 'package:flareline/pages/form/form_layout_page.dart'
    deferred as formLayout;
import 'package:flareline/pages/form/formModule1T1_page.dart'
    deferred as formModule1T1;
import 'package:flareline/pages/form/formModule1T2_page.dart'
    deferred as formModule1T2;
import 'package:flareline/pages/form/formModule1T3_page.dart'
    deferred as formModule1T3;
import 'package:flareline/pages/form/formModule2T1_page.dart'
    deferred as formModule2T1;
import 'package:flareline/pages/form/formModule2T_page.dart'
    deferred as formModule2T;
import 'package:flareline/pages/form/formModule2T2_page.dart'
    deferred as formModule2T2;
import 'package:flareline/pages/form/formModule3T1_page.dart'
    deferred as formModule3T1;
import 'package:flareline/pages/form/formModule3T2_page.dart'
    deferred as formModule3T2;
import 'package:flareline/pages/inbox/index.dart' deferred as inbox;
import 'package:flareline/pages/inbox/evaluations_page.dart'
    deferred as evaluations;
import 'package:flareline/pages/modal/modal_page.dart' deferred as modal;
import 'package:flareline/pages/profile/profile_page.dart' deferred as profile;
import 'package:flareline/pages/resetpwd/reset_pwd_page.dart'
    deferred as resetPwd;
import 'package:flareline/pages/setting/settings_page.dart'
    deferred as settings;
import 'package:flareline/pages/fiches/fiche_pedago_Page.dart'
    deferred as fichespedagogiques;
import 'package:flareline/pages/fiches/fiche_suivi_ame_Page.dart'
    deferred as suiviame;
import 'package:flareline/pages/form/formenseignEvaluation.dart'
    deferred as formenseign;
import 'package:flareline/pages/inbox/enseign_evaluations_page.dart'
    deferred as enseignevaluations;
import 'package:flareline/pages/fiches/contacts_page.dart' deferred as contacts;
import 'package:flareline/pages/toast/toast_page.dart' deferred as toast;
import 'package:flareline/pages/tools/tools_page.dart' deferred as tools;

// Page non différée (ex: dashboard)
import 'package:flareline/pages/dashboard/ecommerce_page.dart';

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

final List<Map<String, Object>> MAIN_PAGES = [
  {
    'routerPath': '/splash',
    'widget': DeferredWidget(splash.loadLibrary, () => splash.SplashScreen()),
  },
  {
    'routerPath': '/',
    'widget': const EcommercePage(),
  },
  {
    'routerPath': '/calendar',
    'widget': DeferredWidget(
        usermanagement.loadLibrary, () => usermanagement.UserManagementPage()),
  },
  {
    'routerPath': '/GestionAme1',
    'widget': DeferredWidget(
        soulmembers2.loadLibrary, () => soulmembers2.SoulMembersPage()),
  },
  {
    'routerPath': '/profile',
    'widget': DeferredWidget(profile.loadLibrary, () => profile.ProfilePage()),
  },
  {
    'routerPath': '/formLayout',
    'widget': DeferredWidget(
        formLayout.loadLibrary, () => formLayout.EvaluationFormPage()),
  },
  {
    'routerPath': '/formModule1T1',
    'widget': DeferredWidget(
        formModule1T1.loadLibrary,
        () => formModule1T1.EvaluationFormPage1(
              module: 'module1',
              theme: 'Jesus créateur de l\'univers',
            )),
  },
  {
    'routerPath': '/formModule1T2',
    'widget': DeferredWidget(
        formModule1T2.loadLibrary,
        () => formModule1T2.EvaluationFormPage2(
              module: 'module1',
              theme: 'bapteme',
            )),
  },
  {
    'routerPath': '/formModule1T3',
    'widget': DeferredWidget(
        formModule1T3.loadLibrary,
        () => formModule1T3.EvaluationFormPage3(
              module: 'module1',
              theme: 'Le Saint-Esprit',
            )),
  },
  {
    'routerPath': '/formModule2T1',
    'widget': DeferredWidget(
        formModule2T1.loadLibrary,
        () => formModule2T1.EvaluationFormPage4(
              module: 'module2',
              theme: 'LA PRIERE1',
            )),
  },
  {
    'routerPath': '/formModule2T',
    'widget': DeferredWidget(
        formModule2T.loadLibrary,
        () => formModule2T.EvaluationFormPage8(
              module: 'module2',
              theme: 'LA PRIERE2',
            )),
  },
  {
    'routerPath': '/formModule2T2',
    'widget': DeferredWidget(
        formModule2T2.loadLibrary,
        () => formModule2T2.EvaluationFormPage5(
              module: 'module2',
              theme: 'La Sanctification',
            )),
  },
  {
    'routerPath': '/formModule3T1',
    'widget': DeferredWidget(
        formModule3T1.loadLibrary,
        () => formModule3T1.EvaluationFormPage6(
              module: 'module3',
              theme: 'La Foi',
            )),
  },
  {
    'routerPath': '/formModule3T2',
    'widget': DeferredWidget(
        formModule3T2.loadLibrary,
        () => formModule3T2.EvaluationFormPage7(
              module: 'module3',
              theme: 'L\'Adoration',
            )),
  },
  {
    'routerPath': '/signIn',
    'widget': DeferredWidget(signIn.loadLibrary, () => signIn.SignInWidget()),
  },
  {
    'routerPath': '/signUp',
    'widget': DeferredWidget(signUp.loadLibrary, () => signUp.SignUpWidget()),
  },
  {
    'routerPath': '/registerAdmin',
    'widget': DeferredWidget(
        registerAdmin.loadLibrary, () => registerAdmin.RegisterAdminPage()),
  },
  {
    'routerPath': '/firstConnexion',
    'widget': DeferredWidget(
        firstConnexion.loadLibrary, () => firstConnexion.FirstConnexion()),
  },
  {
    'routerPath': '/resetPwd',
    'widget':
        DeferredWidget(resetPwd.loadLibrary, () => resetPwd.ResetPwdWidget()),
  },
  {
    'routerPath': '/inbox',
    'widget': DeferredWidget(inbox.loadLibrary, () => inbox.InboxWidget()),
  },
  {
    'routerPath': '/evaluations',
    'widget': DeferredWidget(
        evaluations.loadLibrary, () => evaluations.EvaluationsWidPage()),
  },
  {
    'routerPath': '/fichepedagogique',
    'widget': DeferredWidget(fichespedagogiques.loadLibrary,
        () => fichespedagogiques.FichePedagoPage()),
  },
  {
    'routerPath': '/enseignevaluations',
    'widget': DeferredWidget(
        formenseign.loadLibrary, () => formenseign.FormEnseignement()),
  },
  {
    'routerPath': '/suiviame',
    'widget': DeferredWidget(
        suiviame.loadLibrary, () => suiviame.FicheSuiviAmePage()),
  },
  {
    'routerPath': '/enseignevaluationstable',
    'widget': DeferredWidget(enseignevaluations.loadLibrary,
        () => enseignevaluations.EnseignEvaluationsPage()),
  },
  {
    'routerPath': '/ministrydatabase',
    'widget': DeferredWidget(ministrymembers.loadLibrary,
        () => ministrymembers.MinistryMembersPage()),
  },
  {
    'routerPath': '/settings',
    'widget':
        DeferredWidget(settings.loadLibrary, () => settings.SettingsPage()),
  },
  {
    'routerPath': '/basicChart',
    'widget': DeferredWidget(chart.loadLibrary, () => chart.ChartPage()),
  },
  {
    'routerPath': '/buttons',
    'widget': DeferredWidget(button.loadLibrary, () => button.ButtonPage()),
  },
  {
    'routerPath': '/alerts',
    'widget': DeferredWidget(alert.loadLibrary, () => alert.AlertPage()),
  },
  {
    'routerPath': '/contacts',
    'widget':
        DeferredWidget(contacts.loadLibrary, () => contacts.ContactsPage()),
  },
  {
    'routerPath': '/tools',
    'widget': DeferredWidget(tools.loadLibrary, () => tools.ToolsPage()),
  },
  {
    'routerPath': '/toast',
    'widget': DeferredWidget(toast.loadLibrary, () => toast.ToastPage()),
  },
  {
    'routerPath': '/modal',
    'widget': DeferredWidget(modal.loadLibrary, () => modal.ModalPage()),
  },
];

class RouteConfiguration {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'Rex');

  static BuildContext? get navigatorContext =>
      navigatorKey.currentState?.context;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    String path = settings.name!;

    final map = MAIN_PAGES.cast<Map<String, Object>?>().firstWhere(
          (element) => element?['routerPath'] == path,
          orElse: () => null,
        );

    if (map == null) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Page non trouvée")),
        ),
      );
    }

    Widget targetPage = map['widget'] as Widget;

    Widget builder(BuildContext context, String? _) {
      return targetPage;
    }

    return NoAnimationMaterialPageRoute<void>(
      builder: (context) => builder(context, null),
      settings: settings,
    );
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // pas d'animation
  }
}
