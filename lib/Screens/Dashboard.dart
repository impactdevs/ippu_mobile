import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
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
            Padding(
              padding: EdgeInsets.only(right: size.height * 0.01),
              child: Container(
                padding: EdgeInsets.all(size.height * 0.016),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.026,
                  ),
                ),
              ),
            ),
          ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: size.height * 0.4,
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
                        _buildMainContent(size),
                      ],
                    ),
                  ),
                ),
                if (subscriptionStatus == 'false')
                  _buildSubscriptionNotification(size),
                if (profileStatus != null && profileStatus)
                  _buildProfileNotification(size),
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
                    color: Colors.white, fontSize: size.height * 0.022),
              ),
              SizedBox(height: size.height * 0.005),
              Text(
                userData!.name,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: size.height * 0.032,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: size.width * 0.07,
            backgroundImage: const NetworkImage(
                'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png'),
          ),
        ],
      ),
    );
  }

  // Widget _buildSummaryCards(Size size) {
  //   return SizedBox(
  //     height: size.height * 0.18,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
  //       children: [
  //         _summaryCard('CPDs', totalCPDS.toString(), Icons.workspace_premium,
  //             Colors.orange, size),
  //         _summaryCard('Events', totalEvents.toString(), Icons.event,
  //             Colors.purple, size),
  //         _summaryCard(
  //             'Jobs', totalJobs.toString(), Icons.work, Colors.green, size),
  //         _summaryCard('Communications', totalCommunications.toString(),
  //             Icons.radio, Colors.blue, size),
  //       ],
  //     ),
  //   );
  // }

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
          Text(
            'Coming Soon:',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            upcomingEvents.isEmpty ? latestItem['topic'] : latestItem['name'],
            style: GoogleFonts.lato(
              fontSize: size.height * 0.022,
              color: Colors.black,
            ),
          ),
          Text(
            'Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.018,
              color: Colors.black,
            ),
          ),
          SizedBox(height: size.height * 0.016),
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
              return Text(
                days == 0
                    ? 'Starts in: $hours hrs : $minutes mins'
                    : days == 1
                        ? 'Starts in: $days day : $hours hrs : $minutes mins'
                        : 'Starts in: $days days : $hours hrs : $minutes mins',
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.015,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement attend functionality
                },
                child: const Text('Attend'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement view more functionality
                },
                child: const Text('View More'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isExpanded = false;

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
          Text(
            'Latest Communication',
            style: GoogleFonts.lato(
                fontSize: size.height * 0.022, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: size.height * 0.013),
          AnimatedCrossFade(
            firstChild: Html(
              data: latestCommunication,
              style: {
                "body": Style(
                  fontSize: FontSize(
                    size.height * 0.018,
                  ),
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                  color: Colors.black,
                ),
              },
            ),
            secondChild: Html(
              data: latestCommunication,
              style: {
                "body": Style(
                  fontSize: FontSize(size.height * 0.018),
                  color: Colors.black,
                ),
              },
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'See Less' : 'See More'),
            ),
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
            Text(
              'Upcoming CPDs',
              style: GoogleFonts.lato(
                fontSize: size.height * 0.024,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: size.height * 0.02),
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget _summaryCard(
  //     String title, String count, IconData icon, Color color, Size size) {
  //   return Card(
  //     elevation: 8, // Added elevation
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Container(
  //       width: size.width * 0.28, // Reduced width
  //       height: size.height * 0.15, // Added fixed height
  //       padding: EdgeInsets.all(size.width * 0.02),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon,
  //               size: size.height * 0.035, color: color), // Reduced icon size
  //           SizedBox(height: size.height * 0.01),
  //           Text(count,
  //               style: GoogleFonts.lato(
  //                   fontSize: size.height * 0.028, // Reduced font size
  //                   fontWeight: FontWeight.bold,
  //                   color: color)),
  //           SizedBox(height: size.height * 0.005),
  //           Text(
  //             title,
  //             style: GoogleFonts.lato(
  //                 fontSize: size.height * 0.014, // Reduced font size
  //                 color: Colors.grey[600],
  //                 fontWeight: FontWeight.w500),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMainContent(Size size) {
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
            Text(
              'Hot Jobs',
              style: GoogleFonts.lato(
                fontSize: size.height * 0.024,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: size.height * 0.01),
            if (availableJobs.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableJobs.length > 3 ? 3 : availableJobs.length,
                itemBuilder: (context, index) {
                  final job = availableJobs[index];
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
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(size.width * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.orange[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.work,
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
                                  job.title,
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
                                        color: Colors.orange[600]),
                                    SizedBox(width: size.width * 0.01),
                                    // Text(
                                    //   'Deadline: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(job['deadline']))}',
                                    //   style: GoogleFonts.lato(
                                    //     fontSize: size.height * 0.016,
                                    //     color: Colors.orange[600],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  job.description,
                                  style: GoogleFonts.lato(
                                    fontSize: size.height * 0.015,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // Widget _buildUserSummary(Size size) {
  //   return Container(
  //     padding: EdgeInsets.all(size.width * 0.06),
  //     margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Activity Summary',
  //             style: GoogleFonts.lato(
  //                 fontSize: size.height * 0.026, fontWeight: FontWeight.bold)),
  //         SizedBox(height: size.height * 0.03),
  //         SizedBox(
  //           height: size.height * 0.3,
  //           child: PieChart(
  //             PieChartData(
  //               sectionsSpace: 2,
  //               centerSpaceRadius: 50,
  //               sections: [
  //                 PieChartSectionData(
  //                   value: totalCPDS.toDouble(),
  //                   color: Colors.orange,
  //                   title: 'CPDs',
  //                   titleStyle: GoogleFonts.lato(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: size.height * 0.016),
  //                   radius: 80,
  //                 ),
  //                 PieChartSectionData(
  //                   value: totalEvents.toDouble(),
  //                   color: Colors.purple,
  //                   title: 'Events',
  //                   titleStyle: GoogleFonts.lato(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: size.height * 0.016),
  //                   radius: 80,
  //                 ),
  //                 PieChartSectionData(
  //                   value: totalJobs.toDouble(),
  //                   color: Colors.green,
  //                   title: 'Jobs',
  //                   titleStyle: GoogleFonts.lato(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: size.height * 0.016),
  //                   radius: 80,
  //                 ),
  //                 PieChartSectionData(
  //                   value: totalCommunications.toDouble(),
  //                   color: Colors.blue,
  //                   title: 'Communications',
  //                   titleStyle: GoogleFonts.lato(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: size.height * 0.016),
  //                   radius: 80,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildUpcomingEvents(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Container(
        margin: EdgeInsets.all(size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: GoogleFonts.lato(
                fontSize: size.height * 0.024,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
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
                          padding: EdgeInsets.all(size.width * 0.04),
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

  Widget _buildSubscriptionNotification(Size size) {
    return Positioned(
      bottom: size.height * 0.02,
      left: size.width * 0.04,
      right: size.width * 0.04,
      child: Container(
        height: size.height * 0.075,
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
        child: Center(
          child: Text(
            "Please complete your subscription",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.height * 0.018,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNotification(Size size) {
    return Positioned(
      bottom: size.height * 0.11,
      left: size.width * 0.04,
      right: size.width * 0.04,
      child: Container(
        height: size.height * 0.075,
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
        child: Center(
          child: Text(
            "Please complete your profile",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.height * 0.018,
            ),
          ),
        ),
      ),
    );
  }
}
