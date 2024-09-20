import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ippu/Screens/CpdsScreen.dart';
import 'package:ippu/models/CpdModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class allCpdDisplay extends StatefulWidget {
  const allCpdDisplay({super.key});

  @override
  State<allCpdDisplay> createState() => _allCpdDisplayState();
}

class _allCpdDisplayState extends State<allCpdDisplay> {
  late Future<List<CpdModel>> dataFuture;
  late List<CpdModel> fetchedData = []; // Declare a list to store fetched data
  int totalCpdPoints = 0;
  @override
  void initState() {
    super.initState();
    // Assign the result of fetchdata to the fetchedData list
    dataFuture = fetchAllCpds().then((data) {
      fetchedData = data;
      for (final cpd in fetchedData) {
        int? points = int.tryParse(cpd.points);
        if (points != null) {
          totalCpdPoints += points;
        }
      }
      return data;
    });
    dataFuture = fetchAllCpds();
  }

  // function for fetching cpds
  Future<List<CpdModel>> fetchAllCpds() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/cpds/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];
        List<CpdModel> cpdData = eventData.map((item) {
          return CpdModel(
            //
            id: item['id'].toString(),
            code: item['code'] ?? "",
            topic: item['topic'] ?? "",
            content: item['content'] ?? "",
            hours: item['hours'] ?? "",
            points: item['points'] ?? "",
            targetGroup: item['target_group'] ?? "",
            location: item['location'] ?? "",
            startDate: item['start_date'] ?? "",
            endDate: item['end_date'] ?? "",
            normalRate: item['normal_rate'] ?? "",
            membersRate: item['members_rate'] ?? "",
            resource: item['resource'] ?? "",
            status: item['status'] ?? "",
            type: item['type'] ?? "",
            banner: item['banner'] ?? "",
            attendance_request: item['attendance_request'],
            attendance_status: item['attendance_status'] ?? "",
            //
          );
        }).toList();
        return cpdData;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      return []; // Return an empty list or handle the error in your UI
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Profile'),
          content:
              const Text('Please complete your profile to access this feature'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;
    Provider.of<UserProvider>(context)
        .totalNumberOfPointsFromCpd(totalCpdPoints);
    return InkWell(
      onTap: () {
        if (profileStatus == true) {
          _showDialog();
          return;
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CpdsScreen();
          }));
        }
      },
      child: Container(
        height: size.height * 0.098,
        width: size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 42, 129, 201),
              // Color.fromARGB(200, 139, 195, 74),
              Color.fromARGB(255, 42, 129, 201),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.white,
                offset: Offset(0.8, 0.3),
                blurRadius: 0.3,
                spreadRadius: 0.3),
            BoxShadow(
                color: Colors.grey,
                offset: Offset(0.3, 0.9),
                blurRadius: 0.3,
                spreadRadius: 0.3),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.07),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: size.height * 0.040,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.055),
              child: Text(
                "Check out all CPDS",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.022),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.07),
              child: Container(
                height: size.height * 0.06,
                width: size.width * 0.20,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text("${fetchedData.length}",
                        style: const TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
