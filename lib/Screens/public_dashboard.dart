import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ippu/models/JobData.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class PublicDashboardScreen extends StatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  State<PublicDashboardScreen> createState() => _PublicDashboardScreenState();
}

class _PublicDashboardScreenState extends State<PublicDashboardScreen> {
  final List<dynamic> _upcomingEvents = [];
  final List<dynamic> _upcomingCPDs = [];
  final List<JobData> _availableJobs = [];
  String latestCommunication = '';
  bool _isLoading = true;
  final baseUrl = AppEndpoints.baseUrl;
  final baseImageUrl = AppEndpoints.baseImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPublicData();
  }

  Future<List<JobData>> fetchJobData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final apiUrl = '$baseUrl/jobs';

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
        throw Exception('Failed to load jobs data');
      }
    } catch (error) {
      log('Error fetching job data: $error');
      return [];
    }
  }

  Future<void> _fetchPublicData() async {
    try {
      final AuthController authController = AuthController();
      final futures = await Future.wait([
        authController.getPublicEvents(),
        authController.getPublicCpds(),
        authController.getPublicCommunications(),
        fetchJobData(),
      ]);

      final events = futures[0];
      final cpds = futures[1];
      final communications = futures[2];
      final jobs = futures[3] as List<JobData>;

      setState(() {
        final now = DateTime.now();
        _upcomingEvents.addAll(events.where(
            (event) => DateTime.parse(event['start_date']).isAfter(now)));
        _upcomingCPDs.addAll(cpds
            .where((cpd) => DateTime.parse(cpd['start_date']).isAfter(now)));
        _availableJobs.addAll(jobs);

        _upcomingEvents.sort((a, b) => _compareDates(a, b, now));
        _upcomingCPDs.sort((a, b) => _compareDates(a, b, now));

        latestCommunication = communications.isNotEmpty
            ? communications.first['message']
            : 'No recent communications';

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching public data: $e');
      setState(() => _isLoading = false);
    }
  }

  int _compareDates(dynamic a, dynamic b, DateTime now) {
    final DateTime dateA = DateTime.parse(a['start_date']);
    final DateTime dateB = DateTime.parse(b['start_date']);
    return dateA.difference(now).compareTo(dateB.difference(now));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildCarousel(size)),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(size),
                          _buildUpcomingEvents(size),
                          _buildUpcomingCPDs(size),
                          _buildAvailableJobs(size),
                          _buildLatestCommunication(size),
                          _buildCallToAction(size),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  Widget _buildCarousel(Size size) {
    return CarouselSlider(
      options: CarouselOptions(
        height: size.height * 0.3,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: [
        'assets/images/banner_1.jpeg',
        'assets/images/banner_2.jpeg',
        'assets/images/banner_3.jpeg',
      ].map((item) => _buildCarouselItem(item, size)).toList(),
    );
  }

  Widget _buildCarouselItem(String imagePath, Size size) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to IPPU',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.028,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Discover a world of professional growth and networking opportunities.',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.018,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(Size size) {
    return _buildSection(
      size,
      'Upcoming Events',
      _upcomingEvents,
      (event) => _buildEventCard(event, size),
      'No upcoming events',
    );
  }

  Widget _buildUpcomingCPDs(Size size) {
    return _buildSection(
      size,
      'Upcoming CPDs',
      _upcomingCPDs,
      (cpd) => _buildCPDCard(cpd, size),
      'No upcoming CPDs',
    );
  }

  Widget _buildAvailableJobs(Size size) {
    return _buildSection(
      size,
      'Available Jobs',
      _availableJobs,
      (job) => _buildJobCard(job, size),
      'No available jobs',
    );
  }

  Widget _buildLatestCommunication(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Communication',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.020,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Html(
                  data: latestCommunication,
                  style: {
                    "body": Style(
                      fontSize: FontSize(size.height * 0.018),
                      color: Colors.blue[800],
                      fontFamily: GoogleFonts.lato().fontFamily,
                      maxLines: 3,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen())),
                  child: Text('Read More',
                      style: GoogleFonts.lato(color: Colors.blue[600])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Size size, String title, List<dynamic> items,
      Widget Function(dynamic) itemBuilder, String emptyMessage) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.020,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen())),
                child: Text(
                  'Read More',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.014,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          items.isNotEmpty
              ? Column(
                  children: items
                      .take(3)
                      .map((item) => Padding(
                            padding:
                                EdgeInsets.only(bottom: size.height * 0.02),
                            child: itemBuilder(item),
                          ))
                      .toList(),
                )
              : _buildNoDataContainer(emptyMessage, size),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event, Size size) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  '$baseImageUrl/banners/${event['banner_name']}',
                  height: size.height * 0.15,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: size.height * 0.15,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              // Event details
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'],
                        style: GoogleFonts.lato(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: size.height * 0.01),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        text: DateFormat('MMM dd, yyyy')
                            .format(DateTime.parse(event['start_date'])),
                        size: size,
                        color: Colors.blue[600]!,
                      ),
                      SizedBox(height: size.height * 0.005),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        text: event['venue'] ?? 'Venue TBA',
                        size: size,
                        color: Colors.blue[600]!,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Event',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.014,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon,
      required String text,
      required Size size,
      required Color color}) {
    return Row(
      children: [
        Icon(icon, size: size.height * 0.022, color: color),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: size.height * 0.016,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCPDCard(dynamic cpd, Size size) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  '$baseImageUrl/banners/${cpd['banner']}',
                  height: size.height * 0.15,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: size.height * 0.15,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cpd['topic'],
                        style: GoogleFonts.lato(
                          fontSize: size.height * 0.018,
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
                          SizedBox(width: size.width * 0.02),
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(DateTime.parse(cpd['start_date'])),
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
                              color: Colors.blue[600]),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            '${cpd['duration'] ?? 'Duration TBA'} hours',
                            style: GoogleFonts.lato(
                              fontSize: size.height * 0.016,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Text(
                'CPD',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.014,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobData job, Size size) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: GoogleFonts.lato(
                fontSize: size.height * 0.022,
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
                    size: size.height * 0.02, color: Colors.blue[600]),
                SizedBox(width: size.width * 0.02),
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
                    color: DateTime.now()
                            .isBefore(DateTime.parse(job.deadline.toString()))
                        ? Colors.green[600]
                        : Colors.red[600]),
                SizedBox(width: size.width * 0.02),
                Text(
                  DateTime.now()
                          .isBefore(DateTime.parse(job.deadline.toString()))
                      ? 'Applications Open'
                      : 'Applications Closed',
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.016,
                    color: DateTime.now()
                            .isBefore(DateTime.parse(job.deadline.toString()))
                        ? Colors.green[600]
                        : Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataContainer(String message, Size size) {
    return Container(
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
          message,
          style: GoogleFonts.lato(
            fontSize: size.height * 0.018,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCallToAction(Size size) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join IPPU Today!',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.024,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Unlock exclusive access to events, CPDs, and networking opportunities.',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.016,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue[800],
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.015,
              ),
            ),
            child: Text(
              'Login Now',
              style: GoogleFonts.lato(
                fontSize: size.height * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
