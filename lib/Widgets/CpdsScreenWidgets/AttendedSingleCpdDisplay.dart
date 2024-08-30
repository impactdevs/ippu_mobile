import 'dart:math';

import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class AttendedSingleCpdDisplay extends StatefulWidget {
  final String? imagelink;
  final String? cpdsname;
  final String? startDate;
  final String? endDate;
  final String? type;
  final String? location;
  final String? content;
  final String? target_group;
  final String eventId;
  final String? status;

  const AttendedSingleCpdDisplay(
      {super.key,
      this.location,
      this.startDate,
      this.endDate,
      this.type,
      this.content,
      this.target_group,
      this.cpdsname,
      this.imagelink,
      required this.eventId,
      this.status});

  @override
  State<AttendedSingleCpdDisplay> createState() =>
      _AttendedSingleCpdDisplayState();
}

class _AttendedSingleCpdDisplayState extends State<AttendedSingleCpdDisplay> {
  var random = Random();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 42, 129, 201),
          title: Text(
            "${widget.cpdsname}",
            style: const TextStyle(color: Colors.white),
          )),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.008,
              ),
              Center(
                child: Container(
                  // margin: EdgeInsets.only(right:size.height*0.009, left:size.height*0.009),
                  height: size.height * 0.46,
                  width: size.width * 0.84,
                  decoration: BoxDecoration(
                      // border: Border.all(
                      //   // color: Colors.white,
                      // ),
                      image: DecorationImage(
                          image: NetworkImage("${widget.imagelink}"))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.06, top: size.height * 0.004),
                child: Text(
                  "Name",
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                  padding: EdgeInsets.only(
                      left: size.width * 0.06, top: size.height * 0.0008),
                  child: Text("${widget.cpdsname}")),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.06, top: size.height * 0.016),
                child: const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.06,
                    right: size.width * 0.06,
                    top: size.height * 0.0016),
                child: Html(
                  data: widget.content,
                  style: {
                    "p": Style(
                      // Apply style to <p> tags
                      fontSize: FontSize(16.0),
                      color: Colors.black,
                      // Add more style properties as needed
                    ),
                    "h1": Style(
                      // Apply style to <h1> tags
                      fontSize: FontSize(24.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      // Add more style properties as needed
                    ),
                    // Add more style definitions for other HTML elements
                  },
                ),
                // Text("${content}", textAlign: TextAlign.justify,),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.06, top: size.height * 0.016),
                child: const Text(
                  "Target Group",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.06,
                    right: size.width * 0.06,
                    top: size.height * 0.0016),
                child: Text(
                  "${widget.target_group}",
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(
                height: size.height * 0.016,
              ),
              // container displaying the start, end rate and location
              Container(
                margin: EdgeInsets.only(left: size.width * 0.03),
                height: size.height * 0.08,
                width: size.width * 0.96,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.4, 0.2),
                      blurRadius: 0.2,
                      spreadRadius: 0.4,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.017),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Start Date",
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            "${widget.startDate}",
                            style: TextStyle(fontSize: size.height * 0.008),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "End Date",
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            "${widget.endDate}",
                            style: TextStyle(fontSize: size.height * 0.008),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Type",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            "${widget.type}",
                            style: TextStyle(fontSize: size.height * 0.008),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Location",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            "${widget.location}",
                            style: TextStyle(fontSize: size.height * 0.008),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              //
              SizedBox(
                height: size.height * 0.022,
              ),
              //

              widget.status == "Attended"
                  ? Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 42, 129,
                              201), // Change button color to green
                          padding: EdgeInsets.all(size.height * 0.024),
                        ),
                        onPressed: () {
                          renderCertificateInBrowser(widget.eventId);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.12),
                          child: Text(
                            'Download certificate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.height * 0.02,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Text(""),
              //
              //
              SizedBox(
                height: size.height * 0.022,
              ),
              //
            ],
          ),
        ),
      ),
    );
  }

  Future<void> renderCertificateInBrowser(String eventId) async {
    AuthController authController = AuthController();
    try {
      final response =
          await authController.downloadCpdCertificate(int.parse(eventId));
      //check if response does not contain any error key
      if (response.containsKey('error')) {
        //show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Certificate download failed"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        //ask for storage write permission
        _saveImage(context, response['certificate']);
      }
    } catch (e) {
      //show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Certificate download failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void _showDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => CleanDialog(
  //       title: 'Certificate Downloaded',
  //       content: 'Certificate saved in downloads folder',
  //       backgroundColor: Colors.blue,
  //       titleTextStyle: const TextStyle(
  //           fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
  //       contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
  //       actions: [
  //         CleanDialogActionButtons(
  //           actionTitle: 'OK',
  //           onPressed: () => Navigator.pop(context),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Future<void> _saveImage(BuildContext context, String _url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    late String message;

    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(_url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename = '${dir.path}/certificate${random.nextInt(100)}.png';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Certificate Downloaded';
      }
    } catch (e) {
      message = "Certificate Download Failed, contact the Admin.";
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ));
    }

    if (message != null) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue));
    }
  }
}
