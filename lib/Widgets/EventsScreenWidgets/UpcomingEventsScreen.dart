import 'package:flutter/material.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/ContainerDisplayingUpcomingEvents.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height*0.025,),
            // this section displays upcoming CPDS
             
            SizedBox(height: size.height*0.002,),
            // this container has the container that returns the CPds
            Container(
            height: size.height*0.65,
            width: double.maxFinite,
            decoration: const BoxDecoration(
              // color: Colors.blue,
            ),
            child: const ContainerDisplayingUpcomingEvents()),
          ],
        ),
      );
  }
}