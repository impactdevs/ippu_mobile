import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Screens/SettingsScreen.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/CalendarScreen.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/FirstDisplaySection.dart';
import 'package:ippu/models/UserData.dart';
import 'package:provider/provider.dart';
//import http package
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkProfileStatus(UserData user) async {
    if (user.gender == null &&
        user.dob == null &&
        user.membership_number == null &&
        user.address == null &&
        user.phone_no == null &&
        user.nok_name == null &&
        user.nok_phone_no == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var url = context.watch<ProfilePicProvider>().profilePic;
    //split the url using / and get the last element,
    var lastElement = url.split('/').last;

    //network url, if the last element is profiles, put default image
    var networkUrl = lastElement == 'profiles'
        ? 'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png'
        : url;
    return Scaffold(
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CalendarScreen();
              }));
            },
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const CalendarScreen();
                }));
              },
              child: Padding(
                padding: EdgeInsets.only(right: size.width * 0.06),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 30
                )
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SettingsScreen();
              }));
            },
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ProfileScreen();
                }));
              },
              child: Padding(
                padding: EdgeInsets.only(right: size.width * 0.06),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      networkUrl),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: const Column(
        children: [
          FirstDisplaySection(),
        ],
      ),
    );
  }


  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
  //
}

class ProfileData {
  final Map<String, dynamic> data;

  ProfileData({required this.data});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(data: json['data']);
  }
}
