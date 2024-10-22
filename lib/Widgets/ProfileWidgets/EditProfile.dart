import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Screens/ProfileScreen.dart';
import 'package:ippu/Util/PhoneNumberFormatter%20.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:ippu/models/UserData.dart';
import 'dart:io';
import 'package:ippu/models/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:ippu/Screens/animated_text.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  late Future<UserData> userDataFuture;
  late Future<dynamic> profileData;
  late UserData userDataProfile;

  String name = '';
  String gender = '';
  String dob = '';
  String membershipNumber = '';
  String address = '';
  String phoneNo = '';
  String altPhoneNo = '';
  String nokName = '';
  String nokAddress = '';
  String nokPhoneNo = '';

  bool isMale = false;
  bool isFemale = false;
  int selectedAccountType = 1;
  int real_selected_id = 8;
  late var _accountTypes;

  late ImageProvider _avatarImage;

  final FocusNode _dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    //get account types
    _accountTypes = _fetchAccountTypes();
    _avatarImage = NetworkImage(
        Provider.of<ProfilePicProvider>(context, listen: false).profilePic);
    //set date controller from user data

    profileData = loadProfile();

    //set the date controller to the date field from profileData
    profileData.then((value) {
      _dateController.text = value.dob ?? '';

      //set gender
      if (value.gender != null) {
        setState(() {
          gender = value.gender!;
          isMale = gender == 'male';
          isFemale = gender == 'female';
        });
      }

      //set selected account type
      if (value.account_type_id != null) {
        setState(() {
          selectedAccountType = value.account_type_id!;
          real_selected_id = value.account_type_id!;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAccountTypes() async {
    final response =
        await http.get(Uri.parse('https://ippu.org/api/account-types'));

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

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    // Check if the widget is still mounted before updating the state
    if (!mounted) return;

    if (pickedImage != null && mounted) {
      final selectedFile = File(pickedImage.path);

      // Show a loading indicator while the image is being updated
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
      final userId = userData?.id; // Replace with your actual user ID
      final response = await authController.store(selectedFile, userId!);

      // Close the loading indicator
      Navigator.of(context).pop();

      if (response.containsKey('message')) {
        setState(() {
          final profilePicProvider = context.read<ProfilePicProvider>();
          profilePicProvider.setProfilePic(response['profile_photo_path']);
          _avatarImage = NetworkImage(
              Provider.of<ProfilePicProvider>(context, listen: false)
                  .profilePic);
        });

        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to upload image',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _dateFocusNode.dispose();
    super.dispose();
  }

  Future<UserData> loadProfile() async {
    AuthController authController = AuthController();
    try {
      final response = await authController.getProfile();
      if (response.containsKey("error")) {
        throw Exception("The return is an error");
      } else {
        if (response['data'] != null) {
          // Access the user object directly from the 'data' key
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

          log("profile: ${response['data']}");

          return profile;
        } else {
          // Handle the case where the 'data' field in the API response is null
          throw Exception("You currently have no data");
        }
      }
    } catch (error) {
      throw Exception("An error occurred while loading the profile");
    }
  }

  //combine the futures of account types and profile data
  Future<List<dynamic>> _combineFutures() async {
    return Future.wait([_accountTypes, profileData]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: _combineFutures(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text("An error occurred while loading the profile data"),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: AnimatedLoadingText(
                  loadingTexts: [
                    "Fetching account data...",
                    "Please wait...",
                  ],
                ),
              ),
            ],
          );
        }
        if (snapshot.hasData) {
          //get user data
          userDataProfile = snapshot.data?[1] as UserData;
          //selected account type
          List<Map<String, dynamic>> accountTypes = snapshot.data?[0];

          log('account types: $accountTypes');

          //search for ana account type with the id of the selected account type
          selectedAccountType = accountTypes
              .indexWhere((element) => element['id'] == selectedAccountType);

          //if selected account type is not found, set it to 8
          if (selectedAccountType == -1) {
            selectedAccountType = 2;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarImage,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.014),
              Text(
                userDataProfile.name,
                style: GoogleFonts.lato(
                    fontSize: size.height * 0.03, fontWeight: FontWeight.bold),
              ),
              Text(
                userDataProfile.email,
                style: GoogleFonts.lato(color: Colors.grey),
              ),
              SizedBox(height: size.height * 0.02),
              const Divider(height: 1),
              SizedBox(height: size.height * 0.02),
              const Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 129, 201),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              // a form for editing user profile to be added here
              // UserProfileForm(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.016),
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onSaved: (value) {
                                  name = value ?? userDataProfile.name;
                                },
                                initialValue: userDataProfile.name,
                              ),
                              SizedBox(height: size.height * 0.018),
                              Text("Gender:",
                                  style: GoogleFonts.lato(
                                    color: Colors.grey,
                                    fontSize: size.height * 0.018,
                                  )),
                              Row(
                                children: [
                                  Radio(
                                    value: 'male',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value.toString();
                                        isMale = true;
                                        isFemale = false;
                                      });
                                    },
                                  ),
                                  const Text('Male'),
                                  Radio(
                                    value: 'female',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value.toString();
                                        isMale = false;
                                        isFemale = true;
                                      });
                                    },
                                  ),
                                  const Text('Female'),
                                ],
                              ),
                              SizedBox(height: size.height * 0.018),
                              //account type dropdown
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: 'Account Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                items: accountTypes
                                    .map((accountType) => DropdownMenuItem(
                                          value: accountType['id'],
                                          child: Text(
                                            accountType['name'],
                                            style: GoogleFonts.lato(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                //initial value as value with id 1 from drop down list
                                value: real_selected_id,
                                onChanged: (value) {
                                  setState(() {
                                    //get the index of the selected account type in accountTypes
                                    final index = accountTypes.indexWhere(
                                        (element) => element['id'] == value);
                                    selectedAccountType = index;
                                    log("selected Account: $selectedAccountType");
                                    real_selected_id =
                                        accountTypes[selectedAccountType]['id'];
                                    log("real value: $real_selected_id");
                                    // selectedAccountType = value as int;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an account type';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onTap: () =>
                                    _selectDate(context, _dateController),
                                onSaved: (value) {
                                  dob = (_dateController.text);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'this field is required';
                                  }

                                  //check if the person is 18 years and above
                                  final date =
                                      DateFormat('yyyy-MM-dd').parse(value);
                                  if (!isEighteenYearsAndAbove(date)) {
                                    return 'You must be 18 years and above';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Membership Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onSaved: (value) {
                                  membershipNumber = value ??
                                      userDataProfile.membership_number ??
                                      '';
                                },
                                initialValue:
                                    userDataProfile.membership_number ?? '',
                                enabled: false,
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Place of Residence',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onSaved: (value) {
                                  address = (value ?? userDataProfile.address)!;
                                },
                                initialValue: userDataProfile.address,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'this field is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                inputFormatters: [PhoneNumberFormatter()],
                                keyboardType: TextInputType.phone,
                                onSaved: (value) {
                                  //remove spaces from phone number
                                  phoneNo = (value ?? userDataProfile.phone_no)!
                                      .replaceAll(' ', '');
                                },
                                initialValue:
                                    padPhoneNumber(userDataProfile.phone_no),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'this field is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Alternate Phone Number',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                inputFormatters: [PhoneNumberFormatter()],
                                keyboardType: TextInputType.phone,
                                onSaved: (value) {
                                  altPhoneNo =
                                      (value ?? userDataProfile.alt_phone_no)!
                                          .replaceAll(' ', '');
                                },
                                initialValue: padPhoneNumber(
                                    userDataProfile.alt_phone_no),
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Next of Kin Name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onSaved: (value) {
                                  nokName =
                                      (value ?? userDataProfile.nok_name)!;
                                },
                                initialValue: userDataProfile.nok_name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'this field is required';
                                  }
                                  //check if length of phone number is 13
                                  if (value.length < 3) {
                                    return 'Invalid name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Next of Kin Address',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onSaved: (value) {
                                  nokAddress =
                                      (value ?? userDataProfile.nok_address)!;
                                },
                                initialValue: userDataProfile.nok_address,
                              ),
                              SizedBox(height: size.height * 0.018),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Next of Kin Phone Number',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onSaved: (value) {
                                  nokPhoneNo =
                                      (value ?? userDataProfile.nok_phone_no)!;
                                },
                                initialValue: userDataProfile.nok_phone_no,
                              ),
                              SizedBox(height: size.height * 0.018),
                            ]))
                  ],
                ),
              ),
              // form ends here
              SizedBox(height: size.height * 0.01),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 42, 129, 201), // Change button color to green
                    padding: EdgeInsets.all(size.height * 0.024),
                  ),
                  onPressed: () {
                    final accountID = accountTypes[selectedAccountType]['id'];
                    _submitForm(accountID);
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.12),
                    child: Text(
                      'update profile',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.018),
            ],
          );
        }
        return const Scaffold(
          body: Center(
            child: Text('An error occurred'),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime eighteenYearsAgo =
        currentDate.subtract(const Duration(days: 18 * 365));

    final DateTime? picked = await showDatePicker(
        context: context,
        //initial date starts from date.now minus 18 years
        initialDate: DateTime(eighteenYearsAgo.year, eighteenYearsAgo.month,
            eighteenYearsAgo.day),
        firstDate: DateTime(1920),
        lastDate: DateTime(2101),
        //selectable date starts from date.now minus 18 years
        selectableDayPredicate: (DateTime date) => date.isBefore(
            currentDate.subtract(const Duration(days: 18 * 365 - 1))));
    if (picked != null) {
      // Update the selected date in the text field
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _submitForm(selectedAccountTypeId) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Call the function to send data to the API
      sendUserDataToApi(selectedAccountTypeId);
    }
  }

  void sendUserDataToApi(selectedAccountTypeId) async {
    UserData? userData = Provider.of<UserProvider>(context, listen: false).user;
    final userId = userData?.id; // Replace with your actual user ID

    final apiUrl = Uri.parse('https://ippu.org/api/profile/$userId');

    // Create a map of the data to send
    final userDataMap = {
      'name': name,
      'gender': gender,
      'dob': dob,
      'membership_number': membershipNumber,
      'address': address,
      'phone_no': phoneNo,
      'alt_phone_no': altPhoneNo,
      'nok_name': nokName,
      'nok_email': nokAddress,
      'nok_phone_no': nokPhoneNo,
      'account_type_id': real_selected_id
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
      const CircleAvatar();
      if (response.statusCode == 200) {
        // Handle a successful API response
        const CircleAvatar();
        showBottomNotification('Profile information updated successfully');
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const ProfileScreen())));

        Provider.of<UserProvider>(context, listen: false)
            .setProfileStatus(false);
      } else {
        // Handle errors or unsuccessful response
        showBottomNotification('Update failed, please try again');
      }
    } catch (error) {
      // Handle network errors or exceptions
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

  //check if the person is 18 years and above
  bool isEighteenYearsAndAbove(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    const daysPerYear = 365.25;
    final years = (difference / daysPerYear).floor();
    return years >= 18;
  }

  String padPhoneNumber(phoneNumberWithoutSpaces) {
    if (phoneNumberWithoutSpaces == "") {
      return "";
    }

    //check the length of the phone number, if it has 10 characters, add +256 at the beginning
    if (phoneNumberWithoutSpaces.length == 10) {
      phoneNumberWithoutSpaces = '+256$phoneNumberWithoutSpaces';
    }

    if (phoneNumberWithoutSpaces.length != 13) {
      return "";
    }

    //check if the second character is +
    if (phoneNumberWithoutSpaces[1] == '+') {
      //remove it
      phoneNumberWithoutSpaces = phoneNumberWithoutSpaces.substring(2);
    }

    String formattedPhoneNumber =
        '${phoneNumberWithoutSpaces.substring(0, 4)} ${phoneNumberWithoutSpaces.substring(4, 7)} ${phoneNumberWithoutSpaces.substring(7, 10)} ${phoneNumberWithoutSpaces.substring(10)}';
    return formattedPhoneNumber;
  }
}
