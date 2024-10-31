import 'dart:convert';
import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/env.dart' as env;

class SingleEventDisplay extends StatefulWidget {
  final String imagelink;
  final String eventName;
  final String member_rate;
  final String normal_rate;
  final String startDate;
  final String endDate;
  final String points;
  final String id;
  final bool attendance_request;
  final String description;

  const SingleEventDisplay(
      {required this.attendance_request,
      required this.id,
      required this.points,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.eventName,
      required this.imagelink,
      required this.member_rate,
      required this.normal_rate});

  @override
  State<SingleEventDisplay> createState() => _SingleEventDisplayState();
}

class _SingleEventDisplayState extends State<SingleEventDisplay> {
  int attended = 0;
  String attendance_status = "";

  final baseUrl = AppEndpoints.baseUrl;

  String generateDeepLink() {
    return AppEndpoints.deepLink;
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
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.eventName,
          style: GoogleFonts.lato(
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: const Color(0xFF2A81C9),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: loadProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var profile = snapshot.data;
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Center(
                        child: Container(
                          height: size.height * 0.35,
                          width: size.width * 0.84,
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
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.imagelink),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: size.height * 0.008),
                            child: Text(
                              "Event Name",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: size.height * 0.027,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              final deepLink = generateDeepLink();
                              String message = "🎉 ${widget.eventName} 🎉\n\n"
                                  "📅 Event Date: ${widget.startDate} - ${widget.endDate}\n\n"
                                  "📌 To book for the event attendance, click on the link below:\n"
                                  "$deepLink";
                              Share.share(message);
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.0022),
                        child: Text(
                          widget.eventName,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(color: Colors.black),
                            fontSize: size.height * 0.022,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "Description",
                        style: GoogleFonts.lato(
                          fontSize: size.height * 0.027,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.0019),
                        child: Html(
                          data: widget.description,
                          style: {
                            "p": Style(
                              fontSize: FontSize(16.0),
                              color: Colors.black,
                            ),
                            "h1": Style(
                              fontSize: FontSize(24.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Container(
                        margin: EdgeInsets.only(left: size.width * 0.03),
                        padding: EdgeInsets.all(size.width * 0.03),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            EventInfoColumn(
                              title: "Start Date",
                              value: extractDate(widget.startDate),
                              color: Colors.green,
                            ),
                            EventInfoColumn(
                              title: "End Date",
                              value: extractDate(widget.endDate),
                              color: Colors.green,
                            ),
                            EventInfoColumn(
                              title: "Rate",
                              value: isMember()
                                  ? widget.member_rate
                                  : widget.normal_rate,
                              color: Colors.red,
                            ),
                            EventInfoColumn(
                              title: "Points",
                              value: widget.points,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.022),
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
                                  backgroundColor: const Color(0xFF2A81C9),
                                  padding: EdgeInsets.all(size.height * 0.024),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  _showPaymentDialog(size, profile);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.12),
                                  child: Text(
                                    'Book Attendance',
                                    style: GoogleFonts.lato(
                                      textStyle:
                                          const TextStyle(color: Colors.white),
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
                              return Container();
                          }
                        })(),
                      ),
                      SizedBox(height: size.height * 0.022),
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
                  sendAttendanceRequest(widget.id);
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
    return parts[0];
  }

  int showRegisterButton() {
    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime.parse(widget.startDate);
    DateTime endDate = DateTime.parse(widget.endDate);
    int statusCode = 0;

    if (widget.attendance_request == false) {
      if (currentDate.isAfter(endDate)) {
        attendance_status = "You missed this event";
        statusCode = 1;
      } else if (currentDate.isBefore(startDate)) {
        attendance_status = "Pending";
        statusCode = 2;
      } else if (currentDate.isAfter(startDate) &&
          currentDate.isBefore(endDate)) {
        attendance_status =
            "This event is happening but you did not register for it";
        statusCode = 3;
      } else if (currentDate.isAtSameMomentAs(startDate)) {
        attendance_status =
            "This event is happening but you did not register for it";
        statusCode = 4;
      } else if (currentDate.isAtSameMomentAs(endDate)) {
        attendance_status =
            "This event is happening but you did not register for it";
        statusCode = 5;
      }
    } else {
      if (currentDate.isAfter(endDate)) {
        attendance_status = "Thank you For Attending the Event";
        statusCode = 6;
      } else if (currentDate.isBefore(startDate)) {
        attendance_status = "Already Registered to attend";
        statusCode = 7;
      } else if (currentDate.isAfter(startDate) &&
          currentDate.isBefore(endDate)) {
        attendance_status =
            "Thank you for registering for the event, it is happening now";
        statusCode = 8;
      } else if (currentDate.isAtSameMomentAs(startDate)) {
        attendance_status =
            "Thank you for registering for the event, it is happening now";
        statusCode = 9;
      } else if (currentDate.isAtSameMomentAs(endDate)) {
        attendance_status =
            "Thank you for registering for the event, it is happening now";
        statusCode = 10;
      }
    }

    return statusCode;
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
        redirectUrl: AppEndpoints.flutterWaveRedirect,
        txRef: const Uuid().v1(),
        amount: isMember() ? widget.member_rate : widget.normal_rate,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(
            title: "IPPU PAYMENT",
            description: "Being payment for ${widget.eventName}",
            logo:
                "https://ippu.or.ug/wp-content/uploads/2020/03/cropped-Logo-192x192.png"),
        isTestMode: false);
    final ChargeResponse response = await flutterwave.charge();
    String message;
    if (response.success == true) {
      message = "Payment successful,\n thank you!";
      sendAttendanceRequest(widget.id);
    } else {
      message = "Payment failed,\n try again later";
    }
    showLoading(message);

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

    final apiUrl = Uri.parse('$baseUrl/attend-event');

    // Create a map of the data to send
    final Map<String, dynamic> requestBody = {
      'user_id': userId,
      'event_id': cpdID,
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
        const CircularProgressIndicator();
        showBottomNotification('Bookings for event sent successful');
        Navigator.pop(context);
      } else {
        // Handle errors or unsuccessful response
        showBottomNotification("Booking for event failed..!!");
      }
    } catch (error) {
      // Handle network errors or exceptions
      showBottomNotification("An error occurred while sending booking request");
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

class EventInfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const EventInfoColumn({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
