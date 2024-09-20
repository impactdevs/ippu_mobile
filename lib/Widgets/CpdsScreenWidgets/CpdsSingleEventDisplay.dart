import 'dart:convert';
import 'dart:developer';

import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/env.dart' as env;

class CpdsSingleEventDisplay extends StatefulWidget {
  final String imagelink;
  final String cpdsname;
  final String startDate;
  final String endDate;
  final String type;
  final String location;
  final bool attendance_request;
  final String attendees;
  final String content;
  final String cpdId;
  final String rate;
  final String target_group;
  final String normal_rate;
  final String member_rate;
  const CpdsSingleEventDisplay(
      {super.key,
      required this.attendance_request,
      required this.rate,
      required this.cpdId,
      required this.location,
      required this.startDate,
      required this.endDate,
      required this.type,
      required this.content,
      required this.target_group,
      required this.attendees,
      required this.cpdsname,
      required this.imagelink,
      required this.normal_rate,
      required this.member_rate});

  @override
  State<CpdsSingleEventDisplay> createState() => _CpdsSingleEventDisplayState();
}

class _CpdsSingleEventDisplayState extends State<CpdsSingleEventDisplay> {
  String attendance_status = "";

  String generateDeepLink() {
    // Generate the deep link
    return "https://staging.ippu.org/myevents";
  }

  Future<UserData> loadProfile() async {
    AuthController authController = AuthController();
    try {
      final response = await authController.getProfile();
      if (response.containsKey("error")) {
        throw Exception("The return is an error");
      } else {
        if (response['data'] != null) {
          // Access the user object directly from the 'data' key
          Map<String, dynamic> userData = response['data'];

          UserData profile = UserData(
            id: userData['id'],
            name: userData['name'] ?? "",
            email: userData['email'] ?? "",
            gender: userData['gender'] ?? "",
            dob: userData['dob'] ?? "",
            membership_number: userData['membership_number'] ?? "",
            address: userData['address'] ?? "",
            phone_no: userData['phone_no'] ?? "",
            alt_phone_no: userData['alt_phone_no'] ?? "",
            nok_name: userData['nok_name'] ?? "",
            nok_address: userData['nok_address'] ?? "",
            nok_phone_no: userData['nok_phone_no'] ?? "",
            points: userData['points'] ?? "",
            subscription_status: userData['subscription_status'].toString(),
            profile_pic: userData['profile_pic'] ??
                "https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png",
            membership_expiry_date:
                userData['subscription_status'].toString() == "false"
                    ? ""
                    : userData['latest_membership']["expiry_date"],
          );

          return profile;
        } else {
          // Handle the case where the 'data' field in the API response is null
          throw Exception("You currently have no data");
        }
      }
    } catch (error) {
      throw Exception("An error occurred while loading the profile");
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    int status = showRegisterButton();

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          widget.cpdsname,
          style: GoogleFonts.lato(
            textStyle:
                const TextStyle(color: Colors.white), // Set text color to white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: loadProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final profileData = snapshot.data as UserData;
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          // margin: EdgeInsets.only(right:size.height*0.009, left:size.height*0.009),
                          height: size.height * 0.46,
                          width: size.width * 0.84,
                          decoration: BoxDecoration(
                              // border: Border.all(
                              //   // color: Colors.white,
                              // ),
                              image: DecorationImage(
                                  image: NetworkImage(widget.imagelink))),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.06,
                                top: size.height * 0.004),
                            child: Text(
                              "Description",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons
                                  .share, // Use the share icon from Material Icons
                              color: Colors.blue, // Set the color of the icon
                            ),
                            onPressed: () {
                              //generate the deep link to this event
                              //share the deep link
                              final deepLink = generateDeepLink();

                              String message = "🎉 ${widget.cpdsname}🎉\n\n"
                                  "📅 Event Date: ${widget.startDate} - ${widget.endDate}\n\n"
                                  "📌 To book for the event attendance, click on the link below:\n"
                                  "$deepLink";
                              Share.share(message);
                            },
                          ),
                        ],
                      ),

                      Padding(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              top: size.height * 0.0008),
                          child: Html(
                            data: widget.content,
                            style: {
                              "p": Style(
                                // Apply style to <p> tags
                                fontSize: FontSize(16.0),
                                color: Colors.black,
                                // Add more style properties as needed
                              ),
                              "h1": Style(
                                // Apply style to <h1> tags
                                fontSize: FontSize(24.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                // Add more style properties as needed
                              ),
                              // Add more style definitions for other HTML elements
                            },
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * 0.06, top: size.height * 0.016),
                        child: const Text(
                          "Target Group",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * 0.06,
                            right: size.width * 0.06,
                            top: size.height * 0.0016),
                        child: Text(
                          widget.target_group,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.016,
                      ),
                      // container displaying the start, end rate and location
                      Container(
                        margin: EdgeInsets.only(left: size.width * 0.03),
                        height: size.height * 0.08,
                        width: size.width * 0.96,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.4, 0.2),
                              blurRadius: 0.2,
                              spreadRadius: 0.4,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: size.height * 0.017),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Start Date",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    extractDate(widget.startDate),
                                    style: TextStyle(
                                        fontSize: size.height * 0.012),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "End Date",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    extractDate(widget.endDate),
                                    style: TextStyle(
                                        fontSize: size.height * 0.012),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Type",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    widget.type,
                                    style: TextStyle(
                                        fontSize: size.height * 0.012),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Location",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    widget.location,
                                    style: TextStyle(
                                        fontSize: size.height * 0.012),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //
                      SizedBox(
                        height: size.height * 0.022,
                      ),
                      Center(
                        child: (() {
                          switch (status) {
                            case 1:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            case 2:
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.all(size.height * 0.024),
                                ),
                                onPressed: () {
                                  // _handlePaymentInitialization(profileData.name,
                                  //     profileData.email, profileData.phone_no!);
                                  _showPaymentDialog(size, profileData);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.12),
                                  child: Text(
                                    'Book Attendance',
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          color: Colors
                                              .white), // Set text color to white
                                    ),
                                  ),
                                ),
                              );
                            case 3:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            case 4:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            case 5:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            case 6:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            case 7:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            case 8:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            case 9:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            case 10:
                              return Text(
                                attendance_status,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            default:
                              return Container(); // Handle other cases if needed
                          }
                        })(),
                      ),
                      SizedBox(
                        height: size.height * 0.022,
                      ),
                      //
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text("An error occured while getting details"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  final TextEditingController _amountController = TextEditingController();

  // Function to show the payment mode dialog
  void _showPaymentDialog(Size size, profile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Payment Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Cash'),
                onTap: () async {
                  sendAttendanceRequest(widget.cpdId);
                  Navigator.pop(context, true);
                },
              ),
              ListTile(
                title: const Text('Cashless'),
                onTap: () {
                  Navigator.pop(context, true);
                  // Show a dialog to enter the amount for cashless payment
                  _showCashlessPaymentDialog(size, profile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the dialog for cashless payment
  void _showCashlessPaymentDialog(Size size, profile) {
    _amountController.text =
        widget.normal_rate.toString(); // Set default to event fee
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Amount to Pay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Trigger the Flutterwave payment process
                _handlePaymentInitialization(
                    profile.name, profile.email, profile.phone_no.toString());
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  String extractDate(String fullDate) {
    List<String> parts = fullDate.split('T');

    // Return the date part
    return parts[0];
  }

  //function to decide whether to show the register button or not, or show missed or already registered for the event
  //based on the attendance_request and the start and end date of the event
  int showRegisterButton() {
    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime.parse(widget.startDate);
    DateTime endDate = DateTime.parse(widget.endDate);
    int statusCode = 0;

    //check if the event is still valid
    if (widget.attendance_request == false) {
      if (currentDate.isAfter(endDate)) {
        attendance_status = "You missed this cpd";
        statusCode = 1;
      }

      if (currentDate.isBefore(startDate)) {
        {
          //show attend button
          attendance_status = "Pending";
          statusCode = 2;
        }
      }

      if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        attendance_status =
            "This cpd is happening but you did not book for attendance";
        statusCode = 3;
      }

      //check if the date is at the same momement
      if (currentDate.isAtSameMomentAs(startDate)) {
        attendance_status =
            "This cpd is happening but you did not book for it's attendance";
        statusCode = 4;
      }

      if (currentDate.isAtSameMomentAs(endDate)) {
        attendance_status =
            "This cpd is happening but you did not book for it's attendance";
        statusCode = 5;
      }
    } else {
      if (currentDate.isAfter(endDate)) {
        attendance_status = "Thank you For Attending the cpd";
        statusCode = 6;
      }

      if (currentDate.isBefore(startDate)) {
        {
          attendance_status = "Already booked to attend the cpd";
          statusCode = 7;
        }
      }

      if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        attendance_status =
            "Thank you for registering for the cpd, it is happening now";
        statusCode = 8;
      }

      //check if the date is at the same momement
      if (currentDate.isAtSameMomentAs(startDate)) {
        attendance_status =
            "Thank you for registering for the cpd, it is happening now";
        statusCode = 9;
      }

      if (currentDate.isAtSameMomentAs(endDate)) {
        attendance_status =
            "Thank you for registering for the cpd, it is happening now";
        statusCode = 10;
      }
    }

    return statusCode;
  }

  void shareCPD(String CPDName, String description) {
    Share.share('Check out this CPD event: $CPDName\n\n$description');
  }

  _handlePaymentInitialization(
      String fullName, String email, String phoneNumber) async {
    final Customer customer = Customer(
      name: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: env.Env.FLW_PUBLIC_KEY,
        currency: "UGX",
        redirectUrl: 'https://staging.ippu.org/login',
        txRef: Uuid().v1(),
        amount: isMember() ? widget.member_rate : widget.normal_rate,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(
            title: "IPPU PAYMENT",
            description: "Being payment for ${widget.cpdsname} booking",
            logo:
                "https://ippu.or.ug/wp-content/uploads/2020/03/cropped-Logo-192x192.png"),
        isTestMode: false);
    final ChargeResponse response = await flutterwave.charge();
    var message;
    if (response.success == true) {
      message = "Payment successful,\n thank you!";
      sendAttendanceRequest(widget.cpdId);
    } else {
      message = "Payment failed,\n try again later";
    }
    showLoading(message);

    setState(() {});
    print("${response.toJson()}");
  }

  Future<void> showLoading(String message) {
    return showDialog(
      context: context,
      builder: (context) => CleanDialog(
        title: 'success',
        content: message,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        actions: [
          CleanDialogActionButtons(
            actionTitle: 'OK',
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void sendAttendanceRequest(String cpdID) async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final userId = userData?.id; // Replace with your actual user ID

    final apiUrl = Uri.parse('https://staging.ippu.org/api/cpds/attend');

    // Create a map of the data to send
    final Map<String, dynamic> requestBody = {
      'user_id': userId,
      'cpd_id': cpdID,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Handle a successful API response
        showBottomNotification("Booking successful......");
        const CircularProgressIndicator();
        Navigator.pop(context);
      } else {
        // Handle errors or unsuccessful response
        showBottomNotification("Booking failed....!!!");
      }
    } catch (error) {
      showBottomNotification("Booking failed.....!!!");
    }
  }

  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  bool isMember() {
    final expirely_date = Provider.of<UserProvider>(context, listen: false)
        .user
        ?.membership_expiry_date;
    log("expiry date: $expirely_date");
    //check if the user is a member
    if (expirely_date != null && expirely_date.isNotEmpty) {
      DateTime currentDate = DateTime.now();
      DateTime expiryDate = DateTime.parse(expirely_date);
      if (currentDate.isBefore(expiryDate)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
