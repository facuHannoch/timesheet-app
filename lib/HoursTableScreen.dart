import 'package:flutter/material.dart';
import 'package:hours_tracker/providers/hours.dart';

import 'package:provider/provider.dart';

class HoursTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("list ${context.read<HoursProvider>().hours}");
    return Consumer<HoursProvider>(
      builder: (context, value, child) => Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columns: [
                DataColumn(
                  label: Text("dia"),
                ),
                DataColumn(
                  label: Text("nombre del dia"),
                ),
                DataColumn(
                  label: Text("horario"),
                ),
                DataColumn(
                  label: Text("lugar"),
                ),
                DataColumn(
                  label: Text("\$/hora"),
                )
              ],
              rows: value.hours
                  .map<DataRow>(
                    (dayData) => DataRow(
                      cells: [
                        DataCell(Text("${dayData.day} - ${dayData.month}")),
                        DataCell(Text(dayData.dayName)),
                        DataCell(
                          Wrap(
                            direction: Axis.vertical,
                            children: dayData.hours
                                .map((hourPair) => Text(
                                    "${hourPair.initHour} - ${hourPair.endHour}"))
                                .toList(),
                            // child: Text(
                            //     "${dayData.hours[0].initHour} - ${dayData.hours[0].endHour}"),
                          ),
                        ),
                        DataCell(Text(dayData?.place ?? "")),
                        DataCell(
                          Text(dayData.pricePerHour != null
                              ? "\$ ${dayData.pricePerHour}"
                              : ""),
                        ),
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
      ),
      // child: Container(
      // Their optional child argument allows to rebuild only a very specific part of the widget tree
      //   child: Text()
      // ),
    );
  }
}
