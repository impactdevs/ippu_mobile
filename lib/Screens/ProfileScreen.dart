import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:ippu/Widgets/ProfileWidgets/EditProfile.dart';
import 'package:ippu/Widgets/ProfileWidgets/InformationScreen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _profileController;
  // late List<ProfileData> profileDataList = [];

  @override
  void initState() {
    super.initState();

    _profileController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String? status = context.watch<SubscriptionStatusProvider>().status;
    return Scaffold(
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        elevation: 0,
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
                padding: EdgeInsets.only(right: size.width * 0.016),
                child: Text(
                  (status == "false")
                      ? "No Subscription"
                      : "Subscription:$status",
                  style: GoogleFonts.lato(
                      fontSize: size.height * 0.020,
                      color: (status == "Pending")
                          ? Colors.yellowAccent
                          : (status == "Approved")
                              ? Colors.green
                              : (status == "Denied")
                                  ? Colors.red
                                  : Colors.white,
                      fontWeight: FontWeight.bold),
                )),
          ])
        ],
        bottom: TabBar(
          controller: _profileController,
          tabs: const [
            Tab(
              text: 'Bio data',
            ),
            Tab(
              text: 'Edit Profile',
            ),
          ],
          indicatorColor: Colors.white, // Set the underline color to white
          labelColor: Colors.white, // Set the selected tab text color to white
        ),
      ),
      body: TabBarView(
        controller: _profileController,
        children: [
          // Info Tab Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add content for Info tab here

                SizedBox(
                    height: size.height * 0.9,
                    width: double.maxFinite,
                    child: const InformationScreen()),
              ],
            ),
          ),

          // Edit Profile Tab Content
          const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add content for Edit Profile tab here
                EditProfile()
                // EditUserProfile()
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}
