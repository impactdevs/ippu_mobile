import 'package:flutter/material.dart';
 import 'package:ippu/Widgets/CpdsScreenWidgets/attendedCpdListBuilder.dart';
 


class AttendedCpdsScreen extends StatefulWidget {
  const AttendedCpdsScreen({super.key});

  @override
  State<AttendedCpdsScreen> createState() => _AttendedCpdsScreenState();
}

class _AttendedCpdsScreenState extends State<AttendedCpdsScreen> {
  

@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 
          const Divider(),
          SizedBox(
            height: size.height*0.70,
            width: double.maxFinite,
 
            child: const attendedCpdListBuilder(),
            ),
        ],
      ),
    );
  }
}

