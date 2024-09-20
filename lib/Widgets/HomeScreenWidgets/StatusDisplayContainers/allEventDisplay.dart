import 'package:flutter/material.dart';
import 'package:ippu/Screens/EventsScreen.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class allEventDisplay extends StatefulWidget {
  const allEventDisplay({super.key});

  @override
  State<allEventDisplay> createState() => _allEventDisplayState();
}

class _allEventDisplayState extends State<allEventDisplay> {
  int totalEventPoints = 0;
  @override
  void initState() {
    super.initState();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Profile'),
          content:
              const Text('Please complete your profile to access this feature'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;
    final totalEvents = Provider.of<UserProvider>(context).totalEvents;
    return InkWell(
      onTap: () {
        if (profileStatus == true) {
          _showDialog();
          return;
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const EventsScreen();
          }));
        }
      },
      child: Container(
        height: size.height * 0.098,
        width: size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 42, 129, 201),
              // Color.fromARGB(200, 139, 195, 74),
              Color.fromARGB(255, 42, 129, 201),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.white,
                offset: Offset(0.8, 0.3),
                blurRadius: 0.3,
                spreadRadius: 0.3),
            BoxShadow(
                color: Colors.grey,
                offset: Offset(0.3, 0.9),
                blurRadius: 0.3,
                spreadRadius: 0.3),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.07),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: size.height * 0.040,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.055),
              child: Text(
                "Check out all Events",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.022),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.07),
              child: Container(
                height: size.height * 0.06,
                width: size.width * 0.20,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text("$totalEvents",
                        style: const TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
