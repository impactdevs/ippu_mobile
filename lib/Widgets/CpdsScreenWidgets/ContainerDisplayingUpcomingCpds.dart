import 'package:flutter/material.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/CpdsSingleEventDisplay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ippu/models/CpdModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class ContainerDisplayingUpcomingCpds extends StatefulWidget {
  const ContainerDisplayingUpcomingCpds({super.key});

  @override
  State<ContainerDisplayingUpcomingCpds> createState() =>
      _ContainerDisplayingUpcomingCpdsState();
}

class _ContainerDisplayingUpcomingCpdsState
    extends State<ContainerDisplayingUpcomingCpds>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _showBackToTopButton = false;

  late Future<List<CpdModel>> cpdDataFuture;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollVisibility);
    cpdDataFuture = fetchUpcomingCpds();
  }

  void _updateScrollVisibility() {
    setState(() {
      _showBackToTopButton = _scrollController.offset >
          _scrollController.position.maxScrollExtent / 2;
    });
  }

  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // function for fetching cpds
  Future<List<CpdModel>> fetchUpcomingCpds() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/upcoming-cpds/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];
        List<CpdModel> cpdData = eventData.map((item) {
          return CpdModel(
            id: item['id'].toString(),
            code: item['code'] ?? "",
            topic: item['topic'] ?? "",
            content: item['content'] ?? "",
            hours: item['hours'] ?? "",
            points: item['points'] ?? "",
            targetGroup: item['target_group'] ?? "",
            location: item['location'] ?? "",
            startDate: item['start_date'] ?? "",
            endDate: item['end_date'] ?? "",
            normalRate: item['normal_rate'] ?? "",
            membersRate: item['members_rate'] ?? "",
            resource: item['resource'] ?? "",
            status: item['status'] ?? "",
            type: item['type'] ?? "",
            banner: item['banner'] ?? "",
            attendance_request: item['attendance_request'] ?? "",
            attendance_status: item['attendance_status'] ?? "",
          );
        }).toList();
        return cpdData;
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
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;

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
            padding: EdgeInsets.only(left: size.height * 0.020),
            child: Text(
              "( Scroll to see more CPDS and click on the CPD to see more details )",
              style: GoogleFonts.lato(
                fontSize: size.height * 0.012,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<CpdModel>>(
              future: cpdDataFuture,
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
                        final activityName = item.topic;
                        final points = item.points;
                        final startDate = item.startDate;
                        final endDate = item.endDate;
                        final content = item.content;
                        final attendanceRequest = item.attendance_request;
                        final normal_rate = item.normalRate;
                        final member_rate = item.membersRate;
                        final location = item.location;
                        final type = item.type;
                        final imageLink = item.banner;
                        final targetGroup = item.targetGroup;
                        final cpdId = item.id.toString();

                        if (_searchQuery.isEmpty ||
                            activityName
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
                                  return CpdsSingleEventDisplay(
                                    attendance_request: attendanceRequest,
                                    content: content,
                                    target_group: targetGroup,
                                    startDate: startDate,
                                    endDate: endDate,
                                    rate: location.toString(),
                                    type: type,
                                    cpdId: cpdId.toString(),
                                    attendees: points,
                                    imagelink:
                                        'https://staging.ippu.org/storage/banners/$imageLink',
                                    cpdsname: activityName,
                                    normal_rate: normal_rate,
                                    member_rate: member_rate,
                                    location: location,
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
                                          activityName,
                                          style: GoogleFonts.lato(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
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
                                                      Icons.location_on,
                                                      size: size.height * 0.02,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    Text(
                                                      "Location",
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
                                                  location,
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
