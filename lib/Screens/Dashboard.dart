import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'dart:async';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Map<String, Duration> _eventCountdowns = {};
  Map<String, Duration> _cpdCountdowns = {};
  Map<String, Duration> _jobCountdowns = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
    _updateCountdowns();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdowns());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdowns() {
    final now = DateTime.now();
    setState(() {
      _eventCountdowns = _getUpcomingEvents().asMap().map(
        (index, item) {
          final eventDate =
              DateFormat('MMM d, yyyy').parse(item['date'] as String);
          return MapEntry(
            item['title'] as String,
            eventDate.difference(now),
          );
        },
      );
      _cpdCountdowns = _getUpcomingCPDs().asMap().map(
        (index, item) {
          final cpdDate =
              DateFormat('MMM d, yyyy').parse(item['date'] as String);
          return MapEntry(
            item['title'] as String,
            cpdDate.difference(now),
          );
        },
      );
      _jobCountdowns = _getNewJobs().asMap().map(
        (index, item) {
          final jobDate =
              DateFormat('MMM d, yyyy').parse(item['date'] as String);
          return MapEntry(
            item['title'] as String,
            jobDate.difference(now),
          );
        },
      );
    });
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
          automaticallyImplyLeading: false, // Hides the back button
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/profile_placeholder.png'), // Placeholder image
              radius: 20, // Adjust the size of the profile picture
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText: 'Search...',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // Open navigation drawer or menu
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: const Text(
                        'Hello [Name], Welcome to IPPU!',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Discover everything you need to stay updated: from upcoming events and CPDs to subscribing easily from your convenience and accessing your certificates. We’re here to help you make the most of every opportunity!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Login action
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue, // Blue border color
                            side: const BorderSide(
                                color: Colors.blue), // Blue border color
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title "Upcoming Events"
            const AnimationConfiguration.staggeredList(
              position: 0,
              duration: Duration(milliseconds: 375),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Text(
                    "Upcoming Events",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Horizontally scrollable cards for upcoming events
            SizedBox(
              height: 200, // Adjust height as needed
              child: ScrollableCardList(
                items: _getUpcomingEvents(),
                countdowns: _eventCountdowns,
              ),
            ),
            const SizedBox(height: 24),
            // Title "Upcoming CPDs"
            const AnimationConfiguration.staggeredList(
              position: 1,
              duration: Duration(milliseconds: 375),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Text(
                    "Upcoming CPDs",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Horizontally scrollable cards for upcoming CPDs
            SizedBox(
              height: 200, // Adjust height as needed
              child: ScrollableCardList(
                items: _getUpcomingCPDs(),
                countdowns: _cpdCountdowns,
              ),
            ),
            const SizedBox(height: 24),
            // Title "New Jobs"
            const AnimationConfiguration.staggeredList(
              position: 2,
              duration: Duration(milliseconds: 375),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Text(
                    "New Jobs",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Horizontally scrollable cards for new jobs
            SizedBox(
              height: 200, // Adjust height as needed
              child: ScrollableCardList(
                items: _getNewJobs(),
                countdowns: _jobCountdowns,
              ),
            ),
            const SizedBox(height: 24),
            // Title "Unread Communications"
            const AnimationConfiguration.staggeredList(
              position: 3,
              duration: Duration(milliseconds: 375),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Text(
                    "Unread Communications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Horizontally scrollable cards for unread communications
            SizedBox(
              height: 200, // Adjust height as needed
              child: ScrollableCardList(
                items: _getUnreadCommunications(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getUpcomingEvents() {
    return [
      {
        'title': 'Event 1',
        'venue': 'Venue A',
        'date': 'Aug 25, 2024',
      },
      {
        'title': 'Event 2',
        'venue': 'Venue B',
        'date': 'Sep 10, 2024',
      },


      
      // Add more events as needed
    ];
  }

  List<Map<String, dynamic>> _getUpcomingCPDs() {
    return [
      {
        'title': 'CPD 1',
        'venue': 'Venue C',
        'date': 'Aug 30, 2024',
      },
      {
        'title': 'CPD 2',
        'venue': 'Venue D',
        'date': 'Sep 15, 2024',
      },
      // Add more CPDs as needed
    ];
  }

  List<Map<String, dynamic>> _getNewJobs() {
    return [
      {
        'title': 'Job 1',
        'venue': 'Company A',
        'date': 'Aug 28, 2024',
      },
      {
        'title': 'Job 2',
        'venue': 'Company B',
        'date': 'Sep 05, 2024',
      },
      // Add more jobs as needed
    ];
  }

  List<Map<String, dynamic>> _getUnreadCommunications() {
    return [
      {
        'title': 'Communication 1',
        'venue': 'Location E',
        'date': 'Aug 20, 2024',
      },
      {
        'title': 'Communication 2',
        'venue': 'Location F',
        'date': 'Aug 22, 2024',
      },
      // Add more communications as needed
    ];
  }
}

class ScrollableCardList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Map<String, Duration>? countdowns;

  const ScrollableCardList({super.key, required this.items, this.countdowns});

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item['title'] as String;
          final countdown = countdowns?[title] ?? Duration.zero;
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  width: 250, // Adjust width to make the cards wider
                  margin: const EdgeInsets.symmetric(
                      horizontal:
                          16), // Increase margin to show a bit of the next card
                  child: Card(
                    color: Colors.white, // Set background color to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2, // Adjust elevation to add subtle shadow
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['venue'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          if (countdowns != null) const SizedBox(height: 8),
                          if (countdowns != null)
                            Text(
                              'Time remaining: ${_formatDuration(countdown!)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }
}
