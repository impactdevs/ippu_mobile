import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
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
      final jobs = await fetchJobData();

      setState(() {
        totalEvents = events.length;
        totalCPDS = cpds.length;
        availableJobs = jobs;
        totalJobs = jobs.length;
        totalCommunications = communications.length;
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCPDS(totalCPDS);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfEvents(totalEvents);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCommunications(totalCommunications);
      });
    } catch (e) {
      // Handle any errors here
    }
  }

  // Future<void> fetchData() async {
  //   final userData = Provider.of<UserProvider>(context, listen: false).user;
  //   int userId = userData!.id;
  //   try {
  //     AuthController authController = AuthController();
  //     final cpds = await authController.getCpds(userId);
  //     final events = await authController.getEvents(userId);
  //     // Assuming you have methods to fetch jobs and education data
  // Placeholder, replace with actual method
  //     final education = []; // Placeholder, replace with actual method

  //     setState(() {
  //       totalCPDS = cpds.length;
  //       totalEvents = events.length;
  //       totalJobs = jobs.length;
  //       totalCommunications = education.length;
  //       upcomingEvents = events
  //           .where(
  //               (event) => DateTime.parse(event.date).isAfter(DateTime.now()))
  //           .toList();
  //     });
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: size.height * 0.38,
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
                  _buildSummaryCards(size),
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

  Widget _buildSummaryCards(Size size) {
    return SizedBox(
      height: size.height * 0.18,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        children: [
          _summaryCard('CPDs', totalCPDS.toString(), Icons.workspace_premium,
              Colors.orange, size),
          _summaryCard('Events', totalEvents.toString(), Icons.event,
              Colors.purple, size),
          _summaryCard(
              'Jobs', totalJobs.toString(), Icons.work, Colors.green, size),
          _summaryCard('Communications', totalCommunications.toString(),
              Icons.radio, Colors.blue, size),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String title, String count, IconData icon, Color color, Size size) {
    return Card(
      elevation: 8, // Added elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: size.width * 0.28, // Reduced width
        height: size.height * 0.15, // Added fixed height
        padding: EdgeInsets.all(size.width * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: size.height * 0.035, color: color), // Reduced icon size
            SizedBox(height: size.height * 0.01),
            Text(count,
                style: GoogleFonts.lato(
                    fontSize: size.height * 0.028, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: color)),
            SizedBox(height: size.height * 0.005),
            Text(
              title,
              style: GoogleFonts.lato(
                  fontSize: size.height * 0.014, // Reduced font size
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
          SizedBox(height: size.height * 0.04),
          _buildUserSummary(size),
          SizedBox(height: size.height * 0.04),
          _buildUpcomingEvents(size),
          SizedBox(height: size.height * 0.1),
        ],
      ),
    );
  }

  Widget _buildUserSummary(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Summary',
              style: GoogleFonts.lato(
                  fontSize: size.height * 0.026, fontWeight: FontWeight.bold)),
          SizedBox(height: size.height * 0.03),
          SizedBox(
            height: size.height * 0.3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: totalCPDS.toDouble(),
                    color: Colors.orange,
                    title: 'CPDs',
                    titleStyle: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.016),
                    radius: 80,
                  ),
                  PieChartSectionData(
                    value: totalEvents.toDouble(),
                    color: Colors.purple,
                    title: 'Events',
                    titleStyle: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.016),
                    radius: 80,
                  ),
                  PieChartSectionData(
                    value: totalJobs.toDouble(),
                    color: Colors.green,
                    title: 'Jobs',
                    titleStyle: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.016),
                    radius: 80,
                  ),
                  PieChartSectionData(
                    value: totalCommunications.toDouble(),
                    color: Colors.blue,
                    title: 'Communications',
                    titleStyle: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.016),
                    radius: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Events',
              style: GoogleFonts.lato(
                  fontSize: size.height * 0.026, fontWeight: FontWeight.bold)),
          SizedBox(height: size.height * 0.02),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];
              return Container(
                margin: EdgeInsets.only(bottom: size.height * 0.02),
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.event,
                          color: Colors.white, size: size.height * 0.03),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: GoogleFonts.lato(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: size.height * 0.005),
                          Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(DateTime.parse(event.date)),
                              style: GoogleFonts.lato(
                                  fontSize: size.height * 0.014,
                                  color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (upcomingEvents.isEmpty)
            Center(
              child: Text(
                'No upcoming events',
                style: GoogleFonts.lato(
                    fontSize: size.height * 0.018, color: Colors.grey[600]),
              ),
            ),
        ],
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
