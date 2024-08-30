import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleWorkingExperienceDisplayScreen extends StatefulWidget {
    final String? id;
  final String? user_id;
  final String? title;
  final String? description;
  final String? start_date;
  final String? end_date;
  final String? attachment;
  final String? field;
  final String? points;
  final String? position;
  final String? type;
   const SingleWorkingExperienceDisplayScreen({super.key , this.field ,this.title, this.attachment,this.id, this.user_id, this.start_date, this.end_date, this.points, this.description, this.position, this.type});

  @override
  State<SingleWorkingExperienceDisplayScreen> createState() => _SingleWorkingExperienceDisplayScreenState();
}

class _SingleWorkingExperienceDisplayScreenState extends State<SingleWorkingExperienceDisplayScreen> {
 
  final String fieldType ="Not Specified";
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        title: Padding(
                      padding: EdgeInsets.only(left: size.width*0.02,  right: size.width*0.016,),
                      child: Text(" Job Title:${widget.title}", style: GoogleFonts.roboto(
                  fontSize: size.height*0.02,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ), )),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
                  margin: EdgeInsets.only(right:size.height*0.009, left:size.height*0.0098, top: size.height*0.02),
                  height: size.height*0.9,
                  width: size.width*0.96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  boxShadow: [
                BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Adjust shadow color and opacity
            offset: const Offset(0.8, 1.0), // Adjust the shadow offset
            blurRadius: 4.0, // Adjust the blur radius
            spreadRadius: 0.2, // Adjust the spread radius
                )]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height*0.012,),
                    // communication title section
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.02, top: size.height*0.02, right: size.width*0.016,),
                        child: Text("Job Title: ${widget.title}", style: GoogleFonts.roboto(
                    fontSize: size.height*0.02,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    color: const Color.fromARGB(255, 7, 63, 109),
                  ), )),
                    // 
      
                    // communication body section
                    const Divider(),
                    // 
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Position", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                      Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: widget.position,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                    // 
                      Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Job description", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                      Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: widget.description,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                    
                    // 
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Field of work", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: (widget.field==null)? fieldType:widget.field,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Attachment", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: (widget.attachment==null)? fieldType:widget.attachment,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Type", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: (widget.type==null)? fieldType:widget.type,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                                        Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: const Text("Points", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: size.width*0.066, top: size.height*0.008, right: size.width*0.04, bottom: size.height*0.008,),
                        child: Html(
                        data: (widget.points==null)? fieldType:widget.points,
                        style: {
                        "p": Style( // Apply style to <p> tags
                          fontSize: FontSize(size.height*0.010),
                          color: Colors.black,
                          // Add more style properties as needed
                        ),
                        "h1": Style( // Apply style to <h1> tags
                          fontSize: FontSize(size.height*0.009),
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
                        padding: EdgeInsets.symmetric(horizontal: size.width*0.08),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          // 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Start date", style: GoogleFonts.lato(
                                  color:Colors.green,
                                  fontWeight: FontWeight.bold
                                ),),
                                Text("${widget.start_date}", style: GoogleFonts.roboto(
                                  fontSize:size.height*0.016,
                                ),)
                              ],
                            ),
                          // 
                          // 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("End date", style: GoogleFonts.lato(
                                  color:Colors.green,
                                  fontWeight: FontWeight.bold
                                ),),
                                Text("${widget.end_date}", style: GoogleFonts.roboto(
                                  fontSize:size.height*0.016,
                                ),)
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