import 'package:flutter/material.dart';
import 'package:ippu/models/Profile.dart';

class UserProfile extends ChangeNotifier {
  Profile? _profile;
  Profile? get profile => _profile;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }
}
