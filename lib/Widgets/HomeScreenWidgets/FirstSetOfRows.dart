import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/attendedCpdListHorizontalView.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/UpcomingEventsHorizontalHomeDisplay.dart';
import 'package:ippu/Widgets/chartsWidget/AppColors.dart';
import 'package:ippu/Widgets/chartsWidget/firstPieChart.dart';
import 'package:ippu/Widgets/chartsWidget/indicator.dart';

class FirstSetOfRows extends StatefulWidget {
  const FirstSetOfRows({super.key});

  @override
  State<FirstSetOfRows> createState() => _FirstSetOfRowsState();
}

class _FirstSetOfRowsState extends State<FirstSetOfRows> {
  // Controller for the Scrollable widget
  final ScrollController _scrollController = ScrollController();

  // Timer to control auto-scrolling
  late Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    // Initialize the timer to scroll every 3 seconds
    _scrollTimer = Timer.periodic(const Duration(seconds: 5), _scrollAutomatically);
  }

  void _scrollAutomatically(Timer timer) {
    if (_scrollController.hasClients) {
      // Scroll by a small amount every time the timer fires
      _scrollController.animateTo(
        _scrollController.position.pixels + 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // Cancel the timer and dispose of the ScrollController
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left:size.width*0.4,),
          child: Text("App points summary", style: GoogleFonts.lato(
            fontSize:size.height*0.02,
            fontWeight: FontWeight.bold,
            color: Colors.blue
          ),),
        ),
        Padding(
          padding: EdgeInsets.only(left:size.width*0.4,),
          child: Text("( Touch on the graph to see changes )", style: GoogleFonts.lato(
            fontSize:size.height*0.01,
            fontWeight: FontWeight.bold,
            color: Colors.green
          ),),
        ),
        Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: size.height*0.26,
                    width: size.width*0.95,
                    child: const Row(
                      children: [
                        PieChartSample2(),
                      Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Indicator(
                          color: Colors.lightBlue,
                          text: 'Events points',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Indicator(
                          color: AppColors.contentColorGreen,
                          text: 'All User points',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Indicator(
                          color: AppColors.contentColorPurple,
                          text: 'Cpd points',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                    
                      ],
                    ),
                  ),
                  
                ],
              ),
        SizedBox(
          height: size.height*0.044,
        ),

        // container displaying the upcoming cpds in a horizontal 
        const Divider(),
        SingleChildScrollView(
        controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                height: size.height*0.35,
                width: size.width*0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const attendedCpdListHorizontalView(),
              ),
              SizedBox(
                width: size.height*0.05,
              ),
               Container(
                height: size.height*0.35,
                width: size.width*0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                  // color: Colors.pink,
                ),
                child: const UpcomingEventsHorizontalHomeDisplay(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.height*0.044,
        ),
        // Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Padding(
        //                 padding: EdgeInsets.only(
        //                   left: size.width * 0.06,
        //                   top: size.height * 0.02,
        //                   right: size.width * 0.06,
        //                 ),
        //                 child: Column(
        //                   children: [
        //                     Divider(),
        //                     Container(
        //                       height: size.height*0.4,
        //                       width: size.width*0.9,
        //                       child: Image_Slider()),
        //                   ],
        //                 ),
        //               ),
        //             ])
        // 
      ],
    )
          ;
  }
}