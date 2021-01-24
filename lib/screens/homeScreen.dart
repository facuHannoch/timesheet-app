import 'package:flutter/material.dart';
import 'package:hours_tracker/HoursTableScreen.dart';
import 'package:hours_tracker/SettingsScreen.dart';
import 'package:hours_tracker/screens/NewItemScreen.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewItemScreen()));
              }),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())))
        ],
      ),
      body: ListView(
        // DateTable
        children: [
          HoursTableScreen(),
        ],
      ),
    );
  }
}
