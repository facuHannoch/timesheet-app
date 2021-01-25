import 'package:flutter/material.dart';
import 'package:hours_tracker/HoursTableScreen.dart';
import 'package:hours_tracker/SettingsScreen.dart';
import 'package:hours_tracker/providers/hours.dart';
import 'package:hours_tracker/screens/NewItemScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewItemScreen()));
              }),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())))
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Text(
                      "${AppLocalizations.of(context).total}: \$${context.watch<HoursProvider>().currentListTotal}",
                      style: TextStyle(fontSize: 18),
                    )),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      child: Text(
                        "${AppLocalizations.of(context).total_hours}: ${context.watch<HoursProvider>().currentListTotalHours}",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton(
                // we set the value to the current month every time the users enters the app
                // value: DateTime.now().month,
                value: context.watch<HoursProvider>().currentMonth,
                isDense: true,
                selectedItemBuilder: (context) => List.generate(
                  12,
                  (month) => Text(
                      "${AppLocalizations.of(context).month}: ${month + 1}"),
                ),
                items: List.generate(
                  12,
                  (month) => DropdownMenuItem(
                    child: Text("${month + 1}"),
                    value: month + 1,
                  ),
                ),
                onChanged: (monthSelected) {
                  context.read<HoursProvider>().filterByMonth(monthSelected);
                },
              ),
              DropdownButton(
                // we set the value to the current month every time the users enters the app
                // value: DateTime.now().month,
                value: context.watch<HoursProvider>().currentYear,
                isDense: true,
                selectedItemBuilder: (context) => List.generate(
                  DateTime.now().year - 1900,
                  (year) => Text(
                      "${AppLocalizations.of(context).year}: ${DateTime.now().year - year}"),
                ),
                items: List.generate(
                  DateTime.now().year - 1900,
                  (year) => DropdownMenuItem(
                    child: Text("${DateTime.now().year - year}"),
                    value: DateTime.now().year - year,
                  ),
                ),
                onChanged: (monthSelected) {
                  context.read<HoursProvider>().filterByYear(monthSelected);
                },
              ),
            ],
          ),
          // YearPicker
          Flexible(
            child: Container(
              margin: EdgeInsets.only(top: 16.0),
              child: ListView(
                // shrinkWrap: true,
                children: [
                  HoursTableScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
