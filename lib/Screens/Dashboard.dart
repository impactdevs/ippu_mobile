import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Screens/CpdsScreen.dart';
import 'package:ippu/Screens/EventsScreen.dart';
import 'package:ippu/Screens/JobsScreen.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Widgets/CommunicationScreenWidgets/SingleCommunicationDisplayScreen.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/CalendarScreen.dart';
import 'package:ippu/models/JobData.dart';
import 'package:provider/provider.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalCPDS = 0;
  int totalEvents = 0;
  int totalJobs = 0;
  int totalCommunications = 0;
  List<dynamic> upcomingEvents = [];
  List<JobData> availableJobs = [];
  List<dynamic> upcomingCPDs = [];
  String latestCommunication = '';
  bool isLoading = true;
  final formatter = NumberFormat('#,##0');
  var latestComm = {};

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

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
        log(availableJobs.toString());
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

  Future<void> fetchAllData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    int userId = userData!.id;
    try {
      AuthController authController = AuthController();
      final cpds = await authController.getCpds(userId);
      final events = await authController.getEvents(userId);
      final communications = await authController.getAllCommunications(userId);
      log(communications.toString());
      final jobs = await fetchJobData();

      setState(() {
        totalEvents = events.length;
        totalCPDS = cpds.length;
        availableJobs = jobs;
        totalJobs = jobs.length;
        totalCommunications = communications.length;
        final now = DateTime.now();
        upcomingEvents = events
            .where((event) =>
                DateTime.parse(event['start_date']).isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) {
            DateTime dateA = DateTime.parse(a['start_date']);
            DateTime dateB = DateTime.parse(b['start_date']);
            return dateA.difference(now).compareTo(dateB.difference(now));
          });
        log(upcomingEvents.toString());

        upcomingCPDs = cpds
            .where((cpd) => DateTime.parse(cpd['start_date']).isAfter(now))
            .toList()
          ..sort((a, b) {
            DateTime dateA = DateTime.parse(a['start_date']);
            DateTime dateB = DateTime.parse(b['start_date']);
            return dateA.difference(now).compareTo(dateB.difference(now));
          });
        log(upcomingCPDs.toString());
        latestComm = communications.isNotEmpty
            ? communications.first
            : {'message': 'No recent communications'};
        latestCommunication = communications.isNotEmpty
            ? communications.first['message']
            : 'No recent communications';

        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCPDS(totalCPDS);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfEvents(totalEvents);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCommunications(totalCommunications);
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final subscriptionStatus =
        context.watch<SubscriptionStatusProvider>().status;
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;

    return Scaffold(
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'IPPU MEMBERSHIP APP',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.020,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarScreen()));
              },
              icon: const Icon(Icons.calendar_month),
            ),
          ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: size.height * 0.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(size),
                        SizedBox(height: size.height * 0.02),
                        _buildLatestEventCPD(size),
                        SizedBox(height: size.height * 0.03),
                        _buildMainContent(
                            size, subscriptionStatus, profileStatus),
                      ],
                    ),
                  ),
                ),
                // if (subscriptionStatus == 'false')
                //   _buildSubscriptionNotification(size),
                // if (profileStatus != null && profileStatus)
                //   _buildProfileNotification(size),
              ],
            ),
    );
  }

  Widget _buildHeader(Size size) {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: GoogleFonts.lato(
                    color: Colors.white, fontSize: size.height * 0.020),
              ),
              SizedBox(height: size.height * 0.005),
              SizedBox(
                width: size.width * 0.7, // Adjust this value as needed
                child: Text(
                  userData!.name,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: size.height * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Stream<Duration> _countdownStream(DateTime endTime) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final remaining = endTime.difference(DateTime.now());
      return remaining > Duration.zero ? remaining : Duration.zero;
    });
  }

  Widget _buildLatestEventCPD(Size size) {
    final latestItem = upcomingEvents.isNotEmpty
        ? upcomingEvents.first
        : (upcomingCPDs.isNotEmpty ? upcomingCPDs.first : null);
    if (latestItem == null) return const SizedBox.shrink();

    final eventDate = DateTime.parse(latestItem['start_date']);
    final isEvent = upcomingEvents.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: isEvent ? Colors.blue[600] : Colors.orange[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isEvent ? Icons.event : Icons.school,
                  color: Colors.white,
                  size: size.height * 0.03,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  isEvent ? 'Event Coming Soon' : 'CPD Coming Soon',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.019,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEvent ? latestItem['name'] : latestItem['topic'],
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.019,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: size.height * 0.007),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: size.height * 0.02, color: Colors.blue[600]),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      DateFormat('MMM dd, yyyy').format(eventDate),
                      style: GoogleFonts.lato(
                        fontSize: size.height * 0.016,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                StreamBuilder<Duration>(
                  stream: _countdownStream(eventDate),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final duration = snapshot.data!;
                    final days = duration.inDays;
                    final hours = duration.inHours.remainder(24);
                    final minutes = duration.inMinutes.remainder(60);
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.01,
                        horizontal: size.width * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: size.height * 0.02,
                            color: Colors.blue[600],
                          ),
                          SizedBox(width: size.width * 0.01),
                          Text(
                            days == 0
                                ? 'Starts in: $hours hrs and $minutes mins'
                                : days == 1
                                    ? 'Starts in: $days day, $hours hrs and $minutes mins'
                                    : 'Starts in: $days days, $hours hrs and $minutes mins',
                            style: GoogleFonts.lato(
                                fontSize: size.height * 0.016,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement attend functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015),
                        ),
                        child: Text(
                          'Book for Attendance',
                          style: GoogleFonts.lato(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String extractDate(String fullDate) {
    List<String> parts = fullDate.split('T');
    return parts[0];
  }

  Widget _buildLatestCommunication(Size size) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Latest Communication',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SingleCommunicationDisplayScreen(
                      communicationtitle: latestComm['title'],
                      communicationbody: latestComm['message'],
                      communicationdate: extractDate(latestComm['created_at']),
                    );
                  }));
                },
                child: Text(
                  'Read More',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.015,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.013),
          Html(
            data: latestCommunication,
            style: {
              "body": Style(
                fontSize: FontSize(size.height * 0.018),
                maxLines: 3,
                textOverflow: TextOverflow.ellipsis,
                color: Colors.black,
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCPDs(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Container(
        margin: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming CPDs',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.024,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CpdsScreen()));
                  },
                  child: Text(
                    'View More',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.015,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            if (upcomingCPDs.isNotEmpty)
              SizedBox(
                height: size.height * 0.2,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingCPDs.length,
                  itemBuilder: (context, index) {
                    final cpd = upcomingCPDs[index];
                    return Container(
                      width: size.width * 0.7,
                      margin: EdgeInsets.only(right: size.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.height * 0.004,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                '${cpd['points']} points',
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.016,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(size.width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cpd['topic'],
                                  style: GoogleFonts.lato(
                                    fontSize: size.height * 0.019,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: size.height * 0.02,
                                        color: Colors.blue[600]),
                                    SizedBox(width: size.width * 0.01),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(
                                          DateTime.parse(cpd['start_date'])),
                                      style: GoogleFonts.lato(
                                        fontSize: size.height * 0.016,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.008),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: size.height * 0.02,
                                        color: Colors.blue[600]),
                                    SizedBox(width: size.width * 0.01),
                                    Text(
                                      'Duration: ${cpd['hours']} hours',
                                      style: GoogleFonts.lato(
                                        fontSize: size.height * 0.016,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.008),
                                Row(
                                  children: [
                                    Icon(Icons.group,
                                        size: size.height * 0.02,
                                        color: Colors.blue[600]),
                                    SizedBox(width: size.width * 0.01),
                                    Expanded(
                                      child: Text(
                                        'Target: ${cpd['target_group']}',
                                        style: GoogleFonts.lato(
                                          fontSize: size.height * 0.016,
                                          color: Colors.blue[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No upcoming CPDs',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.018,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size, subscriptionStatus, profileStatus) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildLatestCommunication(size),
          SizedBox(height: size.height * 0.02),
          _buildUpcomingEvents(size),
          _buildUpcomingCPDs(size),
          _buildWarningCards(size, subscriptionStatus, profileStatus),
          _buildHotJobs(size),
        ],
      ),
    );
  }

  Widget _buildHotJobs(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Container(
        margin: EdgeInsets.all(size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hot Jobs',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.024,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const JobsScreen();
                    }));
                  },
                  child: Text(
                    'View More',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.015,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            if (availableJobs.isNotEmpty)
              SizedBox(
                height: size.height * 0.2,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableJobs.length,
                  itemBuilder: (context, index) {
                    final job = availableJobs[index];
                    return Container(
                      width: size.width * 0.7,
                      margin: EdgeInsets.only(right: size.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: GoogleFonts.lato(
                                fontSize: size.height * 0.019,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.01),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: size.height * 0.02,
                                    color: Colors.blue[600]),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  'Deadline: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(job.deadline.toString()))}',
                                  style: GoogleFonts.lato(
                                    fontSize: size.height * 0.016,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const JobsScreen();
                                }));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.015),
                              ),
                              child: Text(
                                'View Details',
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No hot jobs available',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.018,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Container(
        margin: EdgeInsets.all(size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.024,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EventsScreen()));
                  },
                  child: Text(
                    'View More',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.015,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            if (upcomingEvents.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = upcomingEvents[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: size.height * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(size.width * 0.03),
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event,
                                  color: Colors.white,
                                  size: size.height * 0.03,
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['name'],
                                      style: GoogleFonts.lato(
                                        fontSize: size.height * 0.019,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: size.height * 0.007),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: size.height * 0.02,
                                            color: Colors.blue[600]),
                                        SizedBox(width: size.width * 0.01),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(
                                              DateTime.parse(
                                                  event['start_date'])),
                                          style: GoogleFonts.lato(
                                            fontSize: size.height * 0.016,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Text(
                                      'Rate: UGX. ${formatter.format(double.parse(event['rate']))}',
                                      style: GoogleFonts.lato(
                                        fontSize: size.height * 0.015,
                                        color: Colors.blue[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (event['location'] != null) ...[
                                      SizedBox(height: size.height * 0.008),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: size.height * 0.02,
                                              color: Colors.blue[600]),
                                          SizedBox(width: size.width * 0.01),
                                          Expanded(
                                            child: Text(
                                              event['location'],
                                              style: GoogleFonts.lato(
                                                fontSize: size.height * 0.016,
                                                color: Colors.blue[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.02,
                              vertical: size.height * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: Text(
                              '${event['points']} points',
                              style: GoogleFonts.lato(
                                fontSize: size.height * 0.014,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No upcoming events',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.018,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // if (subscriptionStatus == 'false')
  //   _buildSubscriptionNotification(size),
  // if (profileStatus != null && profileStatus)
  //   _buildProfileNotification(size),

  Widget _buildWarningCards(Size size, subscriptionStatus, profileStatus) {
    return Column(
      children: [
        if (profileStatus != null && profileStatus)
          _buildWarningCard(
            size,
            "Please complete your profile",
            () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
            },
          ),
        if (subscriptionStatus == 'false')
          _buildWarningCard(
            size,
            "Please complete your subscription",
            () {
              // Add navigation to subscription page
            },
          ),
      ],
    );
  }

  Widget _buildWarningCard(Size size, String message, VoidCallback onPressed) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7676),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.height * 0.018,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Complete',
                  style: GoogleFonts.lato(
                    color: const Color(0xFFFF7676),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
