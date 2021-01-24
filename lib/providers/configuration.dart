import 'package:flutter/material.dart';

class ConfigurationProvider with ChangeNotifier {
  int appPrimaryColor;

  ConfigurationProvider({int appPrimaryColor}) {
    this.appPrimaryColor = appPrimaryColor;
  }
}