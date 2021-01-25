import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:hours_tracker/HoursTableScreen.dart';
import 'package:hours_tracker/SettingsScreen.dart';
import 'package:hours_tracker/data/dayData.dart';
import 'package:hours_tracker/providers/configuration.dart';
import 'package:hours_tracker/providers/hours.dart';
import 'package:hours_tracker/screens/NewItemScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double pricePerHour = context.read<ConfigurationProvider>().pricePerHour;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.wysiwyg),
              onPressed: () async {
                final excel.Workbook workbook = new excel.Workbook();

                // final List list = context.read<HoursProvider>().hours;
                final List years = context.read<HoursProvider>().allYears;
                years.sort();

                int currentLine = 1;

                // this only works with android phones
                Directory dir = await getExternalStorageDirectory();
                String path = dir.path;
                File file = File("$path/excel.xlsx");

                print("file: $path");

                // print(File('${dir.path}/excel.xlsx'));

                excel.Worksheet sheet = workbook.worksheets[0];
                sheet.getRangeByName("A$currentLine").setValue("Date");
                // excel.Style style = workbook.styles.add('styles');
                // style.wrapText = true;
                // style.fontColor = "#C67878";
                // sheet.getRangeByName("A:A").cellStyle = style;
                sheet.getRangeByName("B$currentLine").setValue("Day");
                sheet.getRangeByName("C$currentLine").setValue("Schedule");
                sheet.getRangeByName("D$currentLine").setValue("Workplace");
                sheet.getRangeByName("E$currentLine").setValue("\$/hour");

                // sheet.autoFitRow(1);
                years.forEach((year) {
                  // sheet.getRangeByName("A$currentLine").setValue(year);
                  currentLine += 1;
                  // currentLine += 4;

                  List<int> months = context
                      .read<HoursProvider>()
                      .allMonthsInCurrentYear(year);
                  months.sort();
                  months.forEach((month) {
                    // sheet.getRangeByName("A$currentLine").setValue(month);
                    // currentLine += 2;

                    List<int> days = context
                        .read<HoursProvider>()
                        .allDaysInCurrentYearAndMonth(year, month);
                    days.sort();
                    days.forEach((day) {
                      currentLine += 1;
                      DayData item = context
                          .read<HoursProvider>()
                          .getItem(DateTime.utc(year, month, day));

                      sheet
                          .getRangeByName('A$currentLine')
                          .setDateTime(item.date);
                      // sheet.getRangeByName('A$currentLine').cellStyle.wrapText = true;
                      sheet
                          .getRangeByName('B$currentLine')
                          .setValue(item.getDayName(context));
                      sheet
                          .getRangeByName('C$currentLine')
                          .setValue(item.hours.join(', '));
                      sheet.getRangeByName('D$currentLine').setText(item.place);
                      sheet.getRangeByName('E$currentLine').setNumber(item
                              .pricePerHour ??
                          context.read<ConfigurationProvider>().pricePerHour);
                    });
                  });
                });

                sheet.getRangeByName("A1:A$currentLine").autoFitColumns();
                sheet.getRangeByName("B1:B$currentLine").autoFitColumns();
                sheet.getRangeByName("C1:C$currentLine").autoFitColumns();
                sheet.getRangeByName("D1:D$currentLine").autoFitColumns();
                sheet.getRangeByName("E1:E$currentLine").autoFitColumns();

                List<int> bytes = workbook.saveAsStream();

                if (!file.existsSync()) {
                  file.createSync();
                }
                file.writeAsBytesSync(bytes);
                print("Finalized!");
                workbook.dispose();
              }),
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
                      "${AppLocalizations.of(context).total}: \$${context.watch<HoursProvider>().currentListTotal(pricePerHour)}",
                      style: TextStyle(fontSize: 18),
                    )),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
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
                // == 0 ? "All" : context.watch<HoursProvider>().currentMonth,
                isDense: true,
                selectedItemBuilder: (context) => List.generate(
                  13,
                  (month) => month == 0
                      ? Text(AppLocalizations.of(context).all)
                      : Text(
                          "${AppLocalizations.of(context).month}: ${month}"),
                ),
                items: List.generate(
                  13,
                  (month) => DropdownMenuItem(
                    child: month == 0
                        ? Text(AppLocalizations.of(context).all)
                        : Text("$month"),
                    value: /* month == 0 ? 0 :  */month /* + 1 */, // TODO
                  ),
                ),
                onChanged: (monthSelected) {
                  int actualMonth = context.read<HoursProvider>().currentMonth;
                  if (monthSelected != actualMonth)
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
                onChanged: (yearSelected) {
                  int actualYear = context.read<HoursProvider>().currentYear;
                  int currentMonth = context.read<HoursProvider>().currentMonth;
                  if (yearSelected != actualYear) {
                    // var s = Stopwatch()..start();
                    context.read<HoursProvider>().filterByMonth(currentMonth);
                    // var function =
                    context.read<HoursProvider>().currentMonth = 0;
                    context.read<HoursProvider>().filterByYear(yearSelected);

                    // s.stop();
                    // print("${s.elapsedMicroseconds}");
                  }
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
