import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';
import 'package:provider/provider.dart';

class HoursProvider with ChangeNotifier {
  List hours;

  List /* <DayData> */ currentList;
  int currentMonth = DateTime.now().month;
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

    List<DayData> filteredList = [];
    hours.forEach((item) => {
          if (item.date.month == month && item.date.year == currentYear)
            filteredList.add(item)
        });
    currentList = filteredList;
    notifyListeners();
    // s.stop();
    // print("s ${s.elapsedMicroseconds}");
  }

  filterByYear(int year) {
    currentYear = year;

    List<DayData> filteredList = [];
    hours.forEach((item) => {
          if (item.date.year == year) {filteredList.add(item)}
        });
    currentList = filteredList;
    notifyListeners();
  }

  // **********************
  // getting class info

  get currentListTotal {
    double total = 0;
    for (var item in currentList) {
      total += item.totalHours * (item.pricePerHour ?? 0);
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
  ...List.generate(
    100,
    (index) {
      if (index == 20)
        return DayData(
          // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
          DateTime.utc(2019, /* index +  */ 1, index + 1),
          "Newbery",
          // Set<HoursClass>.of(
          List<HoursClass>.of(
            [HoursClass(8, 22)],
          ),
          pricePerHour: 80,
        );
      return DayData(
        // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
        DateTime.utc(2021, /* index +  */ 1, index + 1),
        "Newbery",
        // Set<HoursClass>.of(
        List<HoursClass>.of(
          [HoursClass(8, 22)],
        ),
        pricePerHour: 80,
      );
    },
  )
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
