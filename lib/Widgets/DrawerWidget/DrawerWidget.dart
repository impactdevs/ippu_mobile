import 'package:flutter/material.dart';
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Providers/auth.dart';
import 'package:ippu/Screens/CommunicationScreen.dart';
import 'package:ippu/Screens/CpdsScreen.dart';
import 'package:ippu/Screens/DefaultScreen.dart';
import 'package:ippu/Screens/EducationBackgroundScreen.dart';
import 'package:ippu/Screens/EventsScreen.dart';
import 'package:ippu/Screens/JobsScreen.dart';
import 'package:ippu/Screens/OurCoreValues.dart';
import 'package:ippu/Screens/SettingsScreen.dart';
import 'package:ippu/Screens/WhoWeAreScreen.dart';
import 'package:ippu/Screens/WorkExperience.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/Widgets/Payments/PaymentScreen.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, UserProvider, ProfilePicProvider>(
      builder: (context, authProvider, userProvider, profilePicProvider, _) {
        final userData = userProvider.user;
        final profileStatus = userProvider.profileStatusCheck;
        final profilePhotoUrl =
            _getProfilePhotoUrl(profilePicProvider.profilePic);

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context, userData!, profilePhotoUrl),
              _buildDrawerItem(
                  context, Icons.home_outlined, "Home", const DefaultScreen()),
              _buildDrawerItem(
                  context,
                  Icons.cast_for_education_outlined,
                  "Education Background",
                  const EducationBackgroundScreen(),
                  profileStatus!),
              _buildDrawerItem(context, Icons.info_outline_rounded,
                  "Communications", const CommunicationScreen(), profileStatus),
              _buildDrawerItem(context, Icons.work_outline_outlined,
                  "Work Experience", const WorkExperience(), profileStatus),
              _buildDrawerItem(context, Icons.event, "Events",
                  const EventsScreen(), profileStatus),
              _buildDrawerItem(context, Icons.workspace_premium, "CPD",
                  const CpdsScreen(), profileStatus),
              _buildDrawerItem(context, Icons.link, "Jobs", const JobsScreen(),
                  profileStatus),
              _buildDrawerItem(context, Icons.album_outlined, "Who We Are",
                  const WhoWeAre()),
              _buildDrawerItem(
                  context, Icons.payment, "Payments", const PaymentsScreen()),
              _buildDrawerItem(context, Icons.admin_panel_settings_rounded,
                  "Our Core Values", const OurCoreValues(), profileStatus),
              _buildDrawerItem(context, Icons.settings, "Account Settings",
                  const SettingsScreen()),
              _buildLogoutButton(context, authProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(
      BuildContext context, UserData userData, String profilePhotoUrl) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Color(0xFF2A81C9)),
      currentAccountPicture:
          CircleAvatar(backgroundImage: NetworkImage(profilePhotoUrl)),
      accountName: Text(userData.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      accountEmail: Text(userData.email),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget destination,
      [bool checkProfile = false]) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: GoogleFonts.lato()),
        onTap: () => _handleNavigation(context, destination, checkProfile),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
      title: Text('Logout',
          style:
              GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
      onTap: () => _handleLogout(context, authProvider),
    );
  }

  void _handleNavigation(
      BuildContext context, Widget destination, bool checkProfile) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (checkProfile &&
        userProvider.profileStatusCheck != null &&
        userProvider.profileStatusCheck!) {
      _showIncompleteProfileDialog(context);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
    }
  }

  void _showIncompleteProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Profile'),
          content: const Text('Please complete your profile'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthProvider authProvider) async {
    final authController = AuthController();
    final response = await authController.signOut();

    if (!response.containsKey('error')) {
      await _clearUserData();
      authProvider.isLoggedIn();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Logout Failed"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DefaultCacheManager().emptyCache();
  }

  String _getProfilePhotoUrl(String url) {
    final lastElement = url.split('/').last;
    return lastElement == 'profiles'
        ? 'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png'
        : url;
  }
}
