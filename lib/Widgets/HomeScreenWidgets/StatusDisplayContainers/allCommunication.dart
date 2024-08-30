import 'package:flutter/material.dart';
import 'package:ippu/Screens/CommunicationScreen.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class allCommunication extends StatefulWidget {
  const allCommunication({super.key});

  @override
  State<allCommunication> createState() => _allCommunicationState();
}

class _allCommunicationState extends State<allCommunication> {
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
    final totalCommunication =
        Provider.of<UserProvider>(context).totalCommunications;
    final profileStatus = context.watch<UserProvider>().profileStatusCheck;
    return InkWell(
      onTap: () {
        if (profileStatus == true) {
          _showDialog();
          return;
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CommunicationScreen();
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
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Icon(
                Icons.info,
                color: Colors.white,
                size: size.height * 0.040,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.055),
              child: Text(
                "Available communication",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.019),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.04),
              child: Container(
                height: size.height * 0.06,
                width: size.width * 0.20,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text("$totalCommunication",
                        style: const TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
