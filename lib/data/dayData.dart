import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// día mes - día (nombre) - horario - lugar - $/hora?
// 2 enero - sabado - 7 a 20 - San Martín
class DayData {
  // int day;
  // int month;
  DateTime date;
  List<HoursClass> hours;
  double pricePerHour;
  String place;
  String notes;

  DayData(
    this.date,
    this.hours, {
    this.place,
    this.pricePerHour,
    this.notes,
  });

  factory DayData.fromMap(Map data) {
    // if (data["date"] == null) {
    //   return null;
    // }
    List<int> dates =
        data["date"].split('-').map<int>((value) => int.parse(value)).toList();
    // the first is the year, the second the month and the third the day
    DateTime date = DateTime.utc(dates[0], dates[1], dates[2]);

    List<HoursClass> schedule = hoursFromString(data["schedule"]);

    return DayData(
      date,
      schedule,
      place: data["workplace"],
      pricePerHour: data["pricePerHour"],
      notes: data["notes"],
    );
  }
  void editItemExceptDate(DayData newVersion) {
    this.hours = newVersion.hours;
    this.place = newVersion.place;
    this.pricePerHour = newVersion.pricePerHour;
    this.notes = newVersion.notes;
  }
  

  static List hoursFromString(String hoursString) {
    List list;
    if (hoursString.contains('-')) {
      list = hoursString.split('-');
    } else {
      // list = [Hours]
      list = [hoursString.substring(0, hoursString.length)];
    }
    list = list.map<HoursClass>((hoursClass) {
      List hour = hoursClass
          .split(',')
          .map((element) => double.parse(element))
          .toList();
      return HoursClass(hour[0], hour[1]);
    }).toList();
    // hours = list;

    return list;
  }

  get hoursAsString {
    List list = hours.map((hoursClass) {
      return hoursClass.asString;
    }).toList();
    return list.join('-');
  }

  get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  // List hours;

  //{
  // [[2, 4], [5, 7]]
  // List
  // }

  String toString() {
    return "$date - $place - $hours - $pricePerHour";
  }

  get totalHours {
    double totalHours = 0;
    hours.forEach((hourPair) {
      totalHours += hourPair.time;
    });
    return totalHours;
  }

  // get hoursAsString {
  //   hours.toString();
  // }

  get day => date.day;

  getDayName(context) {
    int day = date.weekday;
    switch (day) {
      case 1:
        return AppLocalizations.of(context).monday;
      // break;
      case 2:
        return AppLocalizations.of(context).tuesday;
      // break;
      case 3:
        return AppLocalizations.of(context).wednesday;
        break;
      case 4:
        return AppLocalizations.of(context).thursday;
        break;
      case 5:
        return AppLocalizations.of(context).friday;
        break;
      case 6:
        return AppLocalizations.of(context).saturday;
        break;
      case 7:
        return AppLocalizations.of(context).sunday;
        break;
      default:
        return null;
    }
  }

  get month => date.month;

// 1 a 3 - 4 a 5 - 8 a 10
}

class HoursClass {
  double initHour;
  double endHour;

  HoursClass(this.initHour, this.endHour);

  get time => endHour - initHour;
  get asString => "$initHour,$endHour";

  String toString() {
    return "$initHour - $endHour";
  }
}
