import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Util/PhoneNumberFormatter%20.dart';

import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'dart:io';

class MembershipForm extends StatefulWidget {
  const MembershipForm({super.key});

  @override
  State<MembershipForm> createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  late Future<UserData> userDataFuture;
  late UserData userDataProfile;

  String surname = '';
  String otherNames = '';
  String gender = '';
  String dateOfBirth = '';
  String nationality = 'Ugandan';
  String postalAddress = '';
  String phoneNumber = '';
  String email = '';
  String physicalAddress = '';
  String academicQualifications = '';
  String professionalQualifications = '';
  String otherQualifications = '';
  String currentEmployer = '';
  String currentPosition = '';
  String employerAddress = '';
  String employerPhone = '';
  String employerEmail = '';
  String currentInstitution = '';
  String institutionAddress = '';
  String institutionPhone = '';
  String institutionEmail = '';
  String courseOfStudy = '';
  String dateOfCompletion = '';
  String membershipCategory = '';

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    userDataFuture = loadProfile();
  }

  Future<UserData> loadProfile() async {
    AuthController authController = AuthController();
    try {
      final response = await authController.getProfile();
      if (response.containsKey("error")) {
        throw Exception("The return is an error");
      } else {
        if (response['data'] != null) {
          Map<String, dynamic> userData = response['data'];
          UserData profile = UserData(
              id: userData['id'],
              name: userData['name'] ?? "",
              email: userData['email'] ?? "",
              gender: userData['gender'],
              dob: userData['dob'] ?? "",
              membership_number: userData['membership_number'] ?? "",
              address: userData['address'] ?? "",
              phone_no: userData['phone_no'] ?? "",
              alt_phone_no: userData['alt_phone_no'] ?? "",
              nok_name: userData['nok_name'] ?? "",
              nok_address: userData['nok_address'] ?? "",
              nok_phone_no: userData['nok_phone_no'] ?? "",
              points: userData['points'] ?? "",
              account_type_id: userData['account_type_id'] ?? 1,
              subscription_status: userData['subscription_status'].toString(),
              profile_pic: userData['profile_pic'] ??
                  "https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png",
              membership_expiry_date:
                  userData['subscription_status'].toString() == "false"
                      ? ""
                      : userData['latest_membership']["expiry_date"]);

          // Pre-fill form fields
          List<String> nameParts = profile.name.split(' ');
          surname = nameParts.isNotEmpty ? nameParts[0] : '';
          otherNames =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          gender = profile.gender ?? '';
          dateOfBirth = profile.dob ?? '';
          _dateController.text = dateOfBirth;
          postalAddress = profile.address ?? '';
          phoneNumber = profile.phone_no ?? '';
          email = profile.email;
          physicalAddress = profile.address ?? '';

          return profile;
        } else {
          throw Exception("You currently have no data");
        }
      }
    } catch (error) {
      throw Exception("An error occurred while loading the profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<UserData>(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          userDataProfile = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'MEMBERSHIP APPLICATION FORM',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2A81C9),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: size.width * 0.15,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : NetworkImage(userDataProfile.profile_pic)
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF2A81C9),
                              radius: size.width * 0.05,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: size.width * 0.04),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'A. PERSONAL INFORMATION:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField(
                      'Surname', surname, (value) => surname = value),
                  _buildTextField(
                      'Other names', otherNames, (value) => otherNames = value),
                  _buildGenderSelection(),
                  _buildDateField(size),
                  _buildTextField('Nationality', nationality,
                      (value) => nationality = value),
                  _buildTextField('Postal Address', postalAddress,
                      (value) => postalAddress = value),
                  _buildPhoneField('Phone Number', phoneNumber,
                      (value) => phoneNumber = value),
                  _buildTextField('Email', email, (value) => email = value),
                  _buildTextField('Physical Address', physicalAddress,
                      (value) => physicalAddress = value),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'B. QUALIFICATIONS:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField(
                      'Academic Qualifications',
                      academicQualifications,
                      (value) => academicQualifications = value),
                  _buildTextField(
                      'Professional Qualifications',
                      professionalQualifications,
                      (value) => professionalQualifications = value),
                  _buildTextField('Other Qualifications', otherQualifications,
                      (value) => otherQualifications = value),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'C. OCCUPATION:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField('Current Employer', currentEmployer,
                      (value) => currentEmployer = value),
                  _buildTextField('Current Position', currentPosition,
                      (value) => currentPosition = value),
                  _buildTextField('Employer\'s Address', employerAddress,
                      (value) => employerAddress = value),
                  _buildPhoneField('Employer\'s Phone', employerPhone,
                      (value) => employerPhone = value),
                  _buildTextField('Employer\'s Email', employerEmail,
                      (value) => employerEmail = value),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'D. FOR STUDENTS:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField('Current Institution', currentInstitution,
                      (value) => currentInstitution = value),
                  _buildTextField('Institution Address', institutionAddress,
                      (value) => institutionAddress = value),
                  _buildPhoneField('Institution Phone', institutionPhone,
                      (value) => institutionPhone = value),
                  _buildTextField('Institution Email', institutionEmail,
                      (value) => institutionEmail = value),
                  _buildTextField('Course of Study', courseOfStudy,
                      (value) => courseOfStudy = value),
                  _buildDateField(size,
                      label: 'Date of Completion',
                      controller: TextEditingController(text: dateOfCompletion),
                      onSaved: (value) => dateOfCompletion = value),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'E. MEMBERSHIP CATEGORY:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildDropdownField(
                      'Membership Category',
                      ['Student', 'Associate', 'Full Member', 'Fellow'],
                      membershipCategory,
                      (value) => membershipCategory = value!),
                  SizedBox(height: size.height * 0.04),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A81C9),
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                            vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        'Submit Application',
                        style: GoogleFonts.poppins(
                            fontSize: size.width * 0.04, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildPhoneField(
      String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [PhoneNumberFormatter()],
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Gender:", style: GoogleFonts.poppins(color: Colors.grey[700])),
          Row(
            children: [
              Radio(
                value: 'male',
                groupValue: gender,
                onChanged: (value) => setState(() => gender = value.toString()),
              ),
              Text('Male', style: GoogleFonts.poppins()),
              Radio(
                value: 'female',
                groupValue: gender,
                onChanged: (value) => setState(() => gender = value.toString()),
              ),
              Text('Female', style: GoogleFonts.poppins()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(Size size,
      {String? label,
      TextEditingController? controller,
      Function(String)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller ?? _dateController,
        decoration: InputDecoration(
          labelText: label ?? 'Date of Birth',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, controller ?? _dateController),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: (value) {
          if (onSaved != null) {
            onSaved(value ?? '');
          } else {
            dateOfBirth = value ?? '';
          }
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'This field is required' : null,
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Implement form submission logic
      // This is where you would typically send the data to your backend
      showBottomNotification('Application submitted successfully');
    }
  }

  void showBottomNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}
