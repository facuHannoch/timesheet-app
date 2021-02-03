import 'package:flutter/material.dart';
import 'package:timesheet/providers/configuration.dart';
import 'package:timesheet/widgets/SetPropertyListTile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// import 'providers/CustomProvider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final String appTitle;

  const SettingsScreen({this.appTitle = "", Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings_screen_title),
      ),
      body: ListView(
        children: <Widget>[
          SetPropertyListTile(),
          ListTile(
            title: Text(AppLocalizations.of(context).choose_primary_color),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title:
                      Text(AppLocalizations.of(context).choose_primary_color),
                  content: Container(
                    height: 300,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      children: [
                        Colors.blueGrey,
                        Colors.red,
                        Colors.black,
                        Colors.amber,
                        Colors.green,
                        Colors.blue,
                        Colors.blueAccent,
                        Colors.grey,
                        Colors.lime,
                        Colors.tealAccent,
                        Colors.cyan,
                        Colors.brown,
                        Colors.pinkAccent,
                        Colors.purple,
                      ].map<Widget>(
                        (color) {
                          return Container(
                            height: 30,
                            width: 30,
                            child: RaisedButton(
                              color: color,
                              onPressed: () async {
                                context.read<ConfigurationProvider>().appPrimaryColor = color.value;
                                // SharedPreferences prefs =
                                //     await SharedPreferences.getInstance();
                                // await prefs.setInt(
                                //     "appPrimaryColor", color.value);
                                // Provider.of<CustomProvider>(context,
                                //         listen: false)
                                //     .changeColor(color.value);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context).visit_our_website),
            subtitle: Text(
                AppLocalizations.of(context).visit_our_website_description),
            onTap: () => _launchUrl("https://appneft.vercel.app/"),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).give_feedback),
            subtitle: Text(AppLocalizations.of(context).give_feedback_description),
            onTap: () async {
              // http.get();
              Email email = Email(
                subject: "Timesheet",
                recipients: ["contact.appneft@gmail.com"],
                isHTML: false,
              );
              await FlutterEmailSender.send(email);
            },
          ),
          Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context).follow_us_instagram),
            subtitle: Text(
                AppLocalizations.of(context).follow_us_instagram_description),
            onTap: () => _launchUrl("https://www.instagram.com/appneft/"),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).follow_us_facebook),
            subtitle: Text(
                AppLocalizations.of(context).follow_us_facebook_description),
            onTap: () => _launchUrl("https://www.facebook.com/appneft"),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).follow_us_twitter),
            subtitle: Text(
                AppLocalizations.of(context).follow_us_twitter_description),
            onTap: () => _launchUrl("https://twitter.com/appneft"),
          ),
        ],
      ),
    );
  }

  // void _launchMobileWebsite() async {
  //   String url = "https://thebestapps.vercel.app/";
  //   var response = await http.get("localhost:8000/mobile-page-url");
  //   if (response.statusCode == 200) {
  //     url = jsonDecode(response.body);
  //   }
  //   _launchUrl(url);
  // }
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
