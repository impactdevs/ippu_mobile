import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/CommunicationScreenWidgets/SingleCommunicationDisplayScreen.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/CommunicationModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ContainerDisplayingCommunications extends StatefulWidget {
  const ContainerDisplayingCommunications({super.key});

  @override
  State<ContainerDisplayingCommunications> createState() =>
      _ContainerDisplayingCommunicationsState();
}

class _ContainerDisplayingCommunicationsState
    extends State<ContainerDisplayingCommunications>
    with TickerProviderStateMixin {
  int maxWords = 40;
  int unreadCount = 0;
  int readCount = 0;

  final ScrollController _scrollController = ScrollController();
  AuthController authController = AuthController();
  bool _showBackToTopButton = false;
  late Future<List<CommunicationModel>> eventDataFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollVisibility);
    eventDataFuture = getAllCommunications();
  }

  void _updateScrollVisibility() {
    setState(() {
      _showBackToTopButton = _scrollController.offset >
          _scrollController.position.maxScrollExtent / 2;
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
      body: FutureBuilder<List<dynamic>>(
        future: eventDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;

            unreadCount = data.where((item) => !item.status).length;
            readCount = data.where((item) => item.status).length;

            return ListView.builder(
              // controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return InkWell(
                  onTap: () {
                  },
                  child: InkWell(
                    onTap: () {
                      // Mark the communication as read
                      if (item.status == false) {
                        markAsRead(item.id);
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SingleCommunicationDisplayScreen(
                          communicationtitle: item.title,
                          communicationbody: item.message,
                          communicationdate: extractDate(item.created_at),
                        );
                      }));
                    },
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.008),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: size.height * 0.009,
                          ),
                          width: size.width * 0.95,
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 0.06,
                                  top: size.height * 0.02,
                                ),
                                child: Text(
                                  "${item.title}",
                                  style: GoogleFonts.roboto(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: const Color.fromARGB(255, 7, 63, 109),
                                  ),
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 0.066,
                                  top: size.height * 0.0025,
                                  right: size.width * 0.04,
                                  bottom: size.height * 0.008,
                                ),
                                child: Html(
                                  data: shortenText(item.message, maxWords),
                                  style: {
                                    "p": Style(
                                      // Apply style to <p> tags
                                      fontSize: FontSize(size.height * 0.009),
                                      color: Colors.black,
                                      // Add more style properties as needed
                                    ),
                                    "h1": Style(
                                      // Apply style to <h1> tags
                                      fontSize: FontSize(size.height * 0.009),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      // Add more style properties as needed
                                    ),
                                    // Add more style definitions for other HTML elements
                                  },
                                ),
                                // Text(
                                //   shortenText(item['message'], maxWords),
                                // ),
                              ),
                              const Divider(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.08),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date",
                                          style: GoogleFonts.lato(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          extractDate(item.created_at),
                                          style: GoogleFonts.roboto(
                                            fontSize: size.height * 0.016,
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Icon(Icons.read_more),
                                        Text(
                                          item.status ? "Read" : "Unread",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold,
                                            color: item.status
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.008)
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.03)
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String shortenText(String text, int maxLength) {
    List<String> words = text.split(' ');
    if (words.length <= maxLength) {
      return text;
    } else {
      return '${words.sublist(0, maxLength).join(' ')}...';
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  String extractDate(String fullDate) {
    // Split the full date at the 'T' to separate the date and time
    List<String> parts = fullDate.split('T');

    // Return the date part
    return parts[0];
  }

  Future<List<CommunicationModel>> getAllCommunications() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/communications/${userData?.id}';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'].values.toList();
        List<CommunicationModel> eventsData = eventData.map((item) {
          return CommunicationModel(
            id: item['id'].toString(),
            title: item['title'],
            status: item['status'],
            message: item['message'],
            created_at: item['created_at'],
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

  Future<void> markAsRead(String messageId) async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    const apiUrl = 'https://staging.ippu.org/api/mark-as-read';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    // Define the body
    final body = {
      'user_id': userData?.id.toString(),
      'message_id': messageId,
    };

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        // Communication marked as read successfully
      } else {
        throw Exception('Failed to mark communication as read');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
    }
  }
}
