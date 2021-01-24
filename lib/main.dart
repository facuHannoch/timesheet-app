import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hours_tracker/providers/hours.dart';
import 'package:hours_tracker/providers/configuration.dart';
import 'package:hours_tracker/screens/homeScreen.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Admob.initialize();

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigurationProvider>(
            create: (context) => ConfigurationProvider()),
        ChangeNotifierProvider<HoursProvider>(
            create: (context) => HoursProvider()),
      ],
      builder: (context, child) => MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
        ],
        title: 'Electric ',
        home: App2(),
      ),
    );
  }
}

class App2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}
