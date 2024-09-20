import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ippu/Screens/animated_text.dart';
import 'package:ippu/Util/util.dart';
import 'package:ippu/Widgets/CpdsScreenWidgets/CpdsSingleEventDisplay.dart';
import 'package:ippu/Widgets/DrawerWidget/DrawerWidget.dart';
import 'package:ippu/Widgets/EventsScreenWidgets/SingleEventDisplay.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late Future<LinkedHashMap<DateTime, List<Event>>> dayEvents;
  LinkedHashMap<DateTime, List<Event>> eventsList = LinkedHashMap();

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    dayEvents = _initializeSelectedEvents();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<LinkedHashMap<DateTime, List<Event>>>
      _initializeSelectedEvents() async {
    LinkedHashMap<DateTime, List<Event>> fetchedDayCpds =
        await fetchCpdssAndUpdateMap();

    LinkedHashMap<DateTime, List<Event>> fetchedDayEvents =
        await fetchEventsAndUpdateMap();

    // Merge the events for similar dates
    fetchedDayEvents.forEach((key, value) {
      if (fetchedDayCpds.containsKey(key)) {
        fetchedDayEvents[key]!.addAll(fetchedDayCpds[key]!);
      }
    });
    return fetchedDayEvents;
  }

  Future<LinkedHashMap<DateTime, List<Event>>> fetchEventsAndUpdateMap() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;

    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/events/${userData?.id}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body)['data'];
        final LinkedHashMap<DateTime, List<Event>> updatedEvents =
            LinkedHashMap();

        for (var event in eventData) {
          final int id = event['id'];
          final DateTime startDate = DateTime.parse(event['start_date']);
          final DateTime endDate = DateTime.parse(event['end_date']);
          final String eventTitle = event['name'];
          final bool attendanceRequest = event['attendance_request'];
          final newEvent = Event(
              id: id,
              title: eventTitle,
              eventType: "event",
              attendanceRequest: attendanceRequest,
              normal_rate: event['rate'],
              member_rate: event['member_rate'],
              description: event['details'],
              startDate: event['start_date'],
              endDate: event['end_date'],
              imageLink:
                  "https://staging.ippu.org/storage/banners/${event['banner_name']}",
              points: event['points'].toString());

          for (var date in daysInRange(startDate, endDate)) {
            if (updatedEvents.containsKey(date)) {
              updatedEvents[date]!.add(newEvent);
            } else {
              updatedEvents[date] = [newEvent];
            }
          }
        }
        // Return the updated events data structure
        return updatedEvents;
      } else {
        // Return an empty map if fetching fails
        return LinkedHashMap();
      }
    } catch (e) {
      // Return an empty map if an error occurs
      return LinkedHashMap();
    }
  }

  Future<LinkedHashMap<DateTime, List<Event>>> fetchCpdssAndUpdateMap() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final url = 'https://staging.ippu.org/api/cpds/${userData?.id}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body)['data'];
        final LinkedHashMap<DateTime, List<Event>> updatedEvents =
            LinkedHashMap();

        for (var event in eventData) {
          final int id = event['id'];
          final DateTime startDate = DateTime.parse(event['start_date']);
          final DateTime endDate = DateTime.parse(event['end_date']);
          final String eventTitle = event['topic'];
          final bool attendanceRequest = event['attendance_request'];
          final newEvent = Event(
              id: id,
              title: eventTitle,
              eventType: "cpd",
              attendanceRequest: attendanceRequest,
              normal_rate: event['normal_rate'],
              member_rate: event['member_rate'],
              description: event['content'],
              startDate: event['start_date'],
              endDate: event['end_date'],
              imageLink:
                  "https://staging.ippu.org/storage/banners/${event['banner']}",
              points: event['points'],
              type: event['type'],
              location: event['location'],
              targetGroup: event['target_group']);

          for (var date in daysInRange(startDate, endDate)) {
            if (updatedEvents.containsKey(date)) {
              updatedEvents[date]!.add(newEvent);
            } else {
              updatedEvents[date] = [newEvent];
            }
          }
        }
        // Return the updated events data structure
        return updatedEvents;
      } else {
        // Return an empty map if fetching fails
        return LinkedHashMap();
      }
    } catch (e) {
      // Return an empty map if an error occurs
      return LinkedHashMap();
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return eventsList[day] ?? [];
  }

  Future<List<Event>> _getEventsForRange(DateTime start, DateTime end) async {
    // Wait for the events to be fetched and updated
    final updatedEvents = await fetchEventsAndUpdateMap();

    // Now you can safely access the events for the range
    final List<DateTime> days = daysInRange(start, end);
    final List<Event> eventsForRange = [];

    for (final day in days) {
      eventsForRange.addAll(updatedEvents[day] ?? []);
    }

    return eventsForRange;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      // Wait for the events to be fetched and updated
      final events = _getEventsForDay(selectedDay);
      _selectedEvents.value = events;
    }
  }

  void _onRangeSelected(
      DateTime? start, DateTime? end, DateTime focusedDay) async {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      final events = await _getEventsForRange(start, end);
      _selectedEvents.value = events;
    } else if (start != null) {
      final events = _getEventsForDay(start);
      _selectedEvents.value = events;
    } else if (end != null) {
      final events = _getEventsForDay(end);
      _selectedEvents.value = events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CPDs & Events Calendar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
      ),
      drawer: Drawer(
        width: size.width * 0.8,
        child: const DrawerWidget(),
      ),
      body: FutureBuilder(
          future: dayEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: AnimatedLoadingText(
                    loadingTexts: [
                      "Fetching events..",
                      "Please wait...",
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/empty_events.jpg',
                        height: size.height * 0.3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "An error occurred while fetching events",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              eventsList =
                  snapshot.data as LinkedHashMap<DateTime, List<Event>>;

              final events = _getEventsForDay(_selectedDay!);
              //set the selected events to the value notifier
              _selectedEvents.value = events;
              return Stack(
                children: [
                  Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color.fromARGB(255, 22, 91, 148)),
                  ClipPath(
                    clipper: MyClipper(),
                    child: Container(
                      width: double.infinity,
                      height: size.height * 0.3,
                      color: Colors.white,
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TableCalendar<Event>(
                          firstDay: kFirstDay,
                          lastDay: kLastDay,
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          rangeStartDay: _rangeStart,
                          rangeEndDay: _rangeEnd,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          rangeSelectionMode: _rangeSelectionMode,
                          eventLoader: _getEventsForDay,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                            todayDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold),
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          onDaySelected: _onDaySelected,
                          onRangeSelected: _onRangeSelected,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isEmpty) return const SizedBox();

                              // Use Row for horizontal distribution
                              return Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Prevent exceeding available space
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Distribute equally
                                children: events.map((event) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 26.0), // Adjust spacing
                                    padding: const EdgeInsets.only(
                                        left: 6.0,
                                        right: 6.0), // Adjust padding
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: event.eventType == "cpd"
                                          ? Colors.green
                                          : Colors.red, // Use event's color
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Events and CPDs for the selected date:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.4,
                          child: _selectedEvents.value.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/empty_events.jpg', // Replace with your image path
                                        height: size.height * 0.28,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "No events or CPDs found for the selected date",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _selectedEvents.value.length,
                                  itemBuilder: (context, index) {
                                    final event = _selectedEvents.value[index];
                                    return Card(
                                      margin: const EdgeInsets.all(8.0),
                                      elevation: 4.0,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          event.eventType == "cpd"
                                              ? Icons.calendar_today
                                              : Icons.book,
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                          event.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: event.attendanceRequest
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.calendar_today_sharp,
                                                color: Colors.yellow,
                                              ),
                                        onTap: () {
                                          //check if cpd or event
                                          if (event.eventType == "event") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return SingleEventDisplay(
                                                  id: event.id.toString(),
                                                  attendance_request:
                                                      event.attendanceRequest,
                                                  points:
                                                      event.points.toString(),
                                                  normal_rate:
                                                      event.normal_rate,
                                                  member_rate:
                                                      event.member_rate,
                                                  description:
                                                      event.description,
                                                  startDate: event.startDate,
                                                  endDate: event.endDate,
                                                  imagelink: event.imageLink,
                                                  eventName: event.title,
                                                );
                                              }),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return CpdsSingleEventDisplay(
                                                  attendance_request:
                                                      event.attendanceRequest,
                                                  content: event.description,
                                                  target_group:
                                                      event.targetGroup ?? "",
                                                  startDate: event.startDate,
                                                  endDate: event.endDate,
                                                  rate: event.location ?? "",
                                                  type: event.type ?? "",
                                                  cpdId: event.id.toString(),
                                                  location:
                                                      event.location ?? "",
                                                  normal_rate:
                                                      event.normal_rate,
                                                  member_rate:
                                                      event.member_rate,
                                                  attendees: event.points,
                                                  imagelink: event.imageLink,
                                                  cpdsname: event.title,
                                                );
                                              }),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
