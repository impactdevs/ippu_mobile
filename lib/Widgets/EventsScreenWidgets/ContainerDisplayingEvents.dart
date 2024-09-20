import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/SingleEventDisplay.dart';
import 'package:ippu/models/AllEventsModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class ContainerDisplayingEvents extends StatefulWidget {
  const ContainerDisplayingEvents({super.key});

  @override
  State<ContainerDisplayingEvents> createState() =>
      _ContainerDisplayingEventsState();
}

class _ContainerDisplayingEventsState extends State<ContainerDisplayingEvents>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _showBackToTopButton = false;
  late Future<List<AllEventsModel>> eventDataFuture;
  List<AllEventsModel> _allEvents = [];
  List<AllEventsModel> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    eventDataFuture = fetchAllEvents();
    _scrollController.addListener(_updateScrollVisibility);
  }

  void _updateScrollVisibility() {
    setState(() {
      _showBackToTopButton = _scrollController.offset >
          _scrollController.position.maxScrollExtent / 2;
    });
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AllEventsModel>> fetchAllEvents() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/events/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];

        log("events data: $eventData");
        List<AllEventsModel> eventsData = eventData.map((item) {
          if (item['points'] == null) {
            item['points'] = '0';
          }
          return AllEventsModel(
            id: item['id'].toString(),
            name: item['name'] ?? '',
            start_date: item['start_date'] ?? '',
            end_date: item['end_date'] ?? '',
            normal_rate: item['rate'] ?? '',
            attandence_request: item['attendance_request'] ?? '',
            member_rate: item['member_rate'] ?? '',
            points:
                item['points'].toString(), // Convert points to string if needed
            attachment_name: item['attachment_name'] ?? '',
            banner_name: item['banner_name'] ?? '',
            details: item['details'] ?? '',
            status: item['status'] ?? '',
          );
        }).toList();

        // Sort events by start_date in descending order (newest first)
        eventsData.sort((a, b) => b.start_date.compareTo(a.start_date));

        setState(() {
          _allEvents = eventsData;
          _filteredEvents = eventsData;
        });

        return eventsData;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      return []; // Return an empty list or handle the error in your UI
    }
  }

  void _filterEvents(String query) {
    final filteredEvents = _allEvents.where((event) {
      final eventNameLower = event.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return eventNameLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredEvents = filteredEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: _showBackToTopButton,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 42, 129, 201),
          onPressed: _scrollToTop,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: size.height * 0.012,
                right: size.height * 0.012,
                top: size.height * 0.012),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterEvents,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: size.height * 0.004,
                          horizontal: size.width * 0.035),
                      labelText: 'Search Events by name',
                      labelStyle: GoogleFonts.lato(
                          fontSize: size.height * 0.018, color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text;
                      _filterEvents(_searchQuery);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                        horizontal: size.width * 0.04),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.022,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          // Padding(
          //   padding: EdgeInsets.only(left: size.height * 0.020),
          //   child: Text(
          //     "( Scroll to see more Events and click on the Event to see more details )",
          //     style: GoogleFonts.lato(
          //       fontSize: size.height * 0.012,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.lightBlue.withOpacity(0.5),
          //     ),
          //   ),
          // ),
          // const Divider(),
          Expanded(
            child: FutureBuilder<List<AllEventsModel>>(
              future: eventDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        Image(image: AssetImage('assets/no_data.png')),
                        Text("Check your internet connection")
                      ],
                    ),
                  );
                } else {
                  final data = _filteredEvents;
                  if (data.isNotEmpty) {
                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        // Ensure the properties accessed here match the structure of your API response
                        final eventName = item.name;
                        final startDate = item.start_date;
                        final endData = item.end_date;
                        final description = item.details;
                        final attendanceRequest = item.attandence_request;
                        final rate = item.normal_rate;
                        final eventId = item.id.toString();
                        final imageLink = item.banner_name;
                        final points = item.points.toString();
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return SingleEventDisplay(
                                  id: eventId.toString(),
                                  attendance_request: attendanceRequest,
                                  points: points.toString(),
                                  normal_rate: rate,
                                  description: description,
                                  startDate: startDate,
                                  endDate: endData,
                                  member_rate: item.member_rate,
                                  imagelink:
                                      'https://staging.ippu.org/storage/banners/$imageLink',
                                  eventName: eventName,
                                );
                              }),
                            ).then((value) {
                              setState(() {
                                eventDataFuture = fetchAllEvents();
                              });
                            });
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.01,
                              horizontal: size.width * 0.05,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: Image.network(
                                    'https://staging.ippu.org/storage/banners/$imageLink',
                                    height: size.height * 0.2,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(size.height * 0.02),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventName,
                                        style: GoogleFonts.lato(
                                          fontSize: size.height * 0.018,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: size.height * 0.02,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Text(
                                                    "Start Date",
                                                    style: GoogleFonts.lato(
                                                      fontSize:
                                                          size.height * 0.015,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                extractDate(startDate),
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.015,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: size.height * 0.02,
                                                    color: Colors.amber,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Text(
                                                    "Points",
                                                    style: GoogleFonts.lato(
                                                      fontSize:
                                                          size.height * 0.015,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                points,
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.015,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.info,
                                                    size: size.height * 0.02,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Text(
                                                    "Status",
                                                    style: GoogleFonts.lato(
                                                      fontSize:
                                                          size.height * 0.015,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                item.getStatus(),
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.015,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  String extractDate(String fullDate) {
    // Split the full date at the 'T' to separate the date and time
    List<String> parts = fullDate.split('T');

    // Return the date part
    return parts[0];
  }
}
