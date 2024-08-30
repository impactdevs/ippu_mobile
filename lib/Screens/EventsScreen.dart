import 'package:flutter/material.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/AllEventsScreen.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/MyEvents.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/UpcomingEventsScreen.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final event = Provider.of<UserProvider>(context).events;

    return Scaffold(
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        title: Text(
          "Events page",
          style: GoogleFonts.lato(fontSize: size.height * 0.02, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          Row(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(right: size.width * 0.01),
                  child: const Icon(Icons.notifications_on, color: Colors.white,),
                ),
              ),
              //
              Padding(
                padding: EdgeInsets.only(right: size.width * 0.01,),
                child: Text(
                  "All events: $event",
                  style: GoogleFonts.lato(
                    fontSize: size.height * 0.014,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              )
              //
            ],
          )
        ],
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                children: [
                  Icon(Icons.event_sharp, size: size.height * 0.014, color: Colors.white),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.008),
                    child: Text(
                      "All Events",
                      style: GoogleFonts.lato(fontSize: size.height * 0.014, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  Icon(Icons.timeline, size: size.height * 0.014, color: Colors.white),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.004),
                    child: Text(
                      "Upcoming Events",
                      style: GoogleFonts.lato(fontSize: size.height * 0.013,color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  Icon(Icons.event_seat, size: size.height * 0.014, color: Colors.white),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.008),
                    child: Text(
                      "My Events",
                      style: GoogleFonts.lato(fontSize: size.height * 0.014, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AllEventsScreen(),
          UpcomingEventsScreen(),
          MyEvents(),
        ],
      ),
    );
  }
}
