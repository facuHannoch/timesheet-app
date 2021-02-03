import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timesheet/providers/hours.dart';
import 'package:timesheet/providers/configuration.dart';
import 'package:timesheet/screens/homeScreen.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const DEFAULT_COLOR_VALUE = Colors.blueAccent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int appPrimaryColor = prefs.getInt("appPrimaryColor") ?? DEFAULT_COLOR_VALUE.value;

  Admob.initialize();

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
        title: 'Timesheet',
        theme: ThemeData(
          primaryColor:
              Color(context.watch<ConfigurationProvider>().appPrimaryColor),
        ),
        home: App2(),
      ),
    );
  }
}

class App2 extends StatefulWidget {
  @override
  _App2State createState() => _App2State();
}

class _App2State extends State<App2> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }

  @override
  void dispose() {
    context.read<HoursProvider>().disposeInterstitials();
    super.dispose();
  }
}
