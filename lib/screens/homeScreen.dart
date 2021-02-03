import 'dart:io';
// import 'dart:isolate';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:timesheet/HoursTableScreen.dart';
import 'package:timesheet/SettingsScreen.dart';
import 'package:timesheet/providers/configuration.dart';
import 'package:timesheet/providers/hours.dart';
import 'package:timesheet/screens/NewItemScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double pricePerHour = context.read<ConfigurationProvider>().pricePerHour;
    var orientation = MediaQuery.of(context).orientation;
    int currentYear =
        context.watch<HoursProvider>().currentYear ?? DateTime.now().year;
    List<int> allYears = context.watch<HoursProvider>().listYears;

    GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

    List<Widget> informationAndSelectionPanel = [
      Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: orientation == Orientation.portrait ? 16.0 : 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    child: Text(
                  "${AppLocalizations.of(context).total}: \$${context.watch<HoursProvider>().currentListTotal(pricePerHour)}",
                  style: TextStyle(fontSize: 18),
                )),
                Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
              13,
              (month) => month == 0
                  ? Text(AppLocalizations.of(context).all)
                  : Text("${AppLocalizations.of(context).month}: $month"),
            ),
            items: List.generate(
              13,
              (month) => DropdownMenuItem(
                  child: month == 0
                      ? Text(AppLocalizations.of(context).all)
                      : Text("$month"),
                  value: month),
            ),
            onChanged: (monthSelected) async {
              int actualMonth = context.read<HoursProvider>().currentMonth;
              if (monthSelected != actualMonth)
                context.read<HoursProvider>().filterByMonth(monthSelected);
            },
          ),
          SizedBox(width: orientation == Orientation.landscape ? 32 : 0),
          DropdownButton(
            // we set the value to the current month every time the users enters the app
            // value: DateTime.now().month,
            value: currentYear,
            isDense: true,
            selectedItemBuilder: (context) => (allYears ?? [currentYear])
                .map<Widget>(
                  (year) => Text("${AppLocalizations.of(context).year}: $year"),
                )
                .toList(),
            items: (allYears ?? [currentYear])
                .map<DropdownMenuItem>(
                  (year) => DropdownMenuItem(
                    child: Text("$year"),
                    value: year,
                    // child: Text("${DateTime.now().year - year}"),
                    // value: DateTime.now().year - year,
                  ),
                )
                .toList(),
            // selectedItemBuilder: (context) => List.generate(
            //   DateTime.now().year - 1900,
            //   (year) => Text(
            //       "${AppLocalizations.of(context).year}: ${DateTime.now().year - year}"),
            // ),
            // items: List.generate(
            //   DateTime.now().year - 1900,
            //   (year) => DropdownMenuItem(
            //     child: Text("${DateTime.now().year - year}"),
            //     value: DateTime.now().year - year,
            //   ),
            // ),
            onChanged: (yearSelected) async {
              int actualYear = context.read<HoursProvider>().currentYear;
              if (yearSelected != actualYear) {
                context.read<HoursProvider>().currentMonth = 0;
                await context
                    .read<HoursProvider>()
                    .filterByYear(yearSelected)
                    .then((value) {
                  context.read<HoursProvider>().loadingData = false;
                });
              }
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).app_title),
        actions: [
          IconButton(
            icon: Icon(Icons.wysiwyg),
            tooltip: AppLocalizations.of(context).export_excel_tooltip,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context).export_excel_title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    // shrinkWrap: true,
                    // physics:
                    //     ClampingScrollPhysics(), // the scroll bouncing doesn't look too good here
                    children: [
                      ListTile(
                        title: Text(AppLocalizations.of(context)
                            .export_excel_full_table),
                        onTap: () {
                          createExcel(context).then((result) async {
                            if (result) {
                              await context
                                  .read<HoursProvider>()
                                  .showInterstitial(export: true);
                              _scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .file_exported_text),
                              ));
                            }
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)
                            .export_excel_current_table),
                        subtitle: Text(AppLocalizations.of(context)
                            .export_excel_current_table_description),
                        onTap: () {
                          createExcel(context, true).then((result) async {
                            await context
                                .read<HoursProvider>()
                                .showInterstitial(export: true);
                            if (result) {
                              _scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .file_exported_text),
                              ));
                            }
                          });
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        color: Theme.of(context).primaryColor,
                        height: 11.4,
                      ),
                      Text(
                          "${AppLocalizations.of(context).file_location_label}:\n storage/emulated/0/Android/data/com.appneft.timesheet/files",
                          style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
              );
            },
          ),
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
        builder: (context, snapshot) =>
            !snapshot.hasData || context.watch<HoursProvider>().loadingData
                ? Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : pricePerHour == 0
                    ? Container(
                        padding: EdgeInsets.all(30.0),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).price_per_hours_not_set,
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
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
                              // MediaQuery.of(context).orientation ==
                              orientation == Orientation.portrait
                                  ? Column(
                                      children: informationAndSelectionPanel,
                                    )
                                  : Row(
                                      children: informationAndSelectionPanel,
                                    ),
                              // OrientationBuilder(
                              //   builder: (context, orientation) {
                              //     // orientation = Orientation.landscape;
                              //     return orientation == Orientation.portrait
                              //         ? Column(
                              //             children: informationAndSelectionPanel,
                              //           )
                              //         : Row(
                              //             children: informationAndSelectionPanel,
                              //           );
                              //   },
                              // ),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: orientation == Orientation.portrait
                                          ? 16
                                          : 0),
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
      bottomNavigationBar: Container(
        height: 65,
        color: Colors.black12,
        child: AdmobBanner(
          adUnitId: AdmobBanner.testAdUnitId,
          adSize: AdmobBannerSize.BANNER,
        ),
      ),
    );
  }

  Future<bool> createExcel(BuildContext context,
      [bool justCurrentList = false]) async {
    final excel.Workbook workbook = new excel.Workbook();
    double defaultPrice = context.read<ConfigurationProvider>().pricePerHour;

    int currentYear = context.read<HoursProvider>().currentYear;
    int currentMonth = context.read<HoursProvider>().currentMonth;

    context.read<HoursProvider>();

    int currentLine = 1;

    final excel.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName("A$currentLine").setValue(
        AppLocalizations.of(context).table_date_label); //setValue("Date");
    sheet.getRangeByName("B$currentLine").setValue(
        AppLocalizations.of(context).table_day_name_label); //setValue("Day");
    sheet.getRangeByName("C$currentLine").setValue(AppLocalizations.of(context)
        .table_schedule_label); //setValue("Schedule");
    sheet.getRangeByName("D$currentLine").setValue(AppLocalizations.of(context)
        .table_number_hours_label); //setValue("N° hours");
    sheet.getRangeByName("E$currentLine").setValue(AppLocalizations.of(context)
        .table_workplace_label); //setValue("Workplace");
    sheet.getRangeByName("F$currentLine").setValue(AppLocalizations.of(context)
        .table_price_per_hour_label); //setValue("\$/hour");
    sheet.getRangeByName("G$currentLine").setValue(
        AppLocalizations.of(context).table_notes_label); //setValue("Notes");

    List<int> years;

    if (justCurrentList)
      years = [currentYear];
    else
      years = await context.read<HoursProvider>().allYears;

    years.forEach((year) async {
      List<int> months;

      // when picking a month, the user can pick an option "all", repreented by a 0.
      // So if the user chooses to export just the current month, there are two options:
      // 1- the month selected is "all" (0)
      // 2- the month selected is not 0, so it is a real month
      // in the first case, we'll just take all the months in the selected year with records
      if (!justCurrentList || (justCurrentList && currentMonth == 0))
        months =
            await context.read<HoursProvider>().allMonthsInCurrentYear(year);
      else
        // in the second case, we'll just set the list months to a list of only the current month
        months = [currentMonth];

      months.forEach((month) async {
        List<int> days = await context
            .read<HoursProvider>()
            .allDaysInCurrentYearAndMonth(year, month);

        days.forEach((day) {
          // DayData item = await
          context
              .read<HoursProvider>()
              .getItem(DateTime.utc(year, month, day))
              .then((item) {
            currentLine++;

            sheet.getRangeByName("A$currentLine").setDateTime(item.date);

            sheet
                .getRangeByName("B$currentLine")
                .setText(item.getDayName(context));

            sheet
                .getRangeByName("C$currentLine")
                .setValue(item.hours.join(', '));
            sheet.getRangeByName("D$currentLine").setNumber(item.totalHours);
            sheet
                .getRangeByName("E$currentLine")
                // if the variable passed to setText() is null the function getRangeByName() will throw an error.
                .setText(item.place?.toString() ?? "");
            sheet
                .getRangeByName("F$currentLine")
                .setNumber(item.pricePerHour ?? defaultPrice);
            sheet.getRangeByName("G$currentLine").setText(item.notes);

            sheet.getRangeByName("A$currentLine").autoFit();
            sheet.getRangeByName("E$currentLine").autoFit();
            sheet.getRangeByName("G$currentLine").autoFit();
          });
        });
      });
    });

    // sheet.getRangeByName("A1:A$currentLine").columnWidth = 12;
    // sheet.getRangeByName("A1:A$currentLine").autoFitColumns();
    // sheet.getRangeByName("B1:B$currentLine").autoFitColumns();
    // sheet.getRangeByName("C1:C$currentLine").autoFitColumns();
    // sheet.getRangeByName("D1:D$currentLine").autoFitColumns();
    // sheet.getRangeByName("E1:E$currentLine").autoFitRows();
    // sheet.getRangeByName("F1:E$currentLine").autoFitColumns();
    // sheet.getRangeByName("G1:E$currentLine").autoFitColumns();

    // this only works with android phones
    Directory dir = await getExternalStorageDirectory();

    String path = dir.path;
    File file = File("$path/excel.xlsx");

    List<int> bytes = workbook.saveAsStream();
    if (bytes != null) {
      if (!file.existsSync()) {
        file.createSync();
      }
      file.writeAsBytesSync(bytes);
      workbook.dispose();

      return true;
    } else {
      return false;
    }
  }
}
