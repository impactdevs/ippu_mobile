import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Screens/CommunicationScreen.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/CpdsSingleEventDisplay.dart';
import 'package:flutter/material.dart';
import 'package:ippu/models/CpdModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class attendedCpdListHorizontalView extends StatefulWidget {
  const attendedCpdListHorizontalView({super.key});

  @override
  State<attendedCpdListHorizontalView> createState() => _attendedCpdListHorizontalViewState();
}

class _attendedCpdListHorizontalViewState extends State<attendedCpdListHorizontalView> {
  
  
 late Future<List<CpdModel>> cpdDataFuture;
   @override
  void initState() {
    super.initState();
        cpdDataFuture=fetchUpcomingCpds();
 
  }
 // function for fetching cpds 
  Future<List<CpdModel>> fetchUpcomingCpds() async {
  final userData = Provider.of<UserProvider>(context, listen: false).user;

  // Define the URL with userData.id
  final apiUrl = 'https://ippu.org/api/upcoming-cpds/${userData?.id}';

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
          // 
          id:item['id'].toString(),
          code:item['code']??"",
          topic: item['topic']??"",
          content: item['content']??"",
          hours: item['hours']??"",
          points: item['points']??"",
          targetGroup:item['target_group']??"",
          location:item['location']??"",
          startDate:item['start_date']??"",
          endDate:item['end_date']??"",
          normalRate:item['normal_rate']??"",
          membersRate:item['members_rate']??"",
          resource:item['resource']??"",
          status:item['status']??"",
          type:item['type']??"",
          banner:item['banner']??"",
          attendance_request:item['attendance_request']??"",
          attendance_status:item['attendance_status']??""
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
    return FutureBuilder<List<CpdModel>>(
              future: cpdDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // 
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return const CommunicationScreen();
                      }));
                    },
                    child: Container(
                      height: size.height*0.04,
                      width: size.width*0.10,
                      decoration: BoxDecoration(
                        border: Border.all(
                        color: Colors.grey.withOpacity(0.4)
                        ),
                        //  image: DecorationImage(image: AssetImage("assets/checkcommunication.png")),
                        color: Colors.lightBlue[50]
                      ),
                      child: Column(children: [
                        SizedBox(
                          height: size.height*0.04,
                        ),
                        Text("Check out some of our communications"
                       ,style: GoogleFonts.lato(
                        fontSize: size.width*0.028
                       )
                        ),
                        SizedBox(
                          height: size.height*0.02,
                        ),
                        Container(
                      height: size.height*0.2,
                      width: size.width*0.65,
                      decoration: BoxDecoration(
                        // border: Border.all(
                        // color: Colors.grey.withOpacity(0.4)
                        // ),
                         image: const DecorationImage(image: AssetImage("assets/checkcommunication.png")),
                        color: Colors.lightBlue[50]
                      )
                      )
                      ]),
                    ),
                  );
                  // 
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // return Center(child:  Text('No data available, Or check internet connection'));
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                       return const CommunicationScreen();
                      }));
                    },
                    child: Container(
                      height: size.height*0.04,
                      width: size.width*0.10,
                      decoration: BoxDecoration(
                        border: Border.all(
                        color: Colors.grey.withOpacity(0.4)
                        ),
                        //  image: DecorationImage(image: AssetImage("assets/checkcommunication.png")),
                        color: Colors.lightBlue[50]
                      ),
                      child: Column(children: [
                        SizedBox(
                          height: size.height*0.04,
                        ),
                        Text("Check out some of our communications"
                       ,style: GoogleFonts.lato(
                        fontSize: size.width*0.028
                       )
                        ),
                        SizedBox(
                          height: size.height*0.02,
                        ),
                        Container(
                      height: size.height*0.2,
                      width: size.width*0.65,
                      decoration: BoxDecoration(
                        // border: Border.all(
                        // color: Colors.grey.withOpacity(0.4)
                        // ),
                         image: const DecorationImage(image: AssetImage("assets/checkcommunication.png")),
                        color: Colors.lightBlue[50]
                      )
                      )
                      ]),
                    ),
                  );
                } else {
                  final data = snapshot.data;
                  if (data != null) {
                    return ListView.builder(
                      // controller: _scrollController,
                      // scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
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
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return CpdsSingleEventDisplay(
                                    attendance_request: attendanceRequest ,
                                    content: content,
                                    target_group: targetGroup,
                                    startDate: startDate,
                                    endDate: endDate,
                                    rate: location.toString(),
                                    type: type,
                                    cpdId:cpdId.toString(),
                                    attendees: points,
                                    imagelink: 'https://ippu.org/storage/banners/$imageLink',
                                    cpdsname: activityName,
                                    normal_rate: normal_rate,
                                    member_rate: member_rate,
                                    location: location
                                  );
                                }),
                              );
                            },
                        child: Container(
                                height: size.height * 0.35,
                                width: size.width * 0.85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                          child: Column(
                            children: [
                              Text("Upcoming Cpds",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 42, 129, 201),
                              ),
                              ),
                              SizedBox(height: size.height*0.010,),
                              Container(
                                margin: EdgeInsets.only(
                                  right: size.height * 0.009,
                                  left: size.height * 0.009,
                                ),
                                height: size.height * 0.28,
                                width: size.width * 0.62,
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
                                    color: Colors.grey.withOpacity(0.5)
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage('https://ippu.org/storage/banners/$imageLink'),
                                  ),
                                ),
                              ),
                              Text("Click to read more",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height*0.015,
                                color: const Color.fromARGB(255, 42, 129, 201),
                              )),
                            ],
                          ),
                        ),
                          );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
              },
            );          
  }
}
