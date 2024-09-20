import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/models/UserProvider.dart';
import 'package:ippu/models/WorkingExperience.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

enum FormMode {
  Add,
  Edit,
}

class WorkExperience extends StatefulWidget {
  const WorkExperience({super.key});

  @override
  State<WorkExperience> createState() => _WorkExperienceState();
}

class _WorkExperienceState extends State<WorkExperience> {
  //to control the visibility of the form
  bool _isFormVisible = false;
  late Future<List<WorkingExperience>> WorkingExperienceFuture;
  FormMode _formMode = FormMode.Add; // Default mode is adding

  @override
  void initState() {
    super.initState();
    WorkingExperienceFuture = fetchWorkingExperience();
  }

  final TextEditingController _title = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _position = TextEditingController();
  int experience_id = 0;

  Future<void> addWorkExperience(
      {required String title,
      required String startDate,
      required String endDate,
      required String description,
      required String position,
      required int id}) async {
    const String apiUrl = 'https://staging.ippu.org/api/work-experience';

    final Map<String, dynamic> requestData = {
      "title": title,
      "start_date": startDate,
      "end_date": endDate,
      "description": description,
      "position": position,
      "user_id": id,
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(requestData),
      headers: {
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      // WorkExperience background added successfully
      print('Work Experience added successfully');
      showBottomNotification('work experience added successfully');

      setState(() {
        WorkingExperienceFuture = fetchWorkingExperience();
      });
    } else {
      // Error handling for the failed request
    }
  }

  Future<void> updateWorkExperience(
      {required String title,
      required String startDate,
      required String endDate,
      required String description,
      required String position,
      required int id,
      required String experience_id}) async {
    const String apiUrl = 'https://staging.ippu.org/api/edit-work-experience';

    final Map<String, dynamic> requestData = {
      "title": title,
      "start_date": startDate,
      "end_date": endDate,
      "description": description,
      "position": position,
      "user_id": id,
      "experience_id": int.parse(experience_id),
    };
    final response = await http.put(
      Uri.parse(apiUrl),
      body: json.encode(requestData),
      headers: {
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      // WorkExperience background added successfully
      print('Work Experience added successfully');
      showBottomNotification('work experience added successfully');

      setState(() {
        WorkingExperienceFuture = fetchWorkingExperience();
      });
    } else {
      // Error handling for the failed request
    }
  }

  void _toggleFormVisibility(FormMode mode) {
    setState(() {
      _formMode = mode;
      _isFormVisible = !_isFormVisible;
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        elevation: 0,
        title: Text("Work Experience", style: GoogleFonts.lato(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 42, 129, 201),
        onPressed: () {
          _toggleFormVisibility(FormMode.Add);
        },
        tooltip: 'Add Work Experience',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.009,
          ),
          // Conditionally render the content based on the _isFormVisible flag
          _isFormVisible ? _buildWorkForm() : _buildExistingContent(),
        ],
      ),
    );
  }

  //

  Widget _buildExistingContent() {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Center(
          child: SizedBox(
            height: size.height * 0.78,
            width: size.width * 0.85,
            child: FutureBuilder<List<WorkingExperience>>(
              future: WorkingExperienceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child:
                        Text("Check your internet connection to load the data"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // return const Text('No data available');
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.14,
                        ),
                        const Image(image: AssetImage('assets/no_data.png')),
                        const Text("No Work Experience Available")
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<WorkingExperience> eventData = snapshot.data!;
                  return ListView.builder(
                    itemCount: eventData.length,
                    itemBuilder: (context, index) {
                      final experience = eventData[index];
                      return TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.1,
                        indicatorStyle: IndicatorStyle(
                          width: 20,
                          height: 20,
                          indicator:
                              _buildIndicator(), // You can customize your indicator here
                        ),
                        beforeLineStyle: const LineStyle(
                          color: Colors.grey,
                        ),
                        endChild: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5,
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${experience.title}'.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          print(
                                              'experience id: ${experience.id}');
                                          _toggleFormVisibility(FormMode
                                              .Edit); // Set the mode to Edit
                                          _populateFormFields(
                                              experience); // Pass the index here
                                        },
                                        child: const Icon(Icons.edit, color: Colors.white,), // Edit Icon
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      '${experience.start_date} to ${experience.end_date}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Position: ${experience.position}',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${experience.description}',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Update the selected date in the text field
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = formattedDate;
    }
  }
  //

  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  Widget _buildWorkForm() {
    final size = MediaQuery.of(context).size;
    final userData = Provider.of<UserProvider>(context).user;

    // Define border radius and border width for the input fields
    final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: Colors.grey, // Border color
        width: 1.0, // Border width
      ),
    );

    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            // Display the form title
            child: Text(
              'Add Work Experience',
              style: TextStyle(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          TextField(
            decoration: InputDecoration(
              labelText: 'Title',
              border: outlineInputBorder,
            ),
            controller: _title,
          ),
          SizedBox(height: size.height * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Start Date',
              border: outlineInputBorder,
            ),
            controller: _startDate,
            onTap: () => _selectDate(context, _startDate),
          ),
          SizedBox(height: size.height * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'End Date',
              border: outlineInputBorder,
            ),
            controller: _endDate,
            onTap: () => _selectDate(context, _endDate),
          ),
          SizedBox(height: size.height * 0.02),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: outlineInputBorder,
            ),
            controller: _description,
            maxLines:
                5, // Setting maxLines to null allows the TextField to behave like a TextArea
          ),
          SizedBox(height: size.height * 0.02),
          TextField(
            decoration: InputDecoration(
              labelText: 'Position',
              border: outlineInputBorder,
            ),
            controller: _position,
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Clear form fields and hide the form
                  _clearForm();
                  _toggleFormVisibility(FormMode.Add);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save WorkExperience details and close the form
                  if (_formMode == FormMode.Add) {
                    addWorkExperience(
                      title: _title.text,
                      startDate: _startDate.text,
                      endDate: _endDate.text,
                      description: _description.text,
                      position: _position.text,
                      id: userData!.id,
                    );
                  } else {
                    updateWorkExperience(
                      title: _title.text,
                      startDate: _startDate.text,
                      endDate: _endDate.text,
                      description: _description.text,
                      position: _position.text,
                      id: userData!.id,
                      experience_id: experience_id.toString(),
                    );
                  }
                  _clearForm();
                  _toggleFormVisibility(FormMode.Add);
                },
                //save or update
                child: Text(_formMode == FormMode.Add ? 'Save' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    // Clear form fields when the form is closed or submitted
    _title.clear();
    _startDate.clear();
    _endDate.clear();
    _description.clear();
    _position.clear();
  }

  //  a function to fetch working experience
  Future<List<WorkingExperience>> fetchWorkingExperience() async {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    final userId = userData?.id;
    // Define the URL with userData.id
    final apiUrl = 'https://staging.ippu.org/api/work-experience/$userId';

    // Define the headers with the bearer token
    final headers = {
      'Authorization': 'Bearer ${userData?.token}',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> availableExperience = jsonData['data'];
        List<WorkingExperience> Experience = availableExperience.map((item) {
          return WorkingExperience(
            id: item['id'].toString(),
            title: item['title'],
            start_date: item['start_date'],
            end_date: item['end_date'],
            description: item['description'],
            position: item['position'],
          );
        }).toList();
        return Experience;
      } else {
        throw Exception('Failed to load events data');
      }
    } catch (error) {
      // Handle the error here, e.g., display an error message to the user
      print('Error: $error');
      return []; // Return an empty list or handle the error in your UI
    }
  }

  Widget _buildIndicator() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue, // You can change indicator color here
      ),
    );
  }

  void _populateFormFields(experience) {
    _title.text = experience.title;
    _startDate.text = experience.start_date;
    _endDate.text = experience.end_date;
    _description.text = experience.description;
    _position.text = experience.position;
    experience_id = int.parse(experience.id);
  }
}
