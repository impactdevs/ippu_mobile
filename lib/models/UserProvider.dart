import 'package:flutter/material.dart';
import 'package:ippu/models/UserData.dart';

class UserProvider extends ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  // cpds
  int? totalCPDS = 0;
  int? get CPDS => totalCPDS;
  //

  String? checkRegistration;
  String? get registrationStatus => checkRegistration;
  //

  // events
   int? totalEvents = 0;
  int? get events => totalEvents;
  //
  // points from events
  int? PointsFromEvents = 0;
  int? get EventsPoints => PointsFromEvents;
  //
  // points from events
  int? totalJobs = 0;
  int? get getTotalJobs => totalJobs;
  //
  //
  String? eventsLinkImage;
  String? get getLinkImage => eventsLinkImage;
  //

  String? subscription;
  String? get getSubscriptionStatus => subscription;
  //
  // points from cpds
  int? PointsFromCpd = 0;
  int? get CpdPoints => PointsFromCpd;
  //
  // communication
  int? totalCommunications = 0;
  int? get communications => totalCommunications;

  int? unreadCommunications = 0;
  int? get unreadCommunicationsCount => unreadCommunications;

  // cpds
  int? attendedCpds = 0;
  int? get attendedCpd => attendedCpds;
  //
  //
  bool? profileStatus;
  bool? get profileStatusCheck => profileStatus;
  //
  void setProfileStatus(bool status) {
    profileStatus = status;
    notifyListeners();
  }

  //
  void setUser(UserData userData) {
    _user = userData;
    notifyListeners();
  }

    void updateProfilePic(String profilePicUrl) {
    if (_user != null) {
      _user!.profile_pic = profilePicUrl;
      notifyListeners();
    }
  }

  // fetching total number of cpds
  void totalNumberOfCPDS(int cpds) {
    totalCPDS = cpds;
    notifyListeners();
  }

  // fetching total number of attended cpds
  void totalNumberOfAttendedCpds(int attended) {
    attendedCpds = attended;
  }

  // fetching subscription status
  void setSubscriptionStatus(String status) {
    subscription = status;
  }
  // fetching subscription status

  // fetching total number of communications
  void totalNumberOfCommunications(int communication) {
    totalCommunications = communication;
    notifyListeners();
  }
  // fetching total number of events

  // fetching total number of events
  void totalNumberOfEvents(int events) {
    totalEvents = events;
    notifyListeners();
  }

  // check registration status
  void registrationStatusSetFunction(String status) {
    eventsLinkImage = status;
    notifyListeners();
  }

  // fetching total number of events
  void totalNumberOfPointsFromEvents(int eventPoints) {
    PointsFromEvents = eventPoints;
  }

  // fetching totla number of jobs
  void fetchTotalJobs(int eventPoints) {
    totalJobs = eventPoints;
  }

  // fetching total number of events
  void totalNumberOfPointsFromCpd(int eventPoints) {
    PointsFromCpd = eventPoints;
  }

  void setLinkImage(String eventPoints) {
    eventsLinkImage = eventPoints;
  }

  //update name
  void updateName(String name) {
    if (_user != null) {
      _user!.name = name;
      notifyListeners();
    }
  }
}
