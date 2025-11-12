import 'package:flareline/core/theme/global_theme.dart';
import 'package:flareline_uikit/service/localization_provider.dart';
import 'package:flareline/routes.dart';
import 'package:flareline_uikit/service/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'package:flareline/providers/user_list_provider.dart'; // 👈 à importer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1080, 720),
      minimumSize: Size(480, 360),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      // d'autres providers ici...
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(_)),
        ChangeNotifierProvider(create: (_) => LocalizationProvider(_)),
        ChangeNotifierProvider(
            create: (_) => UserListProvider()..loadUsers()), // 👈 ajouté ici
      ],
      child: Builder(builder: (context) {
        context.read<LocalizationProvider>().supportedLocales =
            AppLocalizations.supportedLocales;

        return GetMaterialApp(
          navigatorKey: RouteConfiguration.navigatorKey,
          title: 'FlareLine',
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: context.watch<LocalizationProvider>().locale,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) =>
              RouteConfiguration.onGenerateRoute(settings),
          themeMode: context.watch<ThemeProvider>().isDark
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: GlobalTheme.lightThemeData,
          darkTheme: GlobalTheme.darkThemeData,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: widget!,
            );
          },
        );
      }),
    );
  }
}
