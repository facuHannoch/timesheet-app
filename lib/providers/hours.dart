// import 'dart:isolate';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hours_tracker/data/dayData.dart';
import 'package:provider/provider.dart';

import 'package:sqflite/sqflite.dart';

const DEFAULT_ASCENDING = false;

class HoursProvider with ChangeNotifier {
  Future<List> /* <List> */ hours = Future.value([]);
  Database db;

  List /* <DayData> */ currentList = [];
  int _currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  bool _loadingData = true;
  bool _sortAscending = DEFAULT_ASCENDING;

  HoursProvider() {
    hours = getData();
    hours.then((value) {
      currentList = value;
      this.filterByMonth();

      loadingData = false;
    }).catchError((error) {
      print("error");
      print(error);
      loadingData = false;
      hours = Future.value([]);
    });
    // getData().then((data) {
    //   hours = data;
    //   notifyListeners();
    // });
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
    // await hours.then((List hours) {
    //   print("hours $hours");
    //   print("day $day");
    //   List<DayData> list = []..add(DayData(day.date, day.place, day.hours));
    //   print("list $list");
    //   hours = list;
    //   hours = [day];
    //   print("hours d $hours");
    //   notifyListeners();
    // });
    notifyListeners();

    // print("hours dd ${await hours}");
    this.filterByMonth();

    // saveData();
    saveItemData(day);
  }

  sortCurrentListByDay(bool ascending) async {
    print("$ascending");
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
    // print("the filteredList ${await filteredList}");

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

    // s.stop();
    // print("${s.elapsedMicroseconds}");
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
    // return DayData(DateTime.now(), [HoursClass(4, 5)]);
    return (await hours)?.firstWhere((item) =>
        item.date.year == date.year &&
        item.date.month == date.month &&
        item.date.day == date.day);
    // db.rawQuery("SELECT * FROM hours WHERE date == ?").;
  }

  currentListTotal(defaultPrice) {
    double total = 0;
    // currentList?.then((currentList) {
    for (var item in currentList) {
      total += item.totalHours * (item.pricePerHour ?? defaultPrice ?? 0);
    }
    // });
    return total;
  }

  get currentListTotalHours {
    double totalHours = 0;
    // currentList?.then((currentList) {
    for (var item in currentList) {
      totalHours += item.totalHours;
    }
    // });
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
    // String stringDate =
    //     "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}";
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
    // update hours
// set date = date("2021-01-28"), schedule = "PEPE, 2", workplace = "String", priceperhour = 50, notes = "house"
// where date = date("2021-01-28");
  }

  deleteData(DateTime date) async {
    // String path = await getDatabasesPath();
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // db.execute("BEGIN TRANSACTION");
    // db.execute("DELETE FROM hours WHERE date = DATE(\"2021-01-03\")");
    // db.execute("COMMIT");

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

  saveData() async {
    String path = await getDatabasesPath();
  }

  Future<List> getData() async {
    await instantiateDatabase();
    List<Map> list;
    try {
      list = (await db.rawQuery("SELECT * FROM hours"));
    } catch (e) {
      print(e);
    }

    // print(list);

    // List<DayData> dataList =
    //     list.map((registry) => DayData.fromMap(registry)).toList();

    List<DayData> dataList = [];
    list.forEach((registry) {
      if (registry["date"] != null) {
        dataList.add(DayData.fromMap(registry));
      }
    });

    return dataList;

    return Future.value(testList);
  }

  instantiateDatabase() async {
    String path = await getDatabasesPath();
    // String createdbQuery = "CREATE TABLE hours(" +
    //     "id INTEGER AUTO_INCREMENT PRIMARY KEY, " +
    //     "date DATE NOT NULL, " +
    //     "schedule TEXT NOT NULL, " +
    //     "workplace TEXT, " +
    //     "pricePerHour REAL, " +
    //     "notes TEXT" +
    //     ")";
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

    for (var a = 0; a < 100; a++) {
      for (var j = 0; j < 12; j++) {
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
    List list = await db.rawQuery("SELECT * FROM hours");
  }
}

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
