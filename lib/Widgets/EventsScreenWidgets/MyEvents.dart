import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/AttendedEventSIngleDisplayScreen.dart';
import 'package:ippu/models/MyAttendedEvents.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  late Future<List<MyAttendedEvents>> eventDataFuture;

  @override
  void initState() {
    super.initState();
    eventDataFuture = fetchEventsData();
  }

  Future<List<MyAttendedEvents>> fetchEventsData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl =
        'https://staging.ippu.org/api/attended-events/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];
        List<MyAttendedEvents> eventsData = eventData.map((item) {
          if (item['points'] == null) {
            item['points'] = '0';
          }
          return MyAttendedEvents(
            id: item['id'].toString(),
            name: item['name'] ?? '',
            start_date: item['start_date'] ?? '',
            end_date: item['end_date'] ?? '',
            rate: item['rate'] ?? '',
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.006,
            ),
            Center(
              child: SizedBox(
                height: size.height * 0.70,
                width: size.width * 0.9,
                child: FutureBuilder<List<MyAttendedEvents>>(
                  future: eventDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                            "Check your internet connection to load the data"),
                      );
                    } else if (snapshot.hasData) {
                      List<MyAttendedEvents> eventData = snapshot.data!;
                      return ListView.builder(
                        itemCount: eventData.length,
                        itemBuilder: (context, index) {
                          MyAttendedEvents data = eventData[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: Image.network(
                                    "https://staging.ippu.org/storage/banners/${data.banner_name}",
                                    height: size.height * 0.22,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.name,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.height * 0.018,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Start Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(data.start_date))}",
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.016,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                "End Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(data.end_date))}",
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.016,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Points",
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: size.height * 0.016,
                                                ),
                                              ),
                                              Text(
                                                data.points,
                                                style: GoogleFonts.lato(
                                                  fontSize: size.height * 0.016,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[800],
                                            padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.012,
                                              horizontal: size.width * 0.08,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return AttendedEventSIngleDisplayScreen(
                                                eventId: data.id,
                                                start_date: data.start_date,
                                                end_date: data.end_date,
                                                details: data.details,
                                                points: data.points,
                                                rate: data.rate,
                                                name: data.name,
                                                imageLink: data.banner_name,
                                                status: data.status,
                                              );
                                            }));
                                          },
                                          child: Text(
                                            'View Details',
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: size.height * 0.016,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
