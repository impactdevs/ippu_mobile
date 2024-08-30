import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/SingleEventDisplay.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/AllEventsModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class ContainerDisplayingUpcomingEvents extends StatefulWidget {
  const ContainerDisplayingUpcomingEvents({super.key});

  @override
  State<ContainerDisplayingUpcomingEvents> createState() =>
      _ContainerDisplayingUpcomingEventsState();
}

class _ContainerDisplayingUpcomingEventsState
    extends State<ContainerDisplayingUpcomingEvents>
    with TickerProviderStateMixin {
  AuthController authController = AuthController();

  final ScrollController _scrollController = ScrollController();
  final String _searchQuery = '';

  late Future<List<AllEventsModel>> eventDataFuture;
  @override
  void initState() {
    super.initState();
    eventDataFuture = fetchUpComingEvents();
    _scrollController.addListener(_updateScrollVisibility);
  }

  void _updateScrollVisibility() {
    setState(() {});
  }

  // function fetching upcoming events
  Future<List<AllEventsModel>> fetchUpComingEvents() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl =
        'https://staging.ippu.org/api/upcoming-events/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: size.height * 0.020),
            child: Text(
              "( Scroll to see more Events and click on the Event to see more details )",
              style: GoogleFonts.lato(
                fontSize: size.height * 0.012,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.5),
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
                        final normal_rate = item.normal_rate;
                        final member_rate = item.member_rate;
                        final eventId = item.id.toString();
                        final imageLink = item.banner_name;
                        final points = item.points.toString();
                        if (_searchQuery.isEmpty ||
                            eventName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())) {
                          return InkWell(
                            onTap: () {
                              if (profileStatus == true) {
                                _showDialog();
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return SingleEventDisplay(
                                    id: eventId.toString(),
                                    attendance_request: attendanceRequest,
                                    points: points.toString(),
                                    normal_rate: normal_rate,
                                    member_rate: member_rate,
                                    description: description,
                                    startDate: extractDate(startDate),
                                    endDate: extractDate(endData),
                                    imagelink:
                                        'https://staging.ippu.org/storage/banners/$imageLink',
                                    eventName: eventName,
                                  );
                                }),
                              );
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

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Profile'),
          content:
              const Text('Please complete your profile to access this feature'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
