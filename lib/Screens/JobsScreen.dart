import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/JobScreenWidgets/SIngleJobDetailDisplay.dart';
import 'package:ippu/models/JobData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  
  late Future<List<JobData>> jobDataFuture;

  @override
  void initState() {
    super.initState();
    jobDataFuture = fetchJobData();
  }

  //
  Future<List<JobData>> fetchJobData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with  userData.id
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
      //catch the exception
      return []; // Return an empty list or handle the error in your UI
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final availableJobs =
        Provider.of<UserProvider>(context, listen: false).getTotalJobs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        elevation: 0,
        title: Text("Jobs", style: GoogleFonts.lato(color: Colors.white)),
        actions: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: EdgeInsets.only(
                  // top: size.height*0.008,
                  left: size.width * 0.034),
              child: Text(
                "Total jobs available: ",
                style: GoogleFonts.lato(
                    color: const Color.fromARGB(255, 15, 255, 23),
                    fontSize: size.height * 0.018,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.016),
              child: Text(
                "$availableJobs",
                style: GoogleFonts.lato(
                    fontSize: size.height * 0.015,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ])
        ],
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
              height: size.height * 0.80,
              width: size.width * 0.9,
              child: FutureBuilder<List<JobData>>(
                future: jobDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          "Check your internet connection to load the data"),
                    );
                  } else if (snapshot.hasData) {
                    List<JobData> eventData = snapshot.data!;
                    return ListView.builder(
                      itemCount: eventData.length,
                      itemBuilder: (context, index) {
                        JobData data = eventData[index];
                        return Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.012,
                            ),
                            Container(
                            
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 210, 211, 211),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: const Offset(0.8, 1.0),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                
                                children: [
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                      child:Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: size.width * 0.06,
                                                top: size.height * 0.004),
                                            child: Text(
                                              "Job Title",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: size.height * 0.028,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: size.width * 0.06,
                                                top: size.height * 0.0008),
                                            child: Text(
                                              data.title,
                                              style:
                                                  const TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.06,
                                                  top: size.height * 0.016),
                                              child: const Text(
                                                "Deadline",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.06,
                                                  right: size.width * 0.06,
                                                  top: size.height * 0.0016),
                                              child: Text(
                                                "${data.deadline}",
                                                textAlign: TextAlign.justify,
                                                style: const TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 0.024,
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 42, 129,
                                            201), // Change button color to green
                                        padding:
                                            EdgeInsets.all(size.height * 0.020),
                                      ),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return SingleJobDetailDisplayScreen(
                                              title: data.title,
                                              description: data.description,
                                              deadline:
                                                  data.deadline.toString());
                                        }));
                                      },
                                      child: Text(
                                        'View Job Details',
                                          style: GoogleFonts.lato(
    textStyle: const TextStyle(color: Colors.white), // Set text color to white
  ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.024,
                                  ),
                                  Center(
                                    child: Text(
                                      getDeadlineStatus(data.deadline
                                          .toString()), // Call a function to get the deadline status
                                      style: TextStyle(
                                        color: getDeadlineStatusColor(data
                                            .deadline
                                            .toString()), // Set text color based on deadline status
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                   SizedBox(
                              height: size.height * 0.012,
                            ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 0.016),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getDeadlineStatus(String deadline) {
    DateTime deadlineDate = DateTime.parse(deadline);
    if (deadlineDate.isBefore(DateTime.now())) {
      return 'Applications Closed';
    } else {
      return 'Applications Ongoing'; // You can format the date as per your requirement
    }
  }

  Color getDeadlineStatusColor(String deadline) {
    DateTime deadlineDate = DateTime.parse(deadline);
    return deadlineDate.isBefore(DateTime.now()) ? Colors.red : Colors.green;
  }
}
