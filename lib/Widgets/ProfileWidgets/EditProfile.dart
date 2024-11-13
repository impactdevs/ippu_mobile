import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Util/PhoneNumberFormatter%20.dart';
import 'package:ippu/Util/app_endpoints.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'dart:io';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final UserData userData;

  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  late String name;
  late String gender;
  late String dob;
  late String membershipNumber;
  late String address;
  late String phoneNo;
  late String altPhoneNo;
  late String nokName;
  late String nokAddress;
  late String nokPhoneNo;

  late bool isMale;
  late bool isFemale;
  Map<String, dynamic> selectedAccountType = {};
  late int accountId;

  late ImageProvider _avatarImage;

  List<Map<String, dynamic>> _accountTypes = [];
  bool _isLoadingAccountTypes = true;
  String? _accountTypesError;

  @override
  void initState() {
    super.initState();
    _initializeData();
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

  void _initializeData() {
    name = widget.userData.name;
    gender = widget.userData.gender ?? '';
    dob = widget.userData.dob ?? '';
    membershipNumber = widget.userData.membership_number ?? '';
    address = widget.userData.address ?? '';
    phoneNo = widget.userData.phone_no ?? '';
    altPhoneNo = widget.userData.alt_phone_no ?? '';
    nokName = widget.userData.nok_name ?? '';
    nokAddress = widget.userData.nok_address ?? '';
    nokPhoneNo = widget.userData.nok_phone_no ?? '';
    accountId = widget.userData.account_type_id ?? 3;

    _dateController.text = dob;
    isMale = gender == 'male';
    isFemale = gender == 'female';
    _avatarImage = NetworkImage(
        Provider.of<ProfilePicProvider>(context, listen: false).profilePic);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A81C9),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, vertical: size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.025),
            _buildProfileImage(size),
            SizedBox(height: size.height * 0.02),
            Text(
              widget.userData.name,
              style: GoogleFonts.poppins(
                  fontSize: size.height * 0.028, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.userData.email,
              style: GoogleFonts.poppins(
                  color: Colors.grey[600], fontSize: size.height * 0.016),
            ),
            SizedBox(height: size.height * 0.025),
            const Divider(height: 1),
            SizedBox(height: size.height * 0.025),
            Text(
              'Complete Profile',
              style: GoogleFonts.poppins(
                fontSize: size.height * 0.024,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A81C9),
              ),
            ),
            SizedBox(height: size.height * 0.025),
            _buildForm(size),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: size.width * 0.15,
          backgroundImage: _avatarImage,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: size.width * 0.045,
              backgroundColor: const Color(0xFF2A81C9),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(Size size) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField('Name', name, (value) => name = value ?? name),
          SizedBox(height: size.height * 0.02),
          _buildGenderSelection(),
          SizedBox(height: size.height * 0.02),
          _buildAccountTypeDropdown(),
          SizedBox(height: size.height * 0.02),
          _buildDateField(size),
          SizedBox(height: size.height * 0.02),
          TextFormField(
            enabled: false,
            initialValue: membershipNumber,
            style: GoogleFonts.poppins(color: Colors.grey[700]),
            decoration: InputDecoration(
              labelText: 'Membership Number',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2A81C9), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          _buildTextField('Place of Residence', address,
              (value) => address = value ?? address),
          SizedBox(height: size.height * 0.02),
          _buildPhoneField(
              'Phone Number', phoneNo, (value) => phoneNo = value ?? phoneNo),
          SizedBox(height: size.height * 0.02),
          _buildPhoneField('Alternate Phone Number', altPhoneNo,
              (value) => altPhoneNo = value ?? altPhoneNo),
          SizedBox(height: size.height * 0.02),
          _buildTextField('Next of Kin Name', nokName,
              (value) => nokName = value ?? nokName),
          SizedBox(height: size.height * 0.02),
          _buildTextField('Next of Kin Address', nokAddress,
              (value) => nokAddress = value ?? nokAddress),
          SizedBox(height: size.height * 0.02),
          _buildPhoneField('Next of Kin Phone Number', nokPhoneNo,
              (value) => nokPhoneNo = value ?? nokPhoneNo),
          SizedBox(height: size.height * 0.03),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A81C9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
              ),
            ),
            onPressed: _submitForm,
            child: Text(
              'Update Profile',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: size.height * 0.018,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String? initialValue, Function(String?) onSaved,
      {bool enabled = true}) {
    return TextFormField(
      enabled: enabled,
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
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      ),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(
      String label, String? initialValue, Function(String?) onSaved) {
    return TextFormField(
      initialValue: initialValue != null && initialValue.isNotEmpty
          ? (initialValue.startsWith('+256')
              ? initialValue
              : '+256$initialValue')
          : '+256',
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
      inputFormatters: [
        PhoneNumberFormatter(),
      ],
      keyboardType: TextInputType.phone,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          onSaved(value.startsWith('+256') ? value : '+256$value');
        } else {
          onSaved(null);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (!value.startsWith('+256')) {
          return 'Phone number must start with +256';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender:",
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: MediaQuery.of(context).size.height * 0.018,
            )),
        Row(
          children: [
            Radio(
              value: 'male',
              groupValue: gender,
              activeColor: const Color(0xFF2A81C9),
              onChanged: (value) {
                setState(() {
                  gender = value.toString();
                  isMale = true;
                  isFemale = false;
                });
              },
            ),
            Text('Male', style: GoogleFonts.poppins()),
            Radio(
              value: 'female',
              groupValue: gender,
              activeColor: const Color(0xFF2A81C9),
              onChanged: (value) {
                setState(() {
                  gender = value.toString();
                  isMale = false;
                  isFemale = true;
                });
              },
            ),
            Text('Female', style: GoogleFonts.poppins()),
          ],
        ),
      ],
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

  Widget _buildDateField(Size size) {
    return TextFormField(
      controller: _dateController,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
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
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        final date = DateFormat('yyyy-MM-dd').parse(value);
        if (!isEighteenYearsAndAbove(date)) {
          return 'You must be 18 years and above';
        }
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime eighteenYearsAgo =
        currentDate.subtract(const Duration(days: 18 * 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
          eighteenYearsAgo.year, eighteenYearsAgo.month, eighteenYearsAgo.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) => date
          .isBefore(currentDate.subtract(const Duration(days: 18 * 365 - 1))),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final selectedFile = File(pickedImage.path);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Updating profile photo...'),
              ],
            ),
          );
        },
      );

      AuthController authController = AuthController();
      final userData = Provider.of<UserProvider>(context, listen: false).user;
      final userId = userData?.id;
      final response = await authController.store(selectedFile, userId!);

      Navigator.of(context).pop();

      if (response.containsKey('message')) {
        setState(() {
          final profilePicProvider = context.read<ProfilePicProvider>();
          profilePicProvider.setProfilePic(response['profile_photo_path']);
          _avatarImage = NetworkImage(
              Provider.of<ProfilePicProvider>(context, listen: false)
                  .profilePic);
        });
        showBottomNotification(response['message']);
      } else {
        showBottomNotification('Failed to upload image');
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      sendUserDataToApi();
    }
  }

  void sendUserDataToApi() async {
    UserData? userData = Provider.of<UserProvider>(context, listen: false).user;
    final userId = userData?.id;

    final apiUrl = Uri.parse('${AppEndpoints.baseUrl}/profile/$userId');

    final userDataMap = {
      'name': name,
      'gender': gender,
      'dob': _dateController.text,
      'membership_number': membershipNumber,
      'address': address,
      'phone_no': phoneNo.replaceAll(' ', ''),
      'alt_phone_no': altPhoneNo.replaceAll(' ', ''),
      'nok_name': nokName,
      'nok_email': nokAddress,
      'nok_phone_no': nokPhoneNo,
      'account_type_id': selectedAccountType['id']
    };

    try {
      final response = await http.put(
        apiUrl,
        body: jsonEncode(userDataMap),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${userData?.token}'
        },
      );

      if (response.statusCode == 200) {
        showBottomNotification('Profile information updated successfully');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => const ProfileScreen())));
        Provider.of<UserProvider>(context, listen: false)
            .setProfileStatus(false);
      } else {
        showBottomNotification('Update failed, please try again');
      }
    } catch (error) {
      showBottomNotification('An error occurred, please try again');
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

  bool isEighteenYearsAndAbove(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    const daysPerYear = 365.25;
    final years = (difference / daysPerYear).floor();
    return years >= 18;
  }
}
