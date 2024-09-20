import 'package:flutter/material.dart';
import 'package:ippu/Screens/UserAppGuide.dart';

class userAppGuide extends StatefulWidget {
  const userAppGuide({super.key});

  @override
  State<userAppGuide> createState() => _userAppGuideState();
}

class _userAppGuideState extends State<userAppGuide> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const UserAppGuide();
        }));
      },
      child: Container(
        height: size.height * 0.098,
        width: size.width * 0.9,
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
              padding: EdgeInsets.only(left: size.width * 0.07),
              child: Icon(
                Icons.supervised_user_circle,
                color: Colors.white,
                size: size.height * 0.040,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.055),
              child: Text(
                "click to see app user guide",
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * 0.022),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
