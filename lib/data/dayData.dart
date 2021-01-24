// día mes - día (nombre) - horario - lugar - $/hora?
// 2 enero - sabado - 7 a 20 - San Martín
class DayData {
  // int day;
  // int month;
  DateTime dayCreated;
  String place;
  List<HoursClass> hours;
  double pricePerHour;

  DayData(
    this.dayCreated,
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
    return "$dayCreated - $place - $hours - $pricePerHour";
  }
  get totalHours {
    double totalHours = 0;
    hours.forEach((hourPair) {
      totalHours += hourPair.time;
    });
    return totalHours;
  }

  get day => dayCreated.day;

  get dayName {
    int day = dayCreated.weekday;
    switch (day) {
      case 1:
        return "Lunes";
      // break;
      case 2:
        return "Martes";
      // break;
      case 3:
        return "Miércoles";
        break;
      case 4:
        return "Jueves";
        break;
      case 5:
        return "Viernes";
        break;
      case 6:
        return "Sábado";
        break;
      case 7:
        return "Domingo";
        break;
      default:
        return null;
    }
  }

  get month => dayCreated.month;

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
