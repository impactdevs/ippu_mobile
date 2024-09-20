import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Util/TextWords.dart';

class OurCoreValues extends StatefulWidget {
  const OurCoreValues({super.key});

  @override
  State<OurCoreValues> createState() => _OurCoreValuesState();
}

class _OurCoreValuesState extends State<OurCoreValues> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Our Core Values",
            style: GoogleFonts.lato(
    textStyle: const TextStyle(color: Colors.white), // Set text color to white
  ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.009,
            ),
            //
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.022),
              child: Text(
                coreValueOpeningSentence,
                style: GoogleFonts.lato(
                    fontSize: size.height * 0.018,
                    color: const Color.fromARGB(210, 14, 55, 88),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            //
            SizedBox(
              height: size.height * 0.008,
            ),
            //
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.022),
              child: Center(
                child: Text(
                  coreValueSubtitle,
                  style: GoogleFonts.lato(
                      fontSize: size.height * 0.018,
                      color: const Color.fromARGB(210, 63, 131, 187).withOpacity(0.5),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            //
            SizedBox(
              height: size.height * 0.012,
            ),

            // this displays transparency
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Transparency",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      transparency,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            //
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Honesty",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      honesty,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            //
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Integrity",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      integrity,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            )
            //

            ,
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Fairness",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      fairness,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            )
            //

            ,
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Ethics",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      ethics,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            )
            //

            ,
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Professionalism",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      professionalism,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            )
            //

            ,
            SizedBox(
              height: size.height * 0.009,
            ),
            // this displays Honesty
            Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Team Work",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      teamwork,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.009,
            ),
                        Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Innovation",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      innovation,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.009,
            ),
                        Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Commitment",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      commitment,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.009,
            ),
                        Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Freedom Of Expression",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      freedomOfExpression,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.009,
            ),
                        Container(
              margin: EdgeInsets.only(
                  right: size.height * 0.009, left: size.height * 0.009),
              height: size.height * 0.18,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Adjust shadow color and opacity
                    offset: const Offset(0.8, 1.0), // Adjust the shadow offset
                    blurRadius: 4.0, // Adjust the blur radius
                    spreadRadius: 0.2, // Adjust the spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.022),
                    child: Text(
                      "Knowledge and Information Sharing",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(210, 14, 55, 88),
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  //
                  SizedBox(
                    height: size.height * 0.009,
                  ),
                  //
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.022),
                    child: Text(
                      knowledgeandInformationSharing,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: size.height * 0.020,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                  //
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
