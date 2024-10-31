import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/Screens/EducationBackgroundScreen.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../Screens/animated_text.dart';

class ProfileData {
  final Map<String, dynamic> data;

  ProfileData({required this.data});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(data: json['data']);
  }
}

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isProfileIncomplete = true;
  int numberOfCertificates = 0;
  late Future<UserData> profileData;
  var random = Random();
  bool isDownloading = false;
  bool isLoadingTextVisible = false;

  @override
  void initState() {
    super.initState();
    profileData = loadProfile();
    _fetchAttendedEventsCount(); // Call the method to fetch attended events count
  }

  Future<void> _fetchAttendedEventsCount() async {
    try {
      final count = await certificateCount();
      setState(() {
        numberOfCertificates = count;
      });
    } catch (error) {}
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
            membership_expiry_date:
                userData['subscription_status'].toString() == "false"
                    ? ""
                    : userData['latest_membership']["expiry_date"],
            profile_pic: userData['profile_pic'] ??
                "https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png",
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
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).user;
    final size = MediaQuery.of(context).size;
    var url = context.watch<ProfilePicProvider>().profilePic;
    //split the url using / and get the last element,
    var lastElement = url.split('/').last;
    //network url, if the last element is profiles, put default image
    var networkUrl = lastElement == 'profiles'
        ? 'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png'
        : url;
    var profilePhoto = NetworkImage(networkUrl);

    String? status = context.watch<SubscriptionStatusProvider>().status;

    return FutureBuilder(
        future: profileData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profileData = snapshot.data as UserData;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: size.height * 0.008),

                      SizedBox(height: size.height * 0.012),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profilePhoto,
                      ),

                      SizedBox(height: size.height * 0.014),
                      Text(
                        userData!.name,
                        style: GoogleFonts.lato(
                            fontSize: size.height * 0.02,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userData.email,
                        style: GoogleFonts.lato(color: Colors.grey),
                      ),
                      SizedBox(height: size.height * 0.02),
                      if (status == 'Approved')
                        Text(
                          "Subscriptions Ends: ${formatExpiryDate(profileData.membership_expiry_date)}",
                          style: GoogleFonts.lato(color: Colors.grey),
                        ),
                      SizedBox(height: size.height * 0.02),
                      // add download membership certificate button
                      if (status == 'Approved')
                        ElevatedButton(
                          onPressed: isDownloading
                              ? null
                              : () {
                                  setState(() {
                                    // show a loading indicator
                                    isDownloading = true;
                                    isLoadingTextVisible = true;
                                  });
                                  renderCertificateInBrowser().then((value) {
                                    setState(() {
                                      isDownloading = false;
                                      isLoadingTextVisible = false;
                                    });
                                  });
                                },
                          child: const Text("Download Membership Certificate"),
                        ),
                      if (isLoadingTextVisible)
                        const AnimatedLoadingText(
                          loadingTexts: [
                            "Getting certificate.......",
                            "Please wait...",
                          ],
                        ),
                      const Divider(height: 1),
                      Card(
                          child: ListTile(
                        title: const Text("Name"),
                        subtitle: Text(profileData.name),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Email"),
                        subtitle: Text(profileData.email),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Gender"),
                        subtitle: Text("${profileData.gender}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Date of birth"),
                        subtitle: Text("${profileData.dob}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Membership number"),
                        subtitle: Text("${profileData.membership_number}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Address"),
                        subtitle: Text("${profileData.address}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Phone number"),
                        subtitle: Text("${profileData.phone_no}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Alt Phone number"),
                        subtitle: Text("${profileData.alt_phone_no}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Next of Kin name"),
                        subtitle: Text("${profileData.nok_name}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Next of Kin address"),
                        subtitle: Text("${profileData.nok_address}"),
                      )),
                      Card(
                          child: ListTile(
                        title: const Text("Next of Kin phone number"),
                        subtitle: Text("${profileData.nok_phone_no}"),
                      )),

                      //
                      SizedBox(height: size.height * 0.02),
                      const Divider(),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.12),
                        child: GestureDetector(
                          onTap: () {
                            //naviagate to my events screen
                            Navigator.pushNamed(context, '/myevents');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Certificates ($numberOfCertificates )',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.height * 0.028),
                              ),
                              const Icon(Icons.workspace_premium)
                            ],
                          ),
                        ),
                      ),
                      //
                      SizedBox(height: size.height * 0.02),
                      const Divider(),
                      SizedBox(height: size.height * 0.02),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const EducationBackgroundScreen();
                          }));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.12),
                          child: GestureDetector(
                            onTap: () {
                              //navigate to education background screen
                              Navigator.pushNamed(
                                  context, '/educationbackground');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Education background",
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.height * 0.028),
                                ),
                                const Icon(Icons.cast_for_education)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Divider(),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.12),
                        child: GestureDetector(
                          onTap: () {
                            //navigate to communication screen
                            Navigator.pushNamed(context, '/workexperience');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Working Experience",
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.height * 0.028),
                              ),
                              const Icon(Icons.work_history)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.12),
                    ],
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("An error occured while loading your profile"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<int> certificateCount() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final apiUrl = '${AppEndpoints.baseUrl}/attended-events/${userData?.id}';
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> eventData = jsonData['data'];
        // Return the count of attended events
        return eventData.length;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      return 0; // Return 0 or handle the error count in your UI
    }
  }

  Future<void> renderCertificateInBrowser() async {
    AuthController authController = AuthController();

    //show a loading indicator

    try {
      final response = await authController.downloadMembershipCertificate();

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Certificate download failed"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        //save certificate to disk
        _saveImage(context, response['certificate']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Certificate download failed, Contact the admin"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveImage(BuildContext context, String _url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    late String message;

    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(_url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename =
          '${dir.path}/membership_certificate${random.nextInt(100)}.png';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Certificate Downloaded';
      }
    } catch (e) {
      message = "Certificate Download Failed, contact the Admin.";
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ));
    }

    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue));
  }

  String formatExpiryDate(String? expiryDate) {
    if (expiryDate == null || expiryDate.isEmpty) {
      return '';
    }

    try {
      final parsedDate = DateTime.parse(expiryDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return expiryDate; // Return the raw string if parsing fails
    }
  }
}
