// import 'dart:isolate';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';
import 'package:provider/provider.dart';

import 'package:sqflite/sqflite.dart';

const DEFAULT_ASCENDING = false;

class HoursProvider with ChangeNotifier {
  static Future /* <List> */ hours;
  Database db;

  Future /* <DayData> */ currentList;
  int _currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  bool _loadingData = true;
  bool _sortAscending = DEFAULT_ASCENDING;

  HoursProvider() {
    hours = getData();
    currentList = hours;
    // print("hours> $currentList");
    this.filterByMonth();

    loadingData = false;
    // getData().then((data) {
    //   hours = data;
    //   notifyListeners();
    // });
  }

  // **********************
  // list and items edition

  editItem(DateTime date, DayData day) async {
    int index = (await hours).indexWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
    hours.then((hours) {
      hours[index] = day;
      notifyListeners();
    });

    this.filterByMonth();

    saveData();
  }

  void deleteItem(DateTime date) async {
    (await hours).removeWhere((hourItem) =>
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

  addNewItem(DayData day) async {
    (await hours).add(day);

    this.filterByMonth();

    notifyListeners();

    saveData();
  }

  sortCurrentListByDay(bool ascending) async {
    print("$ascending");
    // currentList.then((currentList) {
    // if (currentMonth == 0) {
    if (ascending) {
      (await currentList).sort(
        (DayData a, DayData b) => a.date.compareTo(b.date),
      );
    } else {
      (await currentList).sort(
        (DayData b, DayData a) => a.date.compareTo(b.date),
      );
    }
    // ..sort(
    //   (DayData a, DayData b) => a.date.month.compareTo(b.date.month),
    // )
    // ..sort(
    //   (DayData a, DayData b) => a.date.day.compareTo(b.date.day),
    // )
    // } else {
    //   if (ascending) {
    //     (await currentList)
    //         .sort((DayData a, DayData b) => a.date.day.compareTo(b.date.day));
    //   } else {
    //     (await currentList)
    //         .sort((DayData b, DayData a) => a.date.day.compareTo(b.date.day));
    //   }
    // }
    this.sortAscending = ascending;
    notifyListeners();
    // });

    // currentList.sort((a, b) => b.date.day.compareTo(a.date.day));
  }

  /// Edits currentList, making it a list of only the selected month. If the month is 0, it will call the [filterByYear] function.
  filterByMonth([int month]) async {
    if (month == null) {
      month = currentMonth;
    } else {
      currentMonth = month;
    }
    if (month > 0 && month <= 12) {
      loadingData = true;
      currentList = Future.value();

      notifyListeners();

      List list = await hours;
      Map message = {"year": currentYear, "month": month, "list": list};
      Future filteredList = compute(computeCallback, message);
      // List<DayData> filteredList = [];
      // (await hours).forEach((item) => {
      //       if (item.date.month == month && item.date.year == currentYear)
      //         filteredList.add(item)
      //     });
      currentList = filteredList;
      currentList.then((currentList) {
        loadingData = false;
        notifyListeners();
      });
    } else if (month == 0) {
      this.filterByYear().then((value) {
        loadingData = false;
        notifyListeners();
      });
    }
    _sortAscending = DEFAULT_ASCENDING;
    notifyListeners();
  }

  /// Edits currentList, making it a list of the selected year
  filterByYear([int year]) async {
    // var s = Stopwatch()..start();
    if (year != null) {
      currentYear = year;
    } else {
      year = currentYear;
    }

    // currentList = Future.value([]);

    List list = await hours;
    Map message = {"year": year, "list": list};
    print("PEPE");

    loadingData = true;
    currentList = Future.value();

    notifyListeners();

    Future filteredList = compute<Map, List>(computeCallback, message);
    // print("the filteredList ${await filteredList}");

    await filteredList.then((value) async {
      currentList = filteredList;

      _sortAscending = DEFAULT_ASCENDING;
      notifyListeners();

      notifyListeners();
    });

    // await compute/* <String, dynamic> */(
    // (p) => pepe(),
    // pepe,
    // (params) async {
    //   // List<DayData> filteredList = [];
    //   // (await hours).forEach((item) => {
    //   //       if (item.date.year == year) {filteredList.add(item)}
    //   //     });
    //   // currentList.then((currentList) {});
    //   // return filteredList;
    // },
    // "Good"
    // );

    // Isolate.spawn((params) {}, 'Finished');

    // s.stop();
    // print("${s.elapsedMicroseconds}");
  }

  static FutureOr<List> computeCallback(Map message) async {
    // print("v $message");
    List<DayData> filteredList = [];
    // print("m ${message["month"]}");
    if (message["month"] != null) {
      message["list"].forEach((item) => {
            if (item.date.month == message["month"] &&
                item.date.year == message["year"])
              filteredList.add(item)
          });
    } else {
      message["list"].forEach((item) => {
            if (item.date.year == message["year"]) {filteredList.add(item)}
          });
    }
    // (await hours).forEach((item) => {
    //       if (item.date.year == year) {filteredList.add(item)}
    //     });
    return filteredList;
  }

  // **********************
  // getting class info

  Future<DayData> getItem(DateTime date) async {
    return (await hours).firstWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
    // db.rawQuery("SELECT * FROM hours WHERE date == ?").;
  }

  currentListTotal(defaultPrice) {
    double total = 0;
    print("$currentList");
    currentList /* ? */ .then((currentList) {
      for (var item in currentList) {
        total += item.totalHours * (item.pricePerHour ?? defaultPrice ?? 0);
      }
    });
    return total;
  }

  get currentListTotalHours {
    double totalHours = 0;
    currentList?.then((currentList) {
      for (var item in currentList) {
        totalHours += item.totalHours;
      }
    });
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
    hours.then((hours) {
      hours.forEach((item) {
        if (!years.contains(item.date.year)) {
          years.add(item.date.year);
        }
      });
    });
    return years;
  }

  List allMonthsInCurrentYear([year]) {
    // CalendarDatePicker();
    List<int> months = [];
    hours.then((hours) {
      hours.forEach((item) {
        if (item.date.year == (year ?? currentYear)) {
          if (!months.contains(item.date.month)) {
            months.add(item.date.month);
          }
        }
      });
    });
    return months;
  }

  List allDaysInCurrentYearAndMonth([year, month]) {
    List<int> days = [];
    hours.then((hours) {
      hours.forEach((item) {
        if (item.date.year == (year ?? currentYear)) {
          if (item.date.month == (month ?? currentMonth)) {
            if (!days.contains(item.date.day)) {
              days.add(item.date.day);
            }
          }
        }
      });
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

  bool get loadingData => _loadingData;

  set loadingData(bool loadingData) {
    _loadingData = loadingData;

    notifyListeners();
  }

  bool get sortAscending => _sortAscending;

  set sortAscending(bool sortAscending) {
    _sortAscending = sortAscending;

    notifyListeners();
  }

  // **********************
  // data saving/retrieving

  saveItemData(DayData item) async {
    db.insert('hours', {
      "date": item.date,
      "schedule": item.hours,
      "workplace": item.place,
      "pricePerHour": item.pricePerHour,
      // "notes": item.notes
    });
  }

  saveEditedItem(DateTime oldDataItem, DayData item) {
    db.update('hours', {
      "date": item.date,
      "schedule": item.hours,
      "workplace": item.place,
      "pricePerHour": item.pricePerHour,
      // "notes": item.notes
    });
  }

  deleteData(DateTime date) async {
    // String path = await getDatabasesPath();
    db.delete('hours', where: 'date = ?', whereArgs: [date]);
  }

  saveData() async {
    String path = await getDatabasesPath();
  }

  Future<List> getData() async {
    // await instantiateDatabase();
    // List list;
    // try {
    //   list = await db.rawQuery("SELECT * FROM hours");
    // } catch (e) {
    //   print(e);
    // }
    // return list;

    return Future.value(testList);
  }

  instantiateDatabase() async {
    String path = await getDatabasesPath();
    String createdbQuery = "CREATE TABLE hours(" +
        "id INTEGER AUTO_INCREMENT PRIMARY KEY, " +
        "date DATE NOT NULL, " +
        "schedule TEXT NOT NULL, " +
        "workplace TEXT, " +
        "pricePerHour REAL, " +
        "notes TEXT" +
        ")";
    db = await openDatabase(
      '$path/my_db.db',
      version: 1,
      onCreate: (db, version) => db.execute(createdbQuery),
    );
    notifyListeners();

    // db.execute("DROP TABLE hours");
    // db.execute(createdbQuery);

    // db.execute("SELECT * FROM hours");
    List list = await db.rawQuery("SELECT * FROM hours");
    print("db_list $list");
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
    DateTime.parse('2021-01-04'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
      ],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-03'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
      ],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-05'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
      ],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-02'),
    "Newbery",
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
        HoursClass(8, 20),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
        HoursClass(8, 22),
      ],
    ),
  ),
  ...List.generate(
    50,
    (index) {
      if (index == 20)
        return DayData(
          // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
          DateTime.utc(2019, /* index +  */ 1, index + 5),
          "Newbery",
          // Set<HoursClass>.of(
          List<HoursClass>.of(
            [HoursClass(8, 22), HoursClass(8, 22)],
          ),
          pricePerHour: 179,
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
