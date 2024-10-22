import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  List<JobData> jobData = [];

  @override
  void initState() {
    super.initState();
    jobDataFuture = fetchJobData();
    jobDataFuture.then((value) => setState(() {
          jobData = value;
        }));
  }

  Future<List<JobData>> fetchJobData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    const apiUrl = 'https://ippu.org/api/jobs';
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> availableJobs = jsonData['data'];
        return availableJobs
            .map((item) => JobData(
                  id: item['id'],
                  title: item['title'],
                  description: item['description'],
                  visibleFrom: item['visibleFrom'],
                  visibleTo: item['visibleTo'],
                  deadline: item['deadline'],
                ))
            .toList();
      } else {
        throw Exception('Failed to load jobs data');
      }
    } catch (error) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2A81C9),
        elevation: 0,
        title: Text("Jobs",
            style: GoogleFonts.lato(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: size.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.05),
            ),
            child: Text(
              "Total: ${jobData.length}",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
        ],
      ),
      body: FutureBuilder<List<JobData>>(
        future: jobDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Check your internet connection to load the data"),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<JobData> jobData = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(size.width * 0.04),
              itemCount: jobData.length,
              itemBuilder: (context, index) {
                JobData job = jobData[index];
                return JobCard(job: job);
              },
            );
          } else {
            return const Center(child: Text('No jobs available'));
          }
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobData job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDeadlinePassed =
        DateTime.parse(job.deadline.toString()).isBefore(DateTime.now());

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: GoogleFonts.lato(
                fontSize: size.height * 0.022,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2A81C9),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: size.height * 0.02, color: Colors.grey),
                SizedBox(width: size.width * 0.01),
                Text(
                  "Deadline: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(job.deadline.toString()))}",
                  style: GoogleFonts.lato(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Html(
              data: job.description,
              style: {
                "body": Style(
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                  fontSize: FontSize(14.0),
                  color: Colors.grey[800],
                ),
              },
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A81C9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.05)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleJobDetailDisplayScreen(
                          title: job.title,
                          description: job.description,
                          deadline: job.deadline.toString(),
                        ),
                      ),
                    );
                  },
                  child: Text('View Details',
                      style: GoogleFonts.lato(color: Colors.white)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.008),
                  decoration: BoxDecoration(
                    color: isDeadlinePassed
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(size.width * 0.05),
                  ),
                  child: Text(
                    isDeadlinePassed ? 'Closed' : 'Open',
                    style: GoogleFonts.lato(
                      color: isDeadlinePassed ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
