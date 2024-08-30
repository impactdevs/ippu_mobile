import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:clean_dialog/clean_dialog.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<bool> isNotificationEnabled;
  late bool isNotificationOn;
  //delete account function
  Future<void> _deleteAccount(int userId) async {
    //send  DELETE requet to the server for the account id
    final response = await http.delete(
      Uri.parse('https://staging.ippu.org/api/profile/remove/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      //hide any dialog that is open
      Navigator.pop(context);
      //account deletion successful
      _showDialog(
          userId,
          "Account Deleted",
          "Your account has been deleted successfully. You will be redirected to the login screen",
          false);
    } else {
      //account deletion failed
      _showDialog(userId, "Account Deletion Failed",
          "Your account could not be deleted. Please try again later", false);
    }
  }

//create the dialog
  void _showDialog(int userId, String title, String content, bool isDelete) {
    List<CleanDialogActionButtons> actions = [];
    if (isDelete) {
      actions.add(CleanDialogActionButtons(
        actionTitle: 'NO',
        onPressed: () => Navigator.pop(context),
      ));

      actions.add(CleanDialogActionButtons(
        actionTitle: 'YES',
        onPressed: () {
          _deleteAccount(userId);
        },
      ));
    } else {
      actions.add(CleanDialogActionButtons(
        actionTitle: 'OK',
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const LoginScreen();
          }));
        },
      ));
    }
    showDialog(
      context: context,
      builder: (context) => CleanDialog(
        title: title,
        content: content,
        backgroundColor: Colors.red,
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        //show the NO and YES buttons if isDelete is true
        actions: actions,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isNotificationEnabled = getPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isNotificationEnabled,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          isNotificationOn = snapshot.data as bool;
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color.fromARGB(255, 42, 129, 201),
              title: Text("Account Settings", style: GoogleFonts.lato(color: Colors.white)),
            ),
            body: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("ACCOUNT SETTINGS",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Note: Deleting your Account will lead to loss of your data from our system, thus you will lose access to the application",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:Text("DANGER ZONE",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              onPressed: () {
                                final userData = Provider.of<UserProvider>(
                                        context,
                                        listen: false)
                                    .user;
                                final userId = userData
                                    ?.id; // Call the function to delete the account
                                _showDialog(
                                    userId!,
                                    "Delete Account",
                                    "Are you sure you want to delete your account?",
                                    true);
                              },
                              child:const Text(
                                'DELETE ACCOUNT',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:Text("NOTIFICATIONS",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20)),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Switch(
                                  value:
                                      isNotificationOn, // Set this variable based on the user's preference
                                  onChanged: (value) async {
                                    bool status =
                                        await turnNotificationsOnOrOff();
                                    setState(() {
                                      isNotificationOn = status;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error"),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<bool> getPermissionStatus() async {
    var status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  //turn notifications on or off
  Future<bool> turnNotificationsOnOrOff() async {
    //turn notifications on
    await Permission.notification.request();
    var status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    } else {
      openAppSettings();
      return false;
    }
  }
}
