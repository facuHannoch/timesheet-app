import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hours_tracker/providers/hours.dart';
import 'package:hours_tracker/providers/configuration.dart';
import 'package:hours_tracker/screens/homeScreen.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const DEFAULT_COLOR_VALUE = Colors.blueAccent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int appPrimaryColor =
      prefs.getInt("appPrimaryColor") ?? DEFAULT_COLOR_VALUE.value;

  runApp(App(appPrimaryColor: appPrimaryColor));
}

class App extends StatelessWidget {
  final int appPrimaryColor;

  const App({Key key, this.appPrimaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigurationProvider>(
            create: (context) =>
                ConfigurationProvider(appPrimaryColor: appPrimaryColor)),
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
        title: 'Hours Tracker',
        theme: ThemeData(
          primaryColor:
              Color(context.watch<ConfigurationProvider>().appPrimaryColor),
        ),
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
