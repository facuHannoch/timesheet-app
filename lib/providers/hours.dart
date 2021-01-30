// import 'dart:isolate';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';

import 'package:admob_flutter/admob_flutter.dart';

import 'package:sqflite/sqflite.dart';

const DEFAULT_ASCENDING = false;

const ACTIONS_WITHOUT_ADS = 7;
const EXPORTS_WITHOUT_ADS = 3;

class HoursProvider with ChangeNotifier {
  Future<List> /* <List> */ hours = Future.value([]);
  Database db;

  List /* <DayData> */ currentList = [];
  int _currentMonth = DateTime.now().month;
  int currentYear;

  List listYears;

  bool _loadingData = true;
  bool _sortAscending = DEFAULT_ASCENDING;

  AdmobInterstitial actionsInterstitial;
  AdmobInterstitial exportInterstitial;
  int actions = 0;
  int exports = 0;

  HoursProvider() {
    hours = getData();
    hours.then((value) {
      currentList = value;
      this.filterByMonth();

      loadingData = false;
    }).catchError((error) {
      // print("error");
      // print(error);
      loadingData = false;
      // hours = Future.value([]);
    });
    allYears.then((allYears) {
      // we have to intialize the value right now so we can use it.
      currentYear = DateTime.now().year;

      listYears = allYears;

      // it is possible that the user has just created items in years which are not the currentOne. In that case we want to add that year to the list of year that will go in the DropdownButton.
      // If we don't include this, the value of DropdownButton will be set to year that it is not in the list of values provided to the DropdownMenuItems, which will throw an error.
      if (!listYears.contains(currentYear)) {
        listYears.insert(0, currentYear);
      }
      listYears.sort();
    });
    actionsInterstitial = AdmobInterstitial(
        adUnitId: AdmobInterstitial.testAdUnitId,
        listener: (AdmobAdEvent event, Map args) {
          if (event == AdmobAdEvent.closed) {
            actionsInterstitial.load();
          }
        });
    exportInterstitial = AdmobInterstitial(
        adUnitId: AdmobInterstitial.testAdUnitId,
        listener: (AdmobAdEvent event, Map args) {
          if (event == AdmobAdEvent.closed) {
            exportInterstitial.load();
          }
        });
    actionsInterstitial.load();
    exportInterstitial.load();

    // getData().then((data) {
    //   hours = data;
    //   notifyListeners();
    // });
  }

  // **********************
  // ads related stuff

  showInterstitial({export = false}) async {
    if (export) {
      if (await exportInterstitial.isLoaded &&
          (exports == 0 || exports % EXPORTS_WITHOUT_ADS == 0)) {
        exportInterstitial.show();
        exports = 0;
      } else {
        exports++;
      }
    } else {
      // it is very likely that the user just adds one record and then closes doen't create any more until he re-open the app.
      if (await actionsInterstitial.isLoaded &&
          (actions == 0 || actions > ACTIONS_WITHOUT_ADS)) {
        actionsInterstitial.show();
        actions = 1;
      } else {
        actions++;
      }
    }
  }

  disposeInterstitials() {
    actionsInterstitial.dispose();
    exportInterstitial.dispose();
  }

  // **********************
  // list and items edition

  editItem(DateTime oldDate, DayData day) async {
    int index = (await hours).indexWhere((item) =>
        item.date.year == oldDate.year &&
        item.date.month == oldDate.month &&
        item.date.day == oldDate.day);
    hours.then((hours) {
      // hours[index] = day;
      hours[index].editItemExceptDate(day);
      notifyListeners();
    });

    this.filterByMonth();

    saveEditedItem(oldDate, day);
  }

  void deleteItem(DateTime date) async {
    (await hours).removeWhere((hourItem) =>
        hourItem.date.year == date.year &&
        hourItem.date.month == date.month &&
        hourItem.date.day == date.day);

    // we get the new current list by calling the method again
    this.filterByMonth();

    notifyListeners();
    // saveData();
    deleteData(date);
  }

  // **********************
  // data management

  addNewItem(DayData day) async {
    hours.then(
      (List list) => (list /*  as List<DayData> */).add(day),
    );

    if (!listYears.contains(day.date.year)) {
      listYears.add(day.date.year);
      listYears.sort();
    }

    notifyListeners();

    this.filterByMonth();

    saveItemData(day);
  }

  sortCurrentListByDay(bool ascending) async {
    // currentList.then((currentList) {
    // if (currentMonth == 0) {
    if (ascending) {
      (currentList).sort((a, b) => a.date.compareTo(b.date));
      // (currentList).sort((DayData a, DayData b) => a.date.compareTo(b.date));
    } else {
      (currentList).sort(
        (b, a) => a.date.compareTo(b.date),
        // (DayData b, DayData a) => a.date.compareTo(b.date),
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
      currentList = [];

      notifyListeners();

      List list = await hours;
      Map message = {"year": currentYear, "month": month, "list": list};
      Future filteredList = compute(computeCallback, message);
      // List<DayData> filteredList = [];
      // (await hours).forEach((item) => {
      //       if (item.date.month == month && item.date.year == currentYear)
      //         filteredList.add(item)
      //     });
      currentList = await filteredList;
      // currentList.then((currentList) {
      loadingData = false;
      notifyListeners();
      // });
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

    loadingData = true;
    // currentList = Future.value();
    currentList = [];

    notifyListeners();

    Future filteredList = compute<Map, List>(computeCallback, message);

    await filteredList.then((value) async {
      currentList = await filteredList;

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
  }

  static FutureOr<List> computeCallback(Map message) async {
    List<DayData> filteredList = [];
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
    return (await hours)?.firstWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
    // db.rawQuery("SELECT * FROM hours WHERE date == ?").;
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

  // List get allYearsSync {
  //   List<int> years = [];
  //   hours.then((hours) {
  //     hours.forEach((item) {
  //       if (!years.contains(item.date.year)) {
  //         years.add(item.date.year);
  //       }
  //     });
  //   });
  //   return years;
  // }

  Future<List> get allYears async {
    List<int> years = [];
    (await hours).forEach((item) {
      if (!years.contains(item.date.year)) {
        years.add(item.date.year);
      }
    });
    return years;
  }

  Future<List> allMonthsInCurrentYear([int year]) async {
    // CalendarDatePicker();
    List<int> months = [];
    // hours.then((hours) {
    (await hours).forEach((item) {
      if (item.date.year == (year ?? currentYear)) {
        if (!months.contains(item.date.month)) {
          months.add(item.date.month);
        }
      }
    });
    // });
    return months;
  }

  Future<List> allDaysInCurrentYearAndMonth([int year, int month]) async {
    List<int> days = [];
    (await hours).forEach((item) {
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
    // DateTime date = item.formattedDate;
    db.insert('hours', {
      // "date": "date(${item.date.year} - ${item.date.month} - ${item.date.day})",
      // "date": "date(\"${item.formattedDate}\")",
      "date": "${item.formattedDate}",
      "schedule": item.hoursAsString,
      "workplace": item.place,
      "pricePerHour": item.pricePerHour,
      "notes": item.notes
    });
  }

  saveEditedItem(DateTime oldDataItem, DayData item) {
    db.update(
        'hours',
        {
          // "date": "date('${item.formattedDate}')",
          "schedule": item.hoursAsString,
          "workplace": item.place,
          "pricePerHour": item.pricePerHour,
          "notes": item.notes
        },
        where: "date = \"${item.formattedDate}\""
        // "date = \"date(${item.date.year} - ${item.date.month} - ${item.date.day})\"",
        );
  }

  deleteData(DateTime date) async {
    // String path = await getDatabasesPath();
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // db.execute("DELETE FROM hours WHERE date = DATE(\"$formattedDate\")");

    db.execute("BEGIN TRANSACTION");
    db
        .delete(
      'hours',
      where: 'date = DATE(\"$formattedDate\")',
      // whereArgs: ["DATE(\"2021-01-01\")"]
    )
        .then((rowsAffected) {
      if (rowsAffected != 1) {
        db.execute("ROLLBACK");
      } else {
        db.execute("COMMIT");
      }
    });

    // db.transaction((txn) {
    //   return txn.delete('hours',
    //       where: 'date = ?',
    //       whereArgs: ["date('$formattedDate')"]).then((rowsAffected) {
    //     if (rowsAffected != 1) {
    //       txn.execute("ROLLBACK");
    //     } else {
    //       txn.execute("COMMIT");
    //     }
    //   });
    // });
    // db.delete('hours', where: 'date = ?', whereArgs: ["date('$formattedData')"]).then((value) {

    // });
  }

  // saveData() async {
  //   String path = await getDatabasesPath();
  // }

  Future<List> getData() async {
    await instantiateDatabase();
    List<Map> list;
    try {
      list = (await db.rawQuery("SELECT * FROM hours"));
    } catch (e) {
      print(e);
    }

    // List<DayData> dataList =
    //     list.map((registry) => DayData.fromMap(registry)).toList();

    List<DayData> dataList = [];
    // In the test done, sometimes a null date was obtained. Ideally this won't happen in production. But if it does, it is better to lost that one registry than crash the entire application, so we just don't add it to the list.
    list.forEach((registry) {
      if (registry["date"] != null) {
        dataList.add(DayData.fromMap(registry));
      }
    });

    return dataList;

    // return Future.value(testList);
  }

  instantiateDatabase() async {
    String path = await getDatabasesPath();
    String createdbQuery = """
    CREATE TABLE hours(
      date DATE PRIMARY KEY, 
      schedule TEXT NOT NULL,
      workplace TEXT, 
      pricePerHour REAL, 
      notes TEXT
    ); """;
    db = await openDatabase(
      '$path/my_db.db',
      version: 1,
      onCreate: (db, version) => db.execute(createdbQuery),
    );
    notifyListeners();
/*
    db.execute("DROP TABLE hours");
    db.execute(createdbQuery);

    for (var a = 0; a < 1; a++) {
      for (var j = 0; j < 1; j++) {
        for (var i = 0; i < (j == 2 ? 28 : 30); i++) {
          String insertData = """
    INSERT into hours (date, schedule, workplace, notes)
    VALUES(
      date("2${a.toString().padLeft(3, '0')}-${(j + 1).toString().padLeft(2, '0')}-${(i + 1).toString().padLeft(2, '0')}"),
      "2,5",
      "Workplace",
      
      "You can even write notes for each day. This notes can be quite large (Up to 300 characters! That is a lot of characters. I wonder if anyone could use so many characters)"
    );""";
          db.execute(insertData);
        }
      }
    }
*/
    // List list = await db.rawQuery("SELECT * FROM hours");
  }
}
/*
List<DayData> testList = [
  DayData(
    DateTime.parse('2020-03-20'),
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [HoursClass(8, 22)],
    ),
    place: "Newbery",
  ),
  DayData(
      DateTime.parse('2019-03-20'),
      // Set<HoursClass>.of(
      List<HoursClass>.of(
        [HoursClass(8, 22)],
      ),
      notes: """maxLines: 5,
                  maxLength: 250,
                  maxLengthEnforced: true,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                      labelText: AppLocalizatio"""),
  DayData(
    DateTime.parse('2021-01-04'),
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
      ],
    ),
  ),
  DayData(
      DateTime.parse('2021-01-03'),
      // Set<HoursClass>.of(
      List<HoursClass>.of(
        [
          HoursClass(8, 22),
        ],
      ),
      notes: "A very good note to put in every thing that you want"),
  DayData(
    DateTime.parse('2021-01-05'),
    // Set<HoursClass>.of(
    List<HoursClass>.of(
      [
        HoursClass(8, 22),
      ],
    ),
  ),
  DayData(
    DateTime.parse('2021-01-02'),
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
    5000,
    (index) {
      if (index == 20)
        return DayData(
          // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
          DateTime.utc(2019, /* index +  */ 1, index + 5),
          // Set<HoursClass>.of(
          List<HoursClass>.of(
            [HoursClass(8, 22), HoursClass(8, 22)],
          ),
          pricePerHour: 179,
        );
      return DayData(
          // DateTime.parse('${index+1900}-${index+1}-${index+1}'),
          DateTime.utc(2021, /* index +  */ 1, index + 1),
          // Set<HoursClass>.of(
          List<HoursClass>.of(
            [HoursClass(8, 22)],
          ),
          pricePerHour: 80,
          place: "Newbery",
          notes:
              "A very good note to put in every thing that you want. You cant put everything here!");
    },
  )
];
/*
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
*/
*/
