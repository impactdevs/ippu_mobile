
import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  late bool _status;
  bool get status => _status;

  void setSubscriptionStatus(bool status) {
    _status = status;
    notifyListeners();
  }
}