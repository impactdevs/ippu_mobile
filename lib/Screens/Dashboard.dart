import 'dart:convert';
import 'dart:developer';

import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Screens/CpdsScreen.dart';
import 'package:ippu/Screens/EventsScreen.dart';
import 'package:ippu/Screens/JobsScreen.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Widgets/CommunicationScreenWidgets/SingleCommunicationDisplayScreen.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/CpdsSingleEventDisplay.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/SingleEventDisplay.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/CalendarScreen.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/upcoming_events.dart';
import 'package:ippu/Widgets/JobScreenWidgets/SingleJobDetailDisplay.dart';
import 'package:ippu/models/JobData.dart';
import 'package:provider/provider.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:ippu/env.dart' as env;

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
  Map<String, dynamic> latestComm = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    fetchAllData();
  }

  Future<List<JobData>> fetchJobData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    const apiUrl = 'https://staging.ippu.org/api/jobs';

    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> availableJobs = jsonData['data'];

        return availableJobs.map((item) => JobData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      log('Error fetching job data: $error');
      return [];
    }
  }

  Future<void> fetchAllData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    int userId = userData!.id;

    try {
      final authController = AuthController();
      final futures = await Future.wait([
        authController.getCpds(userId),
        authController.getEvents(userId),
        authController.getAllCommunications(userId),
        fetchJobData(),
      ]);

      final cpds = futures[0];
      final events = futures[1];
      final communications = futures[2];
      final jobs = futures[3] as List<JobData>;

      if (mounted) {
        setState(() {
          totalEvents = events.length;
          totalCPDS = cpds.length;
          availableJobs = jobs;
          totalJobs = jobs.length;
          totalCommunications = communications.length;

          final now = DateTime.now();
          upcomingEvents = events
              .where(
                  (event) => DateTime.parse(event['start_date']).isAfter(now))
              .toList()
            ..sort((a, b) => DateTime.parse(a['start_date'])
                .compareTo(DateTime.parse(b['start_date'])));

          upcomingCPDs = cpds
              .where((cpd) => DateTime.parse(cpd['start_date']).isAfter(now))
              .toList()
            ..sort((a, b) => DateTime.parse(a['start_date'])
                .compareTo(DateTime.parse(b['start_date'])));

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
      }
    } catch (e) {
      log('Error fetching data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarScreen())),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAllData,
              child: Stack(children: [
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
                        _buildLatestEventCPD(size, profileStatus),
                        SizedBox(height: size.height * 0.03),
                        _buildMainContent(size, subscriptionStatus,
                            profileStatus, upcomingEvents),
                      ],
                    ),
                  ),
                ),
              ]
                  // if (subscriptionStatus == 'false')
                  //   _buildSubscriptionNotification(size),
                  // if (profileStatus != null && profileStatus)
                  //   _buildProfileNotification(size),
                  ),
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

  Widget _buildLatestEventCPD(Size size, profileStatus) {
    final latestEvent = upcomingEvents.isNotEmpty ? upcomingEvents.first : null;
    final latestCPD = upcomingCPDs.isNotEmpty ? upcomingCPDs.first : null;

    if (latestEvent == null && latestCPD == null) {
      return const SizedBox.shrink();
    }

    final latestItem = (latestEvent != null && latestCPD != null)
        ? (DateTime.parse(latestEvent['start_date'])
                .isBefore(DateTime.parse(latestCPD['start_date']))
            ? latestEvent
            : latestCPD)
        : (latestEvent ?? latestCPD);

    final eventDate = DateTime.parse(latestItem['start_date']);
    final isEvent = latestItem == latestEvent;

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.blue[600],
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
                      child: Builder(
                        builder: (context) {
                          DateTime currentDate = DateTime.now();
                          DateTime startDate =
                              DateTime.parse(latestItem['start_date']);
                          DateTime endDate =
                              DateTime.parse(latestItem['end_date']);
                          bool attendanceRequest =
                              latestItem['attendance_request'];

                          if (currentDate.isBefore(endDate)) {
                            if (currentDate.isAfter(startDate) ||
                                currentDate.isAtSameMomentAs(startDate)) {
                              return Text(
                                "Event is happening",
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              );
                            } else if (attendanceRequest) {
                              return Text(
                                "Thank you for booking the event",
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              );
                            } else {
                              return ElevatedButton(
                                onPressed: () async {
                                  if (profileStatus != null && profileStatus) {
                                    showBottomNotification(
                                        'Please complete your profile first!');
                                  } else {
                                    isEvent
                                        ? await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return SingleEventDisplay(
                                                id: latestItem['id'].toString(),
                                                attendance_request: latestItem[
                                                    'attendance_request'],
                                                points: latestItem['points']
                                                    .toString(),
                                                normal_rate: latestItem['rate'],
                                                description:
                                                    latestItem['details'],
                                                startDate:
                                                    latestItem['start_date'],
                                                endDate: latestItem['end_date'],
                                                member_rate:
                                                    latestItem['member_rate'],
                                                imagelink:
                                                    'https://staging.ippu.org/storage/banners/${latestItem['banner_name']}',
                                                eventName: latestItem['name'],
                                              );
                                            }),
                                          ).then((value) {
                                            setState(() {
                                              fetchAllData();
                                            });
                                          })
                                        : await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return CpdsSingleEventDisplay(
                                                attendance_request: latestItem[
                                                    'attendance_request'],
                                                content: latestItem['content'],
                                                target_group:
                                                    latestItem['target_group'],
                                                startDate:
                                                    latestItem['start_date'],
                                                endDate: latestItem['end_date'],
                                                rate: latestItem['location']
                                                    .toString(),
                                                type: latestItem['type'],
                                                cpdId:
                                                    latestItem['id'].toString(),
                                                attendees: latestItem['points']
                                                    .toString(),
                                                imagelink:
                                                    'https://staging.ippu.org/storage/banners/${latestItem['banner']}',
                                                cpdsname: latestItem['topic'],
                                                normal_rate:
                                                    latestItem['normal_rate'],
                                                member_rate:
                                                    latestItem['members_rate'],
                                                location:
                                                    latestItem['location'],
                                              );
                                            }),
                                          ).then((value) {
                                            setState(() {
                                              fetchAllData();
                                            });
                                          });
                                  }
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
                              );
                            }
                          } else {
                            if (attendanceRequest) {
                              return Text(
                                "Thank you for attending this event",
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              );
                            } else {
                              return Text(
                                "This event happened, you missed!",
                                style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]));
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

  Widget _buildUpcomingCPDs(Size size, profileStatus) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming CPDs',
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (profileStatus != null && profileStatus) {
                    showBottomNotification(
                        'Please complete your profile first!');
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CpdsScreen()));
                  }
                },
                child: Text(
                  'View More',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.014,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          if (upcomingCPDs.isNotEmpty)
            SizedBox(
              height: size.height * 0.25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingCPDs.length,
                itemBuilder: (context, index) {
                  final cpd = upcomingCPDs[index];
                  return Container(
                    width: size.width * 0.7,
                    margin: EdgeInsets.only(right: size.width * 0.03),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.network(
                            'https://staging.ippu.org/storage/banners/${cpd['banner']}',
                            height: size.height * 0.10,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: size.height * 0.10,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                    vertical: size.height * 0.003,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    '${cpd['points']} points',
                                    style: GoogleFonts.lato(
                                      fontSize: size.height * 0.014,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cpd['topic'],
                                      style: GoogleFonts.lato(
                                        fontSize: size.height * 0.016,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: size.height * 0.018,
                                            color: Colors.blue[600]),
                                        SizedBox(width: size.width * 0.01),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(
                                              DateTime.parse(
                                                  cpd['start_date'])),
                                          style: GoogleFonts.lato(
                                            fontSize: size.height * 0.014,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: size.height * 0.018,
                                            color: Colors.blue[600]),
                                        SizedBox(width: size.width * 0.01),
                                        Text(
                                          'Duration: ${cpd['hours']} hours',
                                          style: GoogleFonts.lato(
                                            fontSize: size.height * 0.014,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Row(
                                      children: [
                                        Icon(Icons.group,
                                            size: size.height * 0.018,
                                            color: Colors.blue[600]),
                                        SizedBox(width: size.width * 0.01),
                                        Expanded(
                                          child: Text(
                                            'Target: ${cpd['target_group']}',
                                            style: GoogleFonts.lato(
                                              fontSize: size.height * 0.014,
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
                    fontSize: size.height * 0.016,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      Size size, subscriptionStatus, profileStatus, upcomingEvents) {
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
          UpcomingEventsWidget(
            upcomingEvents: upcomingEvents,
            profileStatus: profileStatus,
            showBottomNotification: (message) =>
                showBottomNotification(message),
            navigateToEventsScreen: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsScreen()),
              );
            },
          ),
          _buildUpcomingCPDs(size, profileStatus),
          _buildWarningCards(size, subscriptionStatus, profileStatus),
          _buildHotJobs(size, profileStatus),
        ],
      ),
    );
  }

  Widget _buildHotJobs(Size size, profileStatus) {
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
                    if (profileStatus != null && profileStatus) {
                      showBottomNotification(
                          'Please complete your profile first!');
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const JobsScreen();
                      }));
                    }
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
                height: size.height * 0.25,
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
                            SizedBox(height: size.height * 0.01),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: size.height * 0.02,
                                    color: DateTime.now().isBefore(
                                            DateTime.parse(
                                                job.deadline.toString()))
                                        ? Colors.green[600]
                                        : Colors.red[600]),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  DateTime.now().isBefore(DateTime.parse(
                                          job.deadline.toString()))
                                      ? 'Status: Applications Open'
                                      : 'Status: Applications Closed',
                                  style: GoogleFonts.lato(
                                    fontSize: size.height * 0.014,
                                    color: DateTime.now().isBefore(
                                            DateTime.parse(
                                                job.deadline.toString()))
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SingleJobDetailDisplayScreen(
                                      title: job.title,
                                      description: job.description,
                                      deadline: job.deadline.toString(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.015,
                                    horizontal: size.width * 0.05),
                              ),
                              child: Text(
                                'Check Out',
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
              final userData =
                  Provider.of<UserProvider>(context, listen: false).user;
              if (userData!.membership_amount == '0') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Subscription Not Available'),
                      content: const Text(
                          'Guests cannot subscribe. Please change your Account Type from Guest to another type in order to subscribe.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Change Account Type'),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()));
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                _handlePaymentInitialization(userData.name, userData.email,
                    userData.phone_no!, userData.membership_amount!);
              }
            },
          ),
      ],
    );
  }

  _handlePaymentInitialization(String fullName, String email,
      String phoneNumber, String membershipAmount) async {
    final Customer customer = Customer(
      name: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: env.Env.FLW_PUBLIC_KEY,
        currency: "UGX",
        redirectUrl: 'https://staging.ippu.org/login',
        txRef: const Uuid().v1(),
        amount: membershipAmount,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(
            title: "IPPU PAYMENT",
            logo:
                "https://ippu.or.ug/wp-content/uploads/2020/03/cropped-Logo-192x192.png"),
        isTestMode: false);
    final ChargeResponse response = await flutterwave.charge();
    String message;
    if (response.success == true) {
      message = "Payment successful,\n thank you!";
      sendRequest();
    } else {
      message = "Payment failed,\n try again later";
    }
    showLoading(message);
  }

  Future<void> showLoading(String message) {
    return showDialog(
      context: context,
      builder: (context) => CleanDialog(
        title: 'success',
        content: message,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        actions: [
          CleanDialogActionButtons(
            actionTitle: 'OK',
            onPressed: () => Navigator.pop(context),
          )
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

  Future<void> sendRequest() async {
    AuthController authController = AuthController();

    //try catch
    try {
      final response = await authController.subscribe();
      //check if response contains message key
      if (response.containsKey("message")) {
        //notify the SubscriptionStatusProvider
        if (mounted) {
          context
              .read<SubscriptionStatusProvider>()
              .setSubscriptionStatus("Pending");
        }
        //show bottom notification
        showBottomNotification(
            "your request has been sent! You will be approved");
      } else {
        //show bottom notification
        showBottomNotification("Something went wrong");
      }
    } catch (e) {
      showBottomNotification("Something went wrong");
    }
  }
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
