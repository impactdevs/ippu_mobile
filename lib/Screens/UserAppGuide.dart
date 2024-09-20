import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class UserAppGuide extends StatefulWidget {
  const UserAppGuide({super.key});

  @override
  State<UserAppGuide> createState() => _UserAppGuideState();
}

class _UserAppGuideState extends State<UserAppGuide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn to use the application", style: GoogleFonts.lato(
          
        ),),
      ),
    );
  }
}