import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationProvider with ChangeNotifier {
  int _appPrimaryColor;
  double _pricePerHour;

  ConfigurationProvider({int appPrimaryColor}) {
    this.appPrimaryColor = appPrimaryColor;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      pricePerHour = prefs.getDouble("pricePerHour") ?? 0;
    });
  }

  int get appPrimaryColor => _appPrimaryColor;

  set appPrimaryColor(int appPrimaryColor) {
    _appPrimaryColor = appPrimaryColor;

    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("appPrimaryColor", appPrimaryColor);
    });
  }

  double get pricePerHour => _pricePerHour;

  set pricePerHour(double pricePerHour) {
    _pricePerHour = pricePerHour;

    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble("pricePerHour", pricePerHour);
    });
  }
}
