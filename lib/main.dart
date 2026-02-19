import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/ssh_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/lg_controller.dart';
import 'controllers/city_controller.dart';
import 'views/home/home_page.dart';
import 'views/settings/settings_page.dart';
import 'constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings before the app renders
  final settingsController = SettingsController();
  await settingsController.loadSettings();

  runApp(LgApp(settingsController: settingsController));
}

class LgApp extends StatelessWidget {
  final SettingsController settingsController;
  const LgApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Layer 1 — infrastructure (no dependencies)
        ChangeNotifierProvider<SshController>(
          create: (_) => SshController(),
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),

        // Layer 2 — LG orchestration (depends on SSH + Settings)
        ChangeNotifierProxyProvider2<SshController, SettingsController,
            LgController>(
          create: (ctx) => LgController(
            sshController: ctx.read<SshController>(),
            settingsController: ctx.read<SettingsController>(),
          ),
          update: (ctx, ssh, settings, prev) =>
              prev ??
              LgController(sshController: ssh, settingsController: settings),
        ),

        // Layer 3 — App Logic (depends on LgController)
        ChangeNotifierProxyProvider<LgController, CityController>(
          create: (ctx) =>
              CityController(lgController: ctx.read<LgController>()),
          update: (ctx, lg, prev) => prev ?? CityController(lgController: lg),
        ),
      ],
      child: MaterialApp(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          colorScheme: ColorScheme.dark(
            primary: Colors.lightBlueAccent,
            secondary: Colors.blueAccent,
          ),
        ),
        initialRoute: HomePage.routeName,
        routes: {
          HomePage.routeName: (_) => const HomePage(),
          SettingsPage.routeName: (_) => const SettingsPage(),
        },
      ),
    );
  }
}
