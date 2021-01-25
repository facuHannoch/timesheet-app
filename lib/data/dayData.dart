import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// día mes - día (nombre) - horario - lugar - $/hora?
// 2 enero - sabado - 7 a 20 - San Martín
class DayData {
  // int day;
  // int month;
  DateTime date;
  String place;
  List<HoursClass> hours;
  double pricePerHour;

  DayData(
    this.date,
    this.place,
    this.hours, {
    this.pricePerHour,
  });
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

  String toString() {
    return "$initHour - $endHour";
  }
}
