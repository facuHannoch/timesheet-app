import 'package:flutter/material.dart';
import 'package:hours_tracker/providers/configuration.dart';

import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SetPropertyListTile extends StatefulWidget {
  @override
  _SetPropertyListTileState createState() => _SetPropertyListTileState();
}

class _SetPropertyListTileState extends State<SetPropertyListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).set_hour_price_property_title),
      trailing:
          Text("\$${context.read<ConfigurationProvider>().pricePerHour ?? 0}"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              var controller = TextEditingController();
              return AlertDialog(
                title: Text(
                    AppLocalizations.of(context).set_hour_price_property_title),
                content: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  controller: controller,
                ),
                actions: [
                  FlatButton(
                    child:
                        Text(AppLocalizations.of(context).alert_input_cancel),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child:
                        Text(AppLocalizations.of(context).alert_input_accept),
                    onPressed: () async {
                      context.read<ConfigurationProvider>().pricePerHour =
                          double.tryParse(controller.text) ?? 0;
                          // if the users enters a invalid value (just dots, for example), when we tryParse it, the result will be null. In that case, we will just set the variable to 0 again.
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
