import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';
import 'package:provider/provider.dart';

class HoursProvider with ChangeNotifier {
  List<DayData> hours;

  HoursProvider() {
    hours = getData();
  }


  // **********************
  // data management

  addNewItem(DayData day) {
    hours.add(day);

    notifyListeners();

    saveData();
  }

  // **********************
  // data saving/retrieving

  saveData() {}

  getData() {
    return testList;
  }
}

List<DayData> testList = [
  DayData(
    DateTime.parse('2021-01-20'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 22)],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-21'),
    "San Martín",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(14, 20)],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-22'),
    "San Martín",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 20)],
    ),
  ),
  DayData(
    DateTime.now(),
    "San Martín",
    List<HoursClass>.of(
      [HoursClass(2, 4), HoursClass(5, 7)],
    ),
  ),
];
