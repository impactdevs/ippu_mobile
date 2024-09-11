import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PublicDashboardScreen extends StatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  State<PublicDashboardScreen> createState() => _PublicDashboardScreenState();
}

class _PublicDashboardScreenState extends State<PublicDashboardScreen> {
  final List<dynamic> _upcomingEvents = [];
  final List<dynamic> _upcomingCPDs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPublicData();
  }

  Future<void> _fetchPublicData() async {
    try {
      final AuthController authController = AuthController();
      final events = await authController.getEvents(1980);
      final cpds = await authController.getCpds(1980);

      setState(() {
        final now = DateTime.now();
        _upcomingEvents.addAll(events.where(
            (event) => DateTime.parse(event['start_date']).isAfter(now)));
        _upcomingCPDs.addAll(cpds
            .where((cpd) => DateTime.parse(cpd['start_date']).isAfter(now)));

        _upcomingEvents.sort((a, b) => _compareDates(a, b, now));
        _upcomingCPDs.sort((a, b) => _compareDates(a, b, now));

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
        // appBar: _buildAppBar(size),
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
                          _buildCallToAction(size),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  // PreferredSizeWidget _buildAppBar(Size size) {
  //   return AppBar(
  //     iconTheme: const IconThemeData(color: Colors.white),
  //     title: Text(
  //       'IPPU Public Dashboard',
  //       style: GoogleFonts.lato(
  //         fontSize: size.height * 0.020,
  //         color: Colors.white,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     centerTitle: false,
  //     flexibleSpace: Container(
  //       decoration: const BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //       ),
  //     ),
  //     actions: [
  //       TextButton(
  //         onPressed: () => Navigator.push(context,
  //             MaterialPageRoute(builder: (context) => const LoginScreen())),
  //         child: Text(
  //           'Login',
  //           style: GoogleFonts.lato(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
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

  Widget _buildSection(Size size, String title, List<dynamic> items,
      Widget Function(dynamic) itemBuilder, String emptyMessage) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: size.height * 0.024,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          items.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length > 3 ? 3 : items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.02),
                    child: itemBuilder(items[index]),
                  ),
                )
              : _buildNoDataContainer(emptyMessage, size),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event, Size size) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['name'],
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.024,
                  color: Colors.blue[800],
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.015),
              _buildInfoRow(
                icon: Icons.calendar_today,
                text: DateFormat('MMM dd, yyyy')
                    .format(DateTime.parse(event['start_date'])),
                size: size,
                color: Colors.blue[600]!,
              ),
              SizedBox(height: size.height * 0.01),
              _buildInfoRow(
                icon: Icons.location_on,
                text: event['venue'] ?? 'Venue TBA',
                size: size,
                color: Colors.blue[600]!,
              ),
            ],
          ),
        ),
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
              fontSize: size.height * 0.018,
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cpd['topic'],
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: size.height * 0.02, color: Colors.green[600]),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    DateFormat('MMM dd, yyyy')
                        .format(DateTime.parse(cpd['start_date'])),
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.016,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: size.height * 0.02, color: Colors.green[600]),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    '${cpd['duration'] ?? 'Duration TBA'} hours',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.016,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
