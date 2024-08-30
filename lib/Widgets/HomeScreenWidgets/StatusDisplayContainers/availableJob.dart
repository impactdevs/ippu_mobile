import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ippu/Screens/JobsScreen.dart';
import 'package:ippu/models/JobData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class availableJob extends StatefulWidget {
  const availableJob({super.key});

  @override
  State<availableJob> createState() => _availableJobState();
}

class _availableJobState extends State<availableJob> {
  late Future<List<JobData>> dataFuture;
  late List<JobData> fetchedData = []; // Declare a list to store fetched data

  @override
  void initState() {
    super.initState();
    // Assign the result of fetchdata to the fetchedData list
    dataFuture = fetchJobData().then((data) {
      fetchedData = data;
      return data;
    });
    dataFuture = fetchJobData();
  }

  Future<List<JobData>> fetchJobData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    const apiUrl = 'https://staging.ippu.org/api/jobs';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> availableJobs = jsonData['data'];
        List<JobData> jobs = availableJobs.map((item) {
          return JobData(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            visibleFrom: item['visibleFrom'],
            visibleTo: item['visibleTo'],
            deadline: item['deadline'],
          );
        }).toList();
        return jobs;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      print('Error: $error');
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

  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Provider.of<UserProvider>(context, listen: false)
        .fetchTotalJobs(fetchedData.length);
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;

    return InkWell(
      onTap: () {
        if (profileStatus == true) {
          _showDialog();
          return;
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const JobsScreen();
          }));
        }
      },
      child: Container(
        height: size.height * 0.098,
        width: size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 42, 129, 201),
              Color.fromARGB(255, 42, 201, 161),
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
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Icon(
                Icons.info,
                color: Colors.white,
                size: size.height * 0.040,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.055),
              child: Text(
                "Available jobs",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.020),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.20),
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
