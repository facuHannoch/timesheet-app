import 'package:flutter/material.dart';
import 'package:timesheet/providers/configuration.dart';
import 'package:timesheet/providers/hours.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timesheet/screens/NewItemScreen.dart';

import 'package:provider/provider.dart';

class HoursTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isAscending = context.watch<HoursProvider>().sortAscending;
    List hours =
        context.watch<HoursProvider>().currentList /*  ?? Future.value([]) */;
    return hours.isEmpty
        ? Container(
            height: 300,
            padding: EdgeInsets.all(32.0),
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context).current_filter_no_data,
              textAlign: TextAlign.center,
            ),
          )
        : Container(
            // child: FutureBuilder(
            //   future: hours,
            //   builder: (context, snapshot) => !snapshot.hasData ||
            //           context.watch<HoursProvider>().loadingData
            //       ? Container(
            //           height: 300,
            //           alignment: Alignment.center,
            //           child: CircularProgressIndicator(),
            //         )
            //       : snapshot.data.isEmpty
            //           ? Container(
            //               height: 300,
            //               alignment: Alignment.center,
            //               child: Text("No data entered yet"),
            //             )
            //           :
            child: SingleChildScrollView(
              // reverse: true,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  sortColumnIndex: 0,
                  dataRowHeight: 60,
                  sortAscending: isAscending,
                  // sortAscending: false,

                  // 22:00 - 23:45, 22:00 - 23:45, 22:00 - 23:45, 22:00 - 23:45, 22:00 - 23:45, 22:00 - 23:45 22:00, - 23:45

                  columns: [
                    DataColumn(
                      label:
                          Text(AppLocalizations.of(context).table_date_label),
                      onSort: (columnIndex, ascending) {
                        return context
                            .read<HoursProvider>()
                            .sortCurrentListByDay(ascending);
                      },
                    ),
                    DataColumn(
                      label: Text(
                          AppLocalizations.of(context).table_day_name_label),
                    ),
                    DataColumn(
                      label: Text(
                          AppLocalizations.of(context).table_schedule_label),
                    ),
                    DataColumn(
                      label: Text(AppLocalizations.of(context)
                          .table_number_hours_label),
                    ),
                    DataColumn(
                      label: Text(
                          AppLocalizations.of(context).table_workplace_label),
                    ),
                    DataColumn(
                      label: Text(AppLocalizations.of(context)
                          .table_price_per_hour_label),
                    ),
                    DataColumn(
                        label: Text(AppLocalizations.of(context)
                            .new_item_notes_label_title)),
                    DataColumn(
                      label:
                          Text(AppLocalizations.of(context).table_edit_label),
                    ),
                    DataColumn(
                      label:
                          Text(AppLocalizations.of(context).table_delete_label),
                    )
                  ],
                  rows: hours
                      .map<DataRow>(
                        (dayData) => DataRow(
                          cells: [
                            DataCell(Text("${dayData.day} - ${dayData.month}")),
                            DataCell(Text(dayData.getDayName(context))),
                            DataCell(
                              SingleChildScrollView(
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: dayData.hours
                                      .map<Widget>((hourPair) => Text(
                                          "${hourPair.initHour} - ${hourPair.endHour}"))
                                      .toList(),
                                  // child: Text(
                                  //     "${dayData.hours[0].initHour} - ${dayData.hours[0].endHour}"),
                                ),
                              ),
                              // showEditIcon: true
                            ),
                            DataCell(
                                Text(dayData?.totalHours.toString() ?? "")),
                            DataCell(Text(dayData?.place ?? "")),
                            DataCell(
                              Text(
                                "\$${dayData.pricePerHour ?? context.read<ConfigurationProvider>().pricePerHour}",
                              ),
                              // != null
                              //     ? "\$ ${dayData.pricePerHour}"
                              //     : ""),
                            ),
                            DataCell(
                              // Wrap(child: Text(dayData?.notes ?? "")),
                              Container(
                                width: 150,
                                child: SingleChildScrollView(
                                    child: Text(dayData?.notes ?? "")),
                              ),
                              placeholder: true,
                            ),
                            DataCell(IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewItemScreen(item: dayData)));
                                  // context.read<HoursProvider>().editItem()
                                })),
                            DataCell(IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  context
                                      .read<HoursProvider>()
                                      .deleteItem(dayData.date);
                                }))
                          ],
                        ),
                      )
                      .toList()

                  // [
                  //   // value.hours.forEach(()
                  //   // => DataRow()),
                  //   DataRow(cells: [DataCell()]),
                  //   // value.hours.map<DataRow>((dayData) {
                  //   //   return
                  //   // });
                  // ],
                  ),
            ),
            // ),
          );
    // child: Container(
    // Their optional child argument allows to rebuild only a very specific part of the widget tree
    //   child: Text()
    // ),
  }
}
