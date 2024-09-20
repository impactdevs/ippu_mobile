import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleCommunicationDisplayScreen extends StatefulWidget {
  final String communicationtitle;
  final String communicationbody;
  final String communicationdate;
  const SingleCommunicationDisplayScreen(
      {super.key,
      required this.communicationbody,
      required this.communicationtitle,
      required this.communicationdate});

  @override
  State<SingleCommunicationDisplayScreen> createState() =>
      _SingleCommunicationDisplayScreenState(); //-
}

class _SingleCommunicationDisplayScreenState
    extends State<SingleCommunicationDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        title: Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.02,
              right: size.width * 0.016,
            ),
            child: Text(
              widget.communicationtitle,
              style: GoogleFonts.roboto(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            )),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(
              right: size.height * 0.009,
              left: size.height * 0.0098,
              top: size.height * 0.02),
          width: size.width * 0.96,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withOpacity(0.5), // Adjust shadow color and opacity
              offset: const Offset(0.8, 1.0), // Adjust the shadow offset
              blurRadius: 4.0, // Adjust the blur radius
              spreadRadius: 0.2, // Adjust the spread radius
            )
          ]),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.012,
              ),
              // communication title section
              Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.02,
                    top: size.height * 0.02,
                    right: size.width * 0.016,
                  ),
                  child: Text(
                    widget.communicationtitle,
                    style: GoogleFonts.roboto(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      color: const Color.fromARGB(255, 7, 63, 109),
                    ),
                  )),
              //

              // communication body section
              const Divider(),
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.066,
                  top: size.height * 0.008,
                  right: size.width * 0.04,
                  bottom: size.height * 0.008,
                ),
                child: Html(
                  data: widget.communicationbody,
                  style: {
                    "p": Style(
                      // Apply style to <p> tags
                      fontSize: FontSize(size.height * 0.010),
                      color: Colors.black,
                      // Add more style properties as needed
                    ),
                    "h1": Style(
                      // Apply style to <h1> tags
                      fontSize: FontSize(size.height * 0.009),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      // Add more style properties as needed
                    ),
                    // Add more style definitions for other HTML elements
                  },
                ),

                // Text("${communicationbody}"),
              ),
              //

              // date and time section
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: GoogleFonts.lato(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.communicationdate,
                          style: GoogleFonts.roboto(
                            fontSize: size.height * 0.016,
                          ),
                        )
                      ],
                    ),
                    //
                  ],
                ),
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}
