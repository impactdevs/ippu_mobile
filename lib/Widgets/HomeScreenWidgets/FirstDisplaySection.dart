import 'dart:async';
import 'dart:convert';
import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/FirstSetOfRows.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/StatDisplayRow.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/StatusDisplayContainers/allCommunication.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/StatusDisplayContainers/allCpdDisplay.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/StatusDisplayContainers/allEventDisplay.dart';
import 'package:ippu/Widgets/HomeScreenWidgets/StatusDisplayContainers/availableJob.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/CpdModel.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';

import 'package:ippu/env.dart' as env;

class FirstDisplaySection extends StatefulWidget {
  const FirstDisplaySection({super.key});

  @override
  State<FirstDisplaySection> createState() => _FirstDisplaySectionState();
}

class _FirstDisplaySectionState extends State<FirstDisplaySection>
    with SingleTickerProviderStateMixin {
  int totalCPDS = 0;
  int totalEvents = 0;
  int totalCommunications = 0;
  late String totaleventPoints;

  late Future<List<CpdModel>> cpdDataFuture;
  late List<CpdModel> fetchedData = [];

  bool isProfileIncomplete = true;
  bool isSubscription = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      setState(() {
        isSubscription = false;
      });
    });
    fetchData();

    cpdDataFuture = fetchAllCpds();
    cpdDataFuture = fetchAllCpds().then((data) {
      fetchedData = data;
      return data;
    });
    cpdDataFuture = fetchAllCpds();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    timeDilation = 2.0; // Slowing down the animation for demonstration purposes

    _controller.repeat(reverse: true);
  }
  //

  //
// function for fetching cpds
  Future<List<CpdModel>> fetchAllCpds() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/cpds/${userData?.id}';

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
            attendance_request: item['attendance_request'],
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
  Future<void> fetchData() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    int userId = userData!.id;
    try {
      AuthController authController = AuthController();
      final cpds = await authController.getCpds(userId);
      final events = await authController.getEvents(userId);
      final communications = await authController.getAllCommunications(userId);

      setState(() {
        totalEvents = events.length;
        totalCPDS = cpds.length;
        totalCommunications = communications.length;
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCPDS(totalCPDS);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfEvents(totalEvents);
        Provider.of<UserProvider>(context, listen: false)
            .totalNumberOfCommunications(totalCommunications);
      });
    } catch (e) {
      // Handle any errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String? status = context.watch<SubscriptionStatusProvider>().status;

    log("subscription status: ${status.toString()}");

    final profileStatus = context.watch<UserProvider>().profileStatusCheck;

    return Stack(
      children: [
        Container(
          height: size.height * 0.35,
          width: size.width * 1,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 42, 129, 201),
          ),
          child: Column(
            children: [
              Text(
                "Welcome to IPPU mobile application",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.016),
              ),
              SizedBox(height: size.height * 0.026),
              const StatDisplayRow(),
            ],
          ),
        ),
        // bottom colored container
        Container(
          margin: EdgeInsets.only(
              top: size.height * 0.24, left: size.width * 0.032),
          // height: size.height * 0.56,
          height: size.height * 0.51,
          width: size.width * 0.95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.018),
                const FirstSetOfRows(),
                SizedBox(height: size.height * 0.002),
                //
                const allCpdDisplay(),
                //
                SizedBox(height: size.height * 0.024),
                //
                const allEventDisplay(),
                //
                SizedBox(height: size.height * 0.024),

                //
                const allCommunication(),
                //

                SizedBox(height: size.height * 0.024),

                const availableJob(),
              ],
            ),
          ),
        ),
        //
        // container displaying the subscription button
        status == 'false'
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + 0.08 * _animation.value,
                    child: child,
                  );
                },
                child: Center(
                  child: Container(
                    height: size.height * 0.075,
                    width: size.width * 0.96,
                    margin: EdgeInsets.only(bottom: size.height * 0.004),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white,
                      ),
                      color: const Color.fromARGB(255, 255, 118, 118),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 247, 245,
                              245), // Adjust shadow color and opacity
                          offset: Offset(0.8, 0.8), // Adjust the shadow offset
                          blurRadius: 4.0, // Adjust the blur radius
                          spreadRadius: 0.2, // Adjust the spread radius
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              final userData = Provider.of<UserProvider>(
                                      context,
                                      listen: false)
                                  .user;
                              _handlePaymentInitialization(
                                  userData!.name,
                                  userData.email,
                                  userData.phone_no!,
                                  userData.membership_amount!);
                            },
                            child: Center(
                              child: Text(
                                "Please complete your subscription",
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const Text(""),
        // container displaying the notifcation
        profileStatus!
            ? Center(
                child: profileStatus
                    ? Container(
                        height: size.height * 0.08,
                        width: size.width * 0.95,
                        margin: EdgeInsets.only(bottom: size.height * 0.004),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                          ),
                          color: const Color.fromARGB(255, 255, 118, 118),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 247, 245,
                                  245), // Adjust shadow color and opacity
                              offset:
                                  Offset(0.8, 0.8), // Adjust the shadow offset
                              blurRadius: 4.0, // Adjust the blur radius
                              spreadRadius: 0.2, // Adjust the spread radius
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const ProfileScreen();
                              }));
                            },
                            child: Center(
                              child: Text(
                                "Please Complete your profile",
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              )
            : const Text(""),

        //
      ],
    );
  }

  //
  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  _handlePaymentInitialization(String fullName, String email,
      String phoneNumber, String membershipAmount) async {
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
        txRef: const Uuid().v1(),
        amount: membershipAmount,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(
            title: "IPPU PAYMENT",
            logo:
                "https://ippu.or.ug/wp-content/uploads/2020/03/cropped-Logo-192x192.png"),
        isTestMode: false);
    final ChargeResponse response = await flutterwave.charge();
    String message;
    if (response.success == true) {
      message = "Payment successful,\n thank you!";
      sendRequest();
    } else {
      message = "Payment failed,\n try again later";
    }
    showLoading(message);
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

  Future<void> sendRequest() async {
    AuthController authController = AuthController();

    //try catch
    try {
      final response = await authController.subscribe();
      //check if response contains message key
      if (response.containsKey("message")) {
        //notify the SubscriptionStatusProvider
        if (mounted) {
          context
              .read<SubscriptionStatusProvider>()
              .setSubscriptionStatus("Pending");
        }
        //show bottom notification
        showBottomNotification(
            "your request has been sent! You will be approved");
      } else {
        //show bottom notification
        showBottomNotification("Something went wrong");
      }
    } catch (e) {
      showBottomNotification("Something went wrong");
    }
  }
}
