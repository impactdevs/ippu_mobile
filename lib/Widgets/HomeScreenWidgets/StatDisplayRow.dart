import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class StatDisplayRow extends StatefulWidget {
  const StatDisplayRow({super.key});

  @override
  State<StatDisplayRow> createState() => _StatDisplayRowState();
}

class _StatDisplayRowState extends State<StatDisplayRow> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final totalCommunication =
        Provider.of<UserProvider>(context).totalCommunications;
        final totalEvents = Provider.of<UserProvider>(context).totalEvents;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // the home screen section displays ( available events)
        Container(
          height: size.height * 0.14,
          width: size.width * 0.42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // the row displaying icon and text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // container containing the event icon
                  Container(
                    height: size.height * 0.060,
                    width: size.width * 0.10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 50, 155, 132),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Colors.white,
                      size: size.height * 0.022,
                    ),
                  ),
                  Text("Available Events",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.012,
                        color: const Color.fromARGB(255, 42, 129, 201),
                      ))
                ],
              ),
              // end of the row section
              const Divider(
                thickness: 2,
                color: Color.fromARGB(210, 63, 131, 187),
              ),
              Center(
                  child: Text(
                "$totalEvents",
                style: TextStyle(
                    fontSize: size.height * 0.0342,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 50, 155, 132),
                    letterSpacing: 1),
              ))
            ],
          ),
        ),
        // attend CPD
        Container(
          height: size.height * 0.14,
          width: size.width * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // the row displaying icon and text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // container containing the event icon
                  Container(
                    height: size.height * 0.060,
                    width: size.width * 0.10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 50, 155, 132),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: size.height * 0.024,
                    ),
                  ),
                  Text("Available communications",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.012,
                        color: const Color.fromARGB(255, 42, 129, 201),
                      ))
                ],
              ),
              // end of the row section
              const Divider(
                thickness: 2,
                color: Color.fromARGB(210, 63, 131, 187),
              ),
              Center(
                  child: Text(
                "$totalCommunication",
                style: TextStyle(
                    fontSize: size.height * 0.0342,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 50, 155, 132),
                    letterSpacing: 1),
              ))
            ],
          ),
        ),
      ],
    );
  }
}
