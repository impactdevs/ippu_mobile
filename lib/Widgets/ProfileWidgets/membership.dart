import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Util/PhoneNumberFormatter%20.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:http/http.dart' as http;

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
  String isStudent = 'No';
  String isEmployed = 'No';
  bool? acknowledgeDeclarations = false;
  Map<String, dynamic> selectedAccountType = {};
  late int accountId;
  List<Map<String, dynamic>> _accountTypes = [];
  bool _isLoadingAccountTypes = true;
  String? _accountTypesError;

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    userDataFuture = loadProfile();
    _fetchAccountTypes();
  }

  Future<List<Map<String, dynamic>>> _fetchAccountTypes() async {
    final response =
        await http.get(Uri.parse('${AppEndpoints.baseUrl}/account-types'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData.containsKey('data')) {
        final data = jsonData['data'] as List<dynamic>;
        if (data.isEmpty) {
          // Add a default account type
          return [
            {'id': 1, 'name': 'Please select account type'}
          ];
        } else {
          // Create a list of account type names
          final accountTypeNames = data
              .map((entry) => {'id': entry['id'], 'name': entry['name']})
              .toList();

          setState(() {
            _isLoadingAccountTypes = false;
            _accountTypes = accountTypeNames;
          });
          return accountTypeNames;
        }
      } else {
        return [
          {'id': 1, 'name': 'Please select account type'}
        ];
      }
    } else {
      return [
        {'id': 1, 'name': 'Please select account type'}
      ];
    }
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

          accountId = profile.account_type_id!;

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
                    'QUALIFICATIONS:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
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
                    'OCCUPATION:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildDropdownField(
                    'Are you employed?',
                    ['Yes', 'No'],
                    isEmployed,
                    (value) {
                      setState(() {
                        isEmployed = value!;
                      });
                    },
                  ),
                  if (isEmployed == 'Yes') ...[
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
                  ],
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'STUDENT STATUS:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildDropdownField(
                    'Are you a student?',
                    ['Yes', 'No'],
                    isStudent,
                    (value) {
                      setState(() {
                        isStudent = value!;
                      });
                    },
                  ),
                  if (isStudent == 'Yes') ...[
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
                        controller:
                            TextEditingController(text: dateOfCompletion),
                        onSaved: (value) => dateOfCompletion = value),
                  ],
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'B. REFEREES:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Recommendation letters from:',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '(a) Either current employer or former employer or Institution.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04, color: Colors.grey[800]),
                  ),
                  Text(
                    '(b) A member of IPPU or any other professional Institution in Uganda.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'These should, in confidence, be submitted directly to the Secretary of the Institute.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500]),
                  ),
                  SizedBox(height: size.height * 0.02),
                  if (recommendationLetter != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.file_present, color: Colors.grey[700]),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: Text(
                              recommendationLetterUrl ?? 'Selected file',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                                fontSize: size.width * 0.035,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[700]),
                            onPressed: () {
                              setState(() {
                                recommendationLetter = null;
                                recommendationLetterUrl = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: size.height * 0.02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _pickRecommendationLetter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey[700]),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Attach Recommendation Letters',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'C. MEMBERSHIP CATEGORY:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildAccountTypeDropdown(),
                  SizedBox(height: size.height * 0.04),
                  Text(
                    'D. DECLARATIONS:',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    '1. I promise to notify IPPU, in writing, of all changes in my details and address.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '2. I accept my responsibility to undertake adequate Continuing Professional Development as recommended by Council from time to time.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '3. When enrolled, I promise to abide by the Rules of Professional Conduct issued by Council. I will have regard to the statement of integrity, independence and objectivity therein.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '4. When enrolled, I promise to pay all my dues to the Institute as prescribed by Council including the agreed development fund.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '5. I have never been charged/convicted in the Courts of Law for any financial impropriety other than those stated on attachment referenced ……………………………………………………...',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    '6. I confirm that to the best of my knowledge, the information given in this form is true and correct.',
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035, color: Colors.grey[800]),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    children: [
                      Checkbox(
                        value: acknowledgeDeclarations ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            acknowledgeDeclarations = value;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I acknowledge and agree to all the above declarations',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.035),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A81C9),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1,
                              vertical: size.height * 0.02),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          'Submit Application',
                          style: GoogleFonts.poppins(
                              fontSize: size.width * 0.04, color: Colors.white),
                        ),
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

  Widget _buildAccountTypeDropdown() {
    if (_isLoadingAccountTypes) {
      return const Center(child: CircularProgressIndicator());
    } else if (_accountTypesError != null) {
      return Text(_accountTypesError!,
          style: GoogleFonts.poppins(color: Colors.red));
    } else if (_accountTypes.isEmpty) {
      return const Text('No account types available');
    }

    selectedAccountType = _accountTypes[
        _accountTypes.indexWhere((type) => type['id'] == accountId)];

    return DropdownButtonFormField<int>(
      value: selectedAccountType['id'],
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Account Type',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A81C9), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _accountTypes
          .map((accountType) => DropdownMenuItem<int>(
                value: accountType['id'],
                child: Text(accountType['name'], style: GoogleFonts.poppins()),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedAccountType = _accountTypes[
              _accountTypes.indexWhere((type) => type['id'] == value)];
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select an account type';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A81C9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField(
      String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A81C9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [PhoneNumberFormatter()],
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
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
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label ?? 'Date of Birth',
          labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A81C9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
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
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A81C9), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
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

  File? recommendationLetter;
  String? recommendationLetterUrl;

  Future<void> _pickRecommendationLetter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();

      if (extension == 'pdf' || extension == 'docx') {
        setState(() {
          recommendationLetter = file;

          final fileName =
              'recommendation_letter_${DateTime.now().millisecondsSinceEpoch}.$extension';
          recommendationLetterUrl = fileName;
        });
        showBottomNotification(
            'Recommendation letter uploaded successfully', Colors.green);
      } else {
        showBottomNotification(
            'Please select a PDF, DOCX or image file', Colors.red);
      }
    } else {
      showBottomNotification('No file was selected', Colors.red);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showBottomNotification(
          'Application submitted successfully', Colors.green);
    }
  }

  void showBottomNotification(String message, Color? color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }
}
