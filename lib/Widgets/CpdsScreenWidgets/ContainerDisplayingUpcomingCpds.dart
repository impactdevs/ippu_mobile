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
                                SizedBox(height: size.height * 0.012),
                                Container(
                                  height: size.height * 0.089,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        const Color.fromARGB(255, 42, 129, 201),
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
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.03),
                                              child: Text(
                                                item.topic
                                                    .split(' ')
                                                    .take(4)
                                                    .join(' '),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: size.height * 0.014,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: size.width * 0.01),
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
                                                  extractDate(item.startDate),
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
                                                const Text("Rate",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Text(
                                                  item.type,
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
                                SizedBox(height: size.height * 0.018),
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
