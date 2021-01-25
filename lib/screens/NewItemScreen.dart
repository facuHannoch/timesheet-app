import 'package:flutter/material.dart';
import 'package:hours_tracker/data/dayData.dart';
import 'package:hours_tracker/providers/configuration.dart';
import 'package:hours_tracker/providers/hours.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

// extension on DateTime {
//   bool isEqual(DateTime other) {
//     return this.year == other.year &&
//         this.month == other.month &&
//         this.day == other.day;
//   }
// }

class NewItemScreen extends StatefulWidget {
  @override
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  // TextEditingController _dayController = TextEditingController();
  TextEditingController _placeController = TextEditingController();
  // TextEditingController _hoursController = TextEditingController();
  TextEditingController _pricePerHourController = TextEditingController();

  GlobalKey<FormState> _formState = GlobalKey<FormState>();

  DateTime date = DateTime.now();
  List<List<double>> hoursList = [
    // [/* 2, 3 */]
    [0, 0]
  ];

  // to make sure the user doesn't create two items with the same date, we'll have three booleans, which will be used to checked the if the year, month and day match with an existing item.
  // we will only say to the user that they have to choose another date if the three variables are set to true at the time of submiting
  bool yearTaken = false;
  bool monthTaken = false;
  bool dayTaken = false;

  @override
  Widget build(BuildContext context) {
    int i = -1;
    int maxDay = 31;
    if ([4, 6, 9, 11].contains(date.month)) {
      maxDay = 30;
    } else if ([1, 3, 5, 7, 8, 10, 12].contains(date.month)) {
      maxDay = 31;
    } else if (date.month == 2) {
      if (date.year % 4 == 0) {
        maxDay = 29;
      } else {
        maxDay = 28;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).new_item_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.end,
              // mainAxisSize: MainAxisSize.min,
              children: [
                InputsDescription(
                  title: AppLocalizations.of(context).new_item_date_label_title,
                  // description: "Date format: yyyy-mm-dd",
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DropdownButton(
                        value: date.day,
                        onChanged: (newValue) {
                          setState(() {
                            date =
                                DateTime.utc(date.year, date.month, newValue);
                            if (context
                                .read<HoursProvider>()
                                .allDaysInCurrentYearAndMonth(
                                    date.year, date.month)
                                .contains(newValue)) {
                              dayTaken = true;
                            }
                            // maxDay = 0;
                            // date = newValue;
                          });
                        },
                        items: List.generate(
                          maxDay,
                          (index) => DropdownMenuItem(
                            child: Text((index + 1).toString()),
                            value: index + 1,
                          ),
                        ),
                      ),
                      DropdownButton(
                          value: date.month,
                          onChanged: (newValue) {
                            setState(() {
                              date =
                                  DateTime.utc(date.year, newValue, date.day);
                              if (context
                                  .read<HoursProvider>()
                                  .allMonthsInCurrentYear(date.year)
                                  .contains(newValue)) {
                                monthTaken = true;
                              }

                              // date.month = newValue;
                            });
                          },
                          items: List.generate(
                            12,
                            (index) => DropdownMenuItem(
                              child: Text((index + 1).toString()),
                              value: index + 1,
                            ),
                          )),
                      DropdownButton(
                          value: date.year,
                          onChanged: (newValue) {
                            setState(() {
                              date =
                                  DateTime.utc(newValue, date.month, date.day);
                              if (context
                                  .read<HoursProvider>()
                                  .allYears
                                  .contains(newValue)) {
                                yearTaken = true;
                              }

                              // date.month = newValue;
                            });
                          },
                          items: List.generate(
                            DateTime.now().year - 1900,
                            (index) {
                              return DropdownMenuItem(
                                child: Text(
                                    (DateTime.now().year - index).toString()),
                                value: DateTime.now().year - index,
                              );
                            },
                          ))
                    ]),
                // TextFormField(
                //   controller: _dayController,
                //   keyboardType: TextInputType.datetime,
                //   decoration: InputDecoration(
                //     labelText: "yyyy-mm-dd",
                //     floatingLabelBehavior: FloatingLabelBehavior.never,
                //   ),
                //   validator: (value) {
                //     if (DateTime.tryParse(value) == null)
                //       return "Date format is not correct";
                //     return null;
                //   },
                // ),
                InputsDescription(
                  title:
                      AppLocalizations.of(context).new_item_place_label_title,
                  // description: "Can be empty",
                ),
                TextFormField(
                  controller: _placeController,
                  decoration: InputDecoration(labelText: ""),
                  maxLength: 80,
                ),
                InputsDescription(
                  title:
                      AppLocalizations.of(context).new_item_hours_label_title,
                  // description: "The number of hours",
                ),
                // (for (var i = 0; i < count; i++) {
                //   return Text("");
                // }),
                // AnimatedList(
                //   initialItemCount: hoursList.length,
                //   itemBuilder: (context, index, animation) {
                ...hoursList.map<Row>(
                  (hoursPair) {
                    i++;
                    // print("hoursList ${hoursList.length}");
                    // print("i $i");
                    return Row(
                      // key: Key(i.toString()),
                      children: <Widget>[
                        Container(
                          width: 100,
                          child: TextFormField(
                            // controller: _hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .hours_input_start_hour_label),
                            validator: (value) {
                              double hour = double.tryParse(value);
                              if (hour == null)
                                return AppLocalizations.of(context)
                                    .hours_input_is_not_number_label;
                              if (hour > 24)
                                return AppLocalizations.of(context)
                                    .hours_input_max_24_label;
                              if (hour < 0)
                                return AppLocalizations.of(context)
                                    .hours_input_min_0_label;
                              return null;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                if (!hoursList[i][0].isNaN)
                                  hoursList[i]?.removeAt(0);
                                hoursList[i]
                                    .insert(0, double.parse(newValue) ?? 0);
                              });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(" - "),
                        ),
                        Container(
                          width: 100,
                          child: TextFormField(
                            // controller: _hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .hours_input_end_hour_label),
                            validator: (value) {
                              double hour = double.tryParse(value);
                              if (hour == null)
                                return AppLocalizations.of(context)
                                    .hours_input_is_not_number_label;
                              if (hour > 24)
                                return AppLocalizations.of(context)
                                    .hours_input_max_24_label;
                              if (hour < 0)
                                return AppLocalizations.of(context)
                                    .hours_input_min_0_label;
                              return null;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                if (!hoursList[i][1].isNaN)
                                  hoursList[i]?.removeAt(1);
                                hoursList[i]
                                    .insert(1, double.tryParse(newValue) ?? 0);
                              });
                            },
                          ),
                        ),
                        hoursList.length - 1 == i
                            ? IconButton(
                                icon: Icon(Icons.add),
                                // if the button has been already used to create a new list of hours, we'll disable that button.
                                onPressed:
                                    // hoursList.length <= i
                                    hoursList[i].isEmpty
                                        ? null
                                        : () {
                                            setState(() {
                                              // hoursList.insert(i + 1, [0, 0]);
                                              hoursList.add([0, 0]);
                                            });
                                          },
                              )
                            : SizedBox(),
                        hoursList.length - 1 == i
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: i == 0
                                    ? null
                                    : () {
                                        setState(() {
                                          hoursList.removeAt(i);
                                        });
                                      })
                            : SizedBox()
                      ],
                    );
                    //   },
                    // ).toList();
                  },
                ),
                InputsDescription(
                  title: AppLocalizations.of(context)
                      .new_item_price_per_hour_label_title,
                  // description: "(optional)",
                ),
                TextFormField(
                  controller: _pricePerHourController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: ""),
                  validator: (value) {
                    // if (value.replaceAll(' ', '') == '')
                    //   return "This field must not be empty";
                    print(value.runtimeType);
                    print("coso $value");
                    if (/* value != null ||  */ value != '') {
                      if (double.tryParse(value) == null)
                        return AppLocalizations.of(context)
                            .hour_price_is_not_number_label;
                    }
                    return null;
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                        // if (states.contains(MaterialState.pressed))
                        // return Theme.of(context).primaryColor.withOpacity(0);
                        return Theme.of(context).primaryColor;
                      })
                          // backgroundColor: ,
                          ),
                      child:
                          Text(AppLocalizations.of(context).submit_form_button),
                      onPressed: () {
                        // we checked the value a last time in case the user didn't change one value, and so it wouldn't have triggered the checked
                        if (context
                            .read<HoursProvider>()
                            .allDaysInCurrentYearAndMonth(date.year, date.month)
                            .contains(date.day)) {
                          dayTaken = true;
                        }
                        if (context
                            .read<HoursProvider>()
                            .allMonthsInCurrentYear(date.year)
                            .contains(date.month)) {
                          monthTaken = true;
                        }
                        if (context
                            .read<HoursProvider>()
                            .allYears
                            .contains(date.year)) {
                          yearTaken = true;
                        }

                        print("\n\n\n");
                        print("daytaken $dayTaken");
                        print("monthTaken $monthTaken");
                        print("yearTaken $yearTaken");
                        print("date $date");
                        print("\n\n\n");
                        // if (context
                        //     .read<HoursProvider>()
                        //     .hours
                        //     .contains(date)) {
                        if (yearTaken && monthTaken && dayTaken) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text(
                                  "There is already an item with that date created."),
                              actions: [
                                FlatButton(
                                  child: Text(AppLocalizations.of(context)
                                      .alert_input_accept),
                                  onPressed: () => Navigator.pop(context),
                                  color: Theme.of(context).primaryColor,
                                )
                              ],
                            ),
                          );
                        } else if (_formState.currentState.validate()) {
                          print("list $hoursList");

                          // DateTime date = _dayController.text == null
                          //     ? DateTime.now()
                          //     : DateTime.tryParse(_dayController.text);
                          DateTime hourDate = date;

                          String place =
                              _placeController.text.replaceAll(' ', '') == ''
                                  ? null
                                  : _placeController?.text;

                          List<HoursClass> hours =
                              hoursList.map<HoursClass>((hours) {
                            return HoursClass(hours[0], hours[1]);
                          }).toList();

                          double pricePerHour =
                              double.tryParse(_pricePerHourController.text) ??
                                  context
                                      .read<ConfigurationProvider>()
                                      .pricePerHour;

                          DayData item = DayData(
                            hourDate,
                            place,
                            hours,
                            pricePerHour: pricePerHour,
                          );

                          print("item $item");
                          context.read<HoursProvider>().addNewItem(item);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputsDescription extends StatelessWidget {
  final String title;
  final String description;

  const InputsDescription({
    Key key,
    @required this.title /*  = "" */,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(title,
              style: Theme.of(context).textTheme.headline5.apply(
                    color: Theme.of(context).primaryColor,
                  )),
          SizedBox(height: description == null ? 0 : 5),
          (description != null
              ? Text(description)
              : SizedBox(
                  height: 0,
                ))
        ],
      ),
    );
  }
}
