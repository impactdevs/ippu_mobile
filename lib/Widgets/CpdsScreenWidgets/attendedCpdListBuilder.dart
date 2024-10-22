import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/AttendedSingleCpdDisplay.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/AttendedCpdModel.dart';

class attendedCpdListBuilder extends StatefulWidget {
  const attendedCpdListBuilder({super.key});

  @override
  State<attendedCpdListBuilder> createState() => _attendedCpdListBuilderState();
}

class _attendedCpdListBuilderState extends State<attendedCpdListBuilder> {
  late Future<List<AttendedCpdModel>> CpdDataFuture;

  @override
  void initState() {
    super.initState();
    CpdDataFuture = fetchCpdData();
  }

  Future<List<AttendedCpdModel>> fetchCpdData() async {
    AuthController authController = AuthController();
    try {
      final response = await authController.getMyCpds();

      List<AttendedCpdModel> eventsData = response.map((item) {
        return AttendedCpdModel(
          id: item['id'].toString(),
          code: item['code'] ?? "",
          topic: item['topic'] ?? "",
          content: item['content'] ?? "",
          hours: item['hours'] ?? "",
          points: item['points'] ?? "",
          targetGroup: item['target_group'] ?? "", // Use correct key name
          location: item['location'] ?? "",
          startDate: item['start_date'] ?? "", // Use correct key name
          endDate: item['end_date'] ?? "", // Use correct key name
          normalRate: item['normal_rate'] ?? "", // Use correct key name
          membersRate: item['members_rate'] ?? "", // Use correct key name
          resource: item['resource'] ?? "",
          status: item['status'] ?? "",
          type: item['type'] ?? "",
          banner: item['banner'] ?? "",
          attendance_status: item['attendance_status'] ?? "",
        );
      }).toList();
      return eventsData;
    } catch (error) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<List<AttendedCpdModel>>(
      future: CpdDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Check your internet connection to load the data"),
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
        } else if (snapshot.hasData) {
          List<AttendedCpdModel> CpdData = snapshot.data!;
          return ListView.builder(
            itemCount: CpdData.length,
            itemBuilder: (context, index) {
              AttendedCpdModel data = CpdData[index];
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: size.height * 0.01,
                      horizontal: size.width * 0.05,
                    ),
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
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            "https://ippu.org/storage/banners/${data.banner}",
                            height: size.height * 0.22,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.height * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.topic,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
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
                                      Text(
                                        "Start Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(data.startDate))}",
                                        style: GoogleFonts.lato(
                                          fontSize: size.height * 0.017,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        "End Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(data.endDate))}",
                                        style: GoogleFonts.lato(
                                          fontSize: size.height * 0.017,
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
                                          fontSize: size.height * 0.018,
                                        ),
                                      ),
                                      Text(
                                        data.points,
                                        style: GoogleFonts.lato(
                                          fontSize: size.height * 0.018,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.014,
                                      horizontal: size.width * 0.1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AttendedSingleCpdDisplay(
                                        eventId: data.id,
                                        content: data.content,
                                        target_group: data.targetGroup,
                                        startDate: data.startDate,
                                        endDate: data.endDate,
                                        type: data.type,
                                        location: data.location,
                                        imagelink:
                                            'https://ippu.org/storage/banners/${data.banner}',
                                        cpdsname: data.topic,
                                        status: data.attendance_status,
                                      );
                                    }));
                                  },
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: size.height * 0.017,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
