
import 'package:flutter/material.dart';

class SubscriptionStatusProvider extends ChangeNotifier {
  late String _status;
  String get status => _status;

  void setSubscriptionStatus(String status) {
    _status = status;
    notifyListeners();
  }
}