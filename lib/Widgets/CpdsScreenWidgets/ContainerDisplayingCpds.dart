import 'package:flutter/material.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/CpdsSingleEventDisplay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ippu/models/CpdModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class ContainerDisplayingCpds extends StatefulWidget {
  const ContainerDisplayingCpds({super.key});

  @override
  State<ContainerDisplayingCpds> createState() =>
      _ContainerDisplayingCpdsState();
}

class _ContainerDisplayingCpdsState extends State<ContainerDisplayingCpds>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _showBackToTopButton = false;

  late Future<List<CpdModel>> cpdDataFuture;
  late List<CpdModel> fetchedData = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollVisibility);
    cpdDataFuture = fetchAllCpds().then((data) {
      fetchedData = data;
      return data;
    });
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

  Future<List<CpdModel>> fetchAllCpds() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final apiUrl = 'https://ippu.org/api/cpds/${userData?.id}';
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
        cpdData.sort((a, b) => b.startDate.compareTo(a.startDate));
        return cpdData;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      return [];
    }
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.0038,
                    horizontal: size.width * 0.035),
                labelText: 'Search CPDS by name',
                labelStyle: GoogleFonts.lato(
                    fontSize: size.height * 0.018, color: Colors.grey),
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
                  icon: const Icon(
                    Icons.search,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            ),
          ),
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
                  return const Center(
                    child: Image(
                        image: AssetImage('assets/check_data_connection.png')),
                  );
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
                        final activityName = item.topic;
                        if (_searchQuery.isEmpty ||
                            activityName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())) {
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return CpdsSingleEventDisplay(
                                    attendance_request: item.attendance_request,
                                    content: item.content,
                                    target_group: item.targetGroup,
                                    startDate: item.startDate,
                                    endDate: item.endDate,
                                    rate: item.location.toString(),
                                    type: item.type,
                                    cpdId: item.id.toString(),
                                    attendees: item.points,
                                    imagelink:
                                        'https://ippu.org/storage/banners/${item.banner}',
                                    cpdsname: activityName,
                                    normal_rate: item.normalRate,
                                    member_rate: item.membersRate,
                                    location: item.location,
                                  );
                                }),
                              ).then((value) {
                                setState(() {
                                  cpdDataFuture = fetchAllCpds();
                                });
                              });
                            },
                            child: Card(
                              color: Colors.white,
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
                                      'https://ippu.org/storage/banners/${item.banner}',
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
                                            fontSize: size.height * 0.018,
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
                                                  extractDate(item.startDate),
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
                                                  item.points,
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
                                                      Icons.info,
                                                      size: size.height * 0.02,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
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
                          return Container();
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
    List<String> parts = fullDate.split('T');
    return parts[0];
  }
}
