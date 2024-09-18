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
                                                        width:
                                                            size.width * 0.01),
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
                                                    fontSize:
                                                        size.height * 0.015,
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
                                                        width:
                                                            size.width * 0.01),
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
                                                    fontSize:
                                                        size.height * 0.015,
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
