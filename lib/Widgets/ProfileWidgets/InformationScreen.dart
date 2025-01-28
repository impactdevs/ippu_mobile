import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:ippu/Widgets/ProfileWidgets/EditProfile.dart';
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
    _fetchAttendedEventsCount();
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
                account_type_id: userData['account_type_id'] ?? "",
          );

          return profile;
        } else {
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
    var lastElement = url.split('/').last;
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
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),
              child: ListView(
                padding: EdgeInsets.all(size.width * 0.04),
                children: [
                  // Profile Header Section
                  Container(
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: size.width * 0.15,
                          backgroundImage: profilePhoto,
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          userData!.name,
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userData.email,
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.035,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfile(userData: profileData),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.blue[700],
                              size: size.width * 0.045,
                            ),
                            label: Text(
                              "Edit Profile",
                              style: GoogleFonts.poppins(
                                color: Colors.blue[700],
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.06,
                                vertical: size.height * 0.015,
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.035),
                              ),
                            ),
                          ),
                        ),
                        if (status == 'Approved') ...[
                          SizedBox(height: size.height * 0.015),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03,
                                vertical: size.height * 0.008),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.05),
                            ),
                            child: Text(
                              "Subscription Ends: ${formatExpiryDate(profileData.membership_expiry_date)}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // Membership Certificate Button
                  if (status == 'Approved')
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: size.height * 0.012),
                      child: ElevatedButton.icon(
                        onPressed: isDownloading
                            ? null
                            : () {
                                setState(() {
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
                        icon: const Icon(Icons.download),
                        label: Text(
                          "Download Membership Certificate",
                          style: GoogleFonts.poppins(),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.025),
                          ),
                        ),
                      ),
                    ),

                  if (isLoadingTextVisible)
                    const AnimatedLoadingText(
                      loadingTexts: [
                        "Getting certificate.......",
                        "Please wait...",
                      ],
                    ),

                  // Profile Information Cards
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.025),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * 0.02,
                              bottom: size.height * 0.015),
                          child: Text(
                            "Personal Information",
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        _buildInfoCard("Name", profileData.name),
                        _buildInfoCard("Email", profileData.email),
                        _buildInfoCard("Gender", profileData.gender),
                        _buildInfoCard("Date of Birth", profileData.dob),
                        _buildInfoCard(
                            "Membership Number", profileData.membership_number),
                        _buildInfoCard("Address", profileData.address),
                        _buildInfoCard("Phone Number", profileData.phone_no),
                        _buildInfoCard(
                            "Alt Phone Number", profileData.alt_phone_no),
                      ],
                    ),
                  ),

                  // Next of Kin Information
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * 0.02,
                              bottom: size.height * 0.015),
                          child: Text(
                            "Next of Kin Details",
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        _buildInfoCard("Name", profileData.nok_name),
                        _buildInfoCard("Address", profileData.nok_address),
                        _buildInfoCard(
                            "Phone Number", profileData.nok_phone_no),
                      ],
                    ),
                  ),

                  // Quick Actions Section
                  Container(
                    margin: EdgeInsets.symmetric(vertical: size.height * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * 0.02,
                              bottom: size.height * 0.015),
                          child: Text(
                            "Quick Actions",
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        _buildActionCard(
                          "My Certificates",
                          "View your earned certificates",
                          Icons.workspace_premium,
                          numberOfCertificates.toString(),
                          () => Navigator.pushNamed(context, '/myevents'),
                        ),
                        _buildActionCard(
                          "Education Background",
                          "Manage your educational history",
                          Icons.school,
                          "",
                          () => Navigator.pushNamed(
                              context, '/educationbackground'),
                        ),
                        _buildActionCard(
                          "Working Experience",
                          "Update your work history",
                          Icons.work,
                          "",
                          () => Navigator.pushNamed(context, '/workexperience'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: size.width * 0.15, color: Colors.red[300]),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "An error occurred while loading your profile",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _buildInfoCard(String title, String? value) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
          vertical: size.height * 0.008, horizontal: size.width * 0.005),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.03),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.03,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value ?? "Not provided",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      String badge, VoidCallback onTap) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
          vertical: size.height * 0.008, horizontal: size.width * 0.005),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.03),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.03,
            color: Colors.grey[600],
          ),
        ),
        trailing: badge.isNotEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.008),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
      ),
    );
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
        return eventData.length;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      return 0;
    }
  }

  Future<void> renderCertificateInBrowser() async {
    AuthController authController = AuthController();

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
      final http.Response response = await http.get(Uri.parse(_url));
      final dir = await getTemporaryDirectory();
      var filename =
          '${dir.path}/membership_certificate${random.nextInt(100)}.png';
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
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
      return expiryDate;
    }
  }
}
