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
              tooltip: AppLocalizations.of(context).export_excel_tooltip,
              onPressed: () async {
                createExcel(context);
                /*
                final excel.Workbook workbook = new excel.Workbook();
                bool finalized = false;
try {
                int currentLine = 1;

                // this only works with android phones
                Directory dir = await getExternalStorageDirectory();
                String path = dir.path;
                File file = File("$path/excel.xlsx");

                print("file: $path");

                final excel.Worksheet sheet = workbook.worksheets[0];
                sheet.getRangeByName("A$currentLine").setValue("Date");
                // excel.Style style = workbook.styles.add('styles');
                // style.wrapText = true;
                // style.fontColor = "#C67878";
                // sheet.getRangeByName("A:A").cellStyle = style;
                sheet.getRangeByName("B$currentLine").setValue("Day");
                sheet.getRangeByName("C$currentLine").setValue("Schedule");
                sheet.getRangeByName("D$currentLine").setValue("N° hours");
                sheet.getRangeByName("E$currentLine").setValue("Workplace");
                sheet.getRangeByName("F$currentLine").setValue("\$/hour");
                sheet.getRangeByName("G$currentLine").setValue("Notes");

/*                
                sheet
                    .getRangeByName('A$currentLine')
                    .setValue(DateTime.now());

                List<int> bytes = workbook.saveAsStream();

                if (!file.existsSync()) {
                  file.createSync();
                }
                file.writeAsBytesSync(bytes);
                print("Finalized!");

                workbook.dispose();

                */
                // final List list = context.read<HoursProvider>().hours;
                final List years =
                await context.read<HoursProvider>().allYears
                ;//.then((years) {
                  years.sort();
                  print("prr1 $workbook");

                  // sheet.autoFitRow(1);
                  years.forEach((year) async {
                    // sheet.getRangeByName("A$currentLine").setValue(year);
                  print("prr2 $workbook");
                    currentLine += 1;
                    // currentLine += 4;
                              print("ra1 ${sheet.getRangeByName('A2')}");

                    List<int> months =
                    await context
                        .read<HoursProvider>()
                        .allMonthsInCurrentYear(year);
                        // .then((months) {
                      months.sort();

                      months.forEach((month) async {
                  print("prr3 $workbook");
                        // sheet.getRangeByName("A$currentLine").setValue(month);
                        // currentLine += 2;

                        List<int> days =
                        await context
                            .read<HoursProvider>()
                            .allDaysInCurrentYearAndMonth(year, month);
                            // .then((days) {
                          days.sort();
                              print("ra2 ${sheet.getRangeByName('A2')}");

                          days.forEach((day) async {
                            // final excel.Workbook workbook =
                            //     new excel.Workbook();
                            // excel.Worksheet sheet = workbook.worksheets[0];

                            currentLine += 1;
                            // DayData item = await
                            print("var $day");

                            print("years $years");
                            print("months $months");
                            print("days $days");

                            DayData item = await context
                                .read<HoursProvider>()
                                .getItem(DateTime.utc(year, month, day));
                                // .then((item) {
                              // print("sheet $sheet");
                              print("ra3 ${sheet.getRangeByName('A2')}");
                              // if (sheet != null) 

                              sheet.getRangeByName('A2').setDateTime(item.date);
                              // sheet.getRangeByName('A$currentLine').cellStyle.wrapText = true;
                              sheet
                                  .getRangeByName('B$currentLine')
                                  .setValue(item.getDayName(context));

                              sheet
                                  .getRangeByName('C$currentLine')
                                  .setValue(item.hours.join(', '));

                              sheet
                                  .getRangeByName('D$currentLine')
                                  .setNumber(item.totalHours);

                              sheet
                                  .getRangeByName('E$currentLine')
                                  .setText(item.place);
                              sheet.getRangeByName('F$currentLine').setNumber(
                                  item.pricePerHour ??
                                      context
                                          .read<ConfigurationProvider>()
                                          .pricePerHour);
                  List<int> bytes = workbook?.saveAsStream();

                  print("prr4 $workbook");
                              sheet
                                  .getRangeByName('G$currentLine')
                                  .setText(item.notes);
                            // });
                            if (days.last == day) {
                  // print("prr5 ${workbook.saveAsStream()}");
                              finalized = true;
                  sheet.getRangeByName("A1:A$currentLine").autoFitColumns();
                  sheet.getRangeByName("B1:B$currentLine").autoFitColumns();
                  sheet.getRangeByName("C1:C$currentLine").autoFitColumns();
                  sheet.getRangeByName("D1:D$currentLine").autoFitColumns();
                  sheet.getRangeByName("E1:E$currentLine").autoFitColumns();
                  sheet.getRangeByName("F1:E$currentLine").autoFitColumns();
                  sheet.getRangeByName("G1:E$currentLine").autoFitColumns();
                  // try {
                    // if (workbook != null)
                    print(workbook.toString());
                    // print(workbook.);

                  // } catch (e) {
                  //   print("error: $e");
                  //   // print(e);
                  // }
                  if (bytes != null ){
                  if (!file.existsSync()) {
                      file.createSync();
                    }
                    // file.writeAsBytesSync(bytes);
                    print("Finalized!");

                    workbook.dispose();
                  }
                            }
                          });
                        });
                      });
                      if (finalized) {



                      }
} catch (e) {print("err: $e");}
                      
                //     });
                //   });
                // }).then((value) {
                // });
                */
              }),
          IconButton(
              icon: Icon(Icons.add),
              tooltip: AppLocalizations.of(context).new_item_tooltip,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewItemScreen()));
              }),
          IconButton(
              icon: Icon(Icons.settings),
              tooltip: AppLocalizations.of(context).settings_tooltip,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())))
        ],
      ),
      body: FutureBuilder(
        future: context.watch<HoursProvider>().hours,
        builder: (context, snapshot) => !snapshot.hasData ||
                context.watch<HoursProvider>().loadingData
            ? Container(
                height: 300,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : snapshot.data.isEmpty
                ? Container(
                    // height: 300,
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context).no_data,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
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
                                value: /* month == 0 ? 0 :  */ month /* + 1 */, // TODO
                              ),
                            ),
                            onChanged: (monthSelected) async {
                              int actualMonth =
                                  context.read<HoursProvider>().currentMonth;
                              if (monthSelected != actualMonth)
                                context
                                    .read<HoursProvider>()
                                    .filterByMonth(monthSelected);
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
                            onChanged: (yearSelected) async {
                              int actualYear =
                                  context.read<HoursProvider>().currentYear;
                              // int currentMonth = context.read<HoursProvider>().currentMonth;
                              if (yearSelected != actualYear) {
                                context.read<HoursProvider>().currentMonth = 0;
                                // await context.read<HoursProvider>().filterByMonth(currentMonth);
                                // print("before\n\n");
                                // print("before\n\n");
                                // print("currentList ${await context.read<HoursProvider>().currentList} \n\n");

                                await context
                                    .read<HoursProvider>()
                                    .filterByYear(yearSelected)
                                    .then((value) {
                                  context.read<HoursProvider>().loadingData =
                                      false;
                                });

                                // print("after\n\n");
                                // print("after\n\n");
                                // print("currentList ${await context.read<HoursProvider>().currentList} \n\n");
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
      ),
    );
  }

  void createExcel(BuildContext context) async {
    final excel.Workbook workbook = new excel.Workbook();
    double defaultPrice = context.read<ConfigurationProvider>().pricePerHour;

    context.read<HoursProvider>();

    int currentLine = 1;

    // this only works with android phones

    final excel.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName("A$currentLine").setValue("Date");
    sheet.getRangeByName("B$currentLine").setValue("Day");
    sheet.getRangeByName("C$currentLine").setValue("Schedule");
    sheet.getRangeByName("D$currentLine").setValue("N° hours");
    sheet.getRangeByName("E$currentLine").setValue("Workplace");
    sheet.getRangeByName("F$currentLine").setValue("\$/hour");
    sheet.getRangeByName("G$currentLine").setValue("Notes");

    final List<int> years = await context.read<HoursProvider>().allYears;

    // return true;

    years.forEach((year) async {
      // print("CurrentLine: $currentLine");

      List<int> months =
          await context.read<HoursProvider>().allMonthsInCurrentYear(year);

      months.forEach((month) async {
        List<int> days = await context
            .read<HoursProvider>()
            .allDaysInCurrentYearAndMonth(year, month);

        days.forEach((day) {
          // DayData item = await 
          context
              .read<HoursProvider>()
              .getItem(DateTime.utc(year, month, day)).then((item) {
          // print("$day: $item");
          currentLine++;
                
          sheet.getRangeByName("A$currentLine").setDateTime(item.date);

          sheet
              .getRangeByName("B$currentLine")
              .setText(item.getDayName(context));

          sheet.getRangeByName("C$currentLine").setValue(item.hours.join(', '));
          sheet.getRangeByName("D$currentLine").setNumber(item.totalHours);
          sheet.getRangeByName("E$currentLine").setText(item.place
                  ?.toString() ??
              ""); // if the variable is null the function will throw an error.
          sheet
              .getRangeByName("F$currentLine")
              .setNumber(item.pricePerHour ?? defaultPrice);
          sheet.getRangeByName("G$currentLine").setText(item.notes);

/*
          sheet.getRangeByName('A$currentLine').setText(item.date.toString());
          // sheet.getRangeByName('A$currentLine').cellStyle.wrapText = true;
          sheet
              .getRangeByName('B$currentLine')
              .setValue(item.getDayName(context));

          sheet.getRangeByName('C$currentLine').setValue(item.hours.join(', '));

          sheet.getRangeByName('D$currentLine').setNumber(item.totalHours);

          sheet.getRangeByName('E$currentLine').setText(item.place);
          sheet.getRangeByName('F$currentLine').setNumber(item.pricePerHour ??
              context.read<ConfigurationProvider>().pricePerHour);

          print("prr4 $workbook");
          sheet.getRangeByName('G$currentLine').setText(item.notes);

*/
          sheet.getRangeByName("A$currentLine").autoFit();
          sheet.getRangeByName("E$currentLine").autoFit();
          sheet.getRangeByName("G$currentLine").autoFit();
              });
        });
      });

      // if (years.last == year) {}
      if (years.last == year) {}
    });

    // sheet.getRangeByName("A1:A$currentLine").columnWidth = 12;
    // sheet.getRangeByName("A1:A$currentLine").autoFitColumns();
    // sheet.getRangeByName("B1:B$currentLine").autoFitColumns();
    // sheet.getRangeByName("C1:C$currentLine").autoFitColumns();
    // sheet.getRangeByName("D1:D$currentLine").autoFitColumns();
    // sheet.getRangeByName("E1:E$currentLine").autoFitRows();
    // sheet.getRangeByName("F1:E$currentLine").autoFitColumns();
    // sheet.getRangeByName("G1:E$currentLine").autoFitColumns();

    Directory dir = await getExternalStorageDirectory();
    String path = dir.path;
    File file = File("$path/excel.xlsx");

    print("file: $path");

    List<int> bytes = workbook.saveAsStream();
    // if (file.existsSync()) file.deleteSync();
    if (bytes != null) {
      if (!file.existsSync()) {
        file.createSync();
      }
      file.writeAsBytesSync(bytes);
      print("Finalized!");

      workbook.dispose();
    }
  }
}
