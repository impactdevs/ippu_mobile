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
        return eventsData;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      return []; // Return an empty list or handle the error in your UI
    }
  }

//
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.004,
                    horizontal: size.width * 0.035),
                labelText: 'Search Events by name',
                labelStyle: GoogleFonts.lato(
                    fontSize: size.height * 0.022, color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: size.height * 0.020),
            child: Text(
              "( Scroll to see more Events and click on the Event to see more details )",
              style: GoogleFonts.lato(
                fontSize: size.height * 0.012,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue.withOpacity(0.5),
              ),
            ),
          ),
          const Divider(),
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
                  final data = snapshot.data;
                  if (data != null) {
                    return ListView.builder(
                      // controller: _scrollController,
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
                        if (_searchQuery.isEmpty ||
                            eventName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())) {
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
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    right: size.height * 0.009,
                                    left: size.height * 0.009,
                                  ),
                                  height: size.height * 0.35,
                                  width: size.width * 0.85,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: const Offset(0.8, 1.0),
                                        blurRadius: 4.0,
                                        spreadRadius: 0.2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.5)),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'https://staging.ippu.org/storage/banners/$imageLink'),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.014),
                                Container(
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        const Color.fromARGB(255, 42, 129, 201),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: const Offset(0.8, 1.0),
                                        blurRadius: 4.0,
                                        spreadRadius: 0.2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: size.height * 0.008),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: size.width * 0.03),
                                                child: Text(
                                                  item.name.split(' ').take(4).join(
                                                      ' '), // Display only the first two words
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        size.height * 0.014,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: size.width * 0.03),
                                              child: Icon(
                                                Icons.read_more,
                                                size: size.height * 0.02,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.white,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_month,
                                                      size: size.height * 0.02,
                                                      color: Colors.white,
                                                    ),
                                                    const Text(
                                                      "Start Date",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  extractDate(item.start_date),
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.height * 0.008,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Points",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Text(
                                                  item.points,
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.height * 0.008,
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Status",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Text(
                                                  item.getStatus(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.height * 0.01,
                                                      color: Colors.white),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.022),
                              ],
                            ),
                          );
                        } else {
                          return Container(); // Return an empty container for non-matching items
                        }
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
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
