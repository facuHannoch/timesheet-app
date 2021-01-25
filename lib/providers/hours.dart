// import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';
import 'package:provider/provider.dart';

class HoursProvider with ChangeNotifier {
  List hours;

  List /* <DayData> */ currentList;
  int _currentMonth = DateTime.now().month;

  int currentYear = DateTime.now().year;

  HoursProvider() {
    hours = getData();
    this.filterByMonth();
  }

  // **********************
  // list and items edition

  editItem(DateTime date, DayData day) {
    int index = hours.indexWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
    hours[index] = day;

    this.filterByMonth();

    notifyListeners();
    saveData();
  }

  void deleteItem(DateTime date) {
    hours.removeWhere((hourItem) =>
        hourItem.date.year == date.year &&
        hourItem.date.month == date.month &&
        hourItem.date.day == date.day);

    // we get the new current list by calling the method again
    this.filterByMonth();

    notifyListeners();
    saveData();
  }

  // **********************
  // data management

  addNewItem(DayData day) {
    hours.add(day);

    this.filterByMonth();

    notifyListeners();

    saveData();
  }

  filterByMonth([int month]) {
    if (month == null) {
      month = currentMonth;
    } else {
      currentMonth = month;
    }
    // var s = Stopwatch()..start();
    if (month > 0 && month <= 12) {
      List<DayData> filteredList = [];
      hours.forEach((item) => {
            if (item.date.month == month && item.date.year == currentYear)
              filteredList.add(item)
          });
      currentList = filteredList;
      notifyListeners();
    } else if (month == 0) {
      this.filterByYear();
    }
    // s.stop();
    // print("s ${s.elapsedMicroseconds}");
  }

  filterByYear([int year]) {
    // var s = Stopwatch()..start();
    if (year != null) {
      currentYear = year;
    } else {
      year = currentYear;
    }

    // compute(
    //   (params) {

    //   }
    // );

    // Isolate.spawn((params) {}, 'Finished');

    List<DayData> filteredList = [];
    hours.forEach((item) => {
          if (item.date.year == year) {filteredList.add(item)}
        });
    currentList = filteredList;

    notifyListeners();

    // s.stop();
    // print("${s.elapsedMicroseconds}");
  }

  // **********************
  // getting class info

  getItem(DateTime date) {
    return hours.firstWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
  }

  currentListTotal(defaultPrice) {
    double total = 0;
    for (var item in currentList) {
      total += item.totalHours * (item.pricePerHour ?? defaultPrice ?? 0);
    }
    return total;
  }

  get currentListTotalHours {
    double totalHours = 0;
    for (var item in currentList) {
      totalHours += item.totalHours;
    }
    return totalHours;
  }

  // get total {
  //   double total = 0;
  //   for (var item in hours) {
  //     total += item.totalHours * (item.pricePerHour ?? 0);
  //   }
  //   return total;
  // }

  // get totalHours {
  //   double totalHours = 0;
  //   for (var item in hours) {
  //     totalHours += item.totalHours;
  //   }
  //   return totalHours;
  // }

  List get allYears {
    List<int> years = [];
    hours.forEach((item) {
      if (!years.contains(item.date.year)) {
        years.add(item.date.year);
      }
    });
    return years;
  }

  List allMonthsInCurrentYear([year]) {
    // CalendarDatePicker();
    List<int> months = [];
    hours.forEach((item) {
      if (item.date.year == (year ?? currentYear)) {
        if (!months.contains(item.date.month)) {
          months.add(item.date.month);
        }
      }
    });
    return months;
  }

  List allDaysInCurrentYearAndMonth([year, month]) {
    List<int> days = [];
    hours.forEach((item) {
      if (item.date.year == (year ?? currentYear)) {
        if (item.date.month == (month ?? currentMonth)) {
          if (!days.contains(item.date.day)) {
            days.add(item.date.day);
          }
        }
      }
    });
    return days;
  }

  // **********************
  // getters and setters
  int get currentMonth => _currentMonth;

  set currentMonth(int currentMonth) {
    _currentMonth = currentMonth;
    notifyListeners();
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
    DateTime.parse('2020-03-20'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 22)],
    ),
  ),
  DayData(
    DateTime.parse('2019-03-20'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 22)],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-02'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 22)],
    ),
  ),
  // ...List.generate(
  //   365,
  //   (index) {
  //     if (index == 20)
  //       return DayData(
  //         // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
  //         DateTime.utc(2019, /* index +  */ 1, index + 1),
  //         "Newbery",
  //         // Set<HoursClass>.of(
  //         List<HoursClass>.of(
  //           [HoursClass(8, 22), HoursClass(8, 22)],
  //         ),
  //         pricePerHour: 179,
  //       );
  //     return DayData(
  //       // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
  //       DateTime.utc(2021, /* index +  */ 1, index + 1),
  //       "Newbery",
  //       // Set<HoursClass>.of(
  //       List<HoursClass>.of(
  //         [HoursClass(8, 22)],
  //       ),
  //       pricePerHour: 80,
  //     );
  //   },
  // )
];

List<DayData> testList2 = [
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
