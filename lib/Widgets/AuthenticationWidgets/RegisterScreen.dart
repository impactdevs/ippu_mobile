import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ippu/Screens/animated_text.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Widgets/AuthenticationWidgets/RegistrationFeedback.dart';
import 'package:ippu/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';
  String _confirmPassword = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late var _accountTypes;
  int selectedAccountType = 1;

  @override
  void initState() {
    super.initState();
    _accountTypes = _fetchAccountTypes();
  }

  Future<List<Map<String, dynamic>>> _fetchAccountTypes() async {
    final response =
        await http.get(Uri.parse('https://staging.ippu.org/api/account-types'));

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

  /*
    * Submits the form
  */
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> requestData = {
        "name": _username,
        "email": _email,
        "password": _confirmPassword,
        "account_type_id": selectedAccountType,
      };

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      AuthController authController = AuthController();
      final response = await authController.signUp(requestData);

      // Close the loading indicator dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (!response.containsKey('error')) {
        // Registration successful, handle the response as needed.
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return RegistrationFeedback(email: _email);
          }));
        }
      } else {
        String message = response['error'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: _accountTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: AnimatedLoadingText(
                  loadingTexts: [
                    "Fetching account types...",
                    "Please wait...",
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'An error occurred while fetching account types',
                style: GoogleFonts.lato(
                  color: Colors.red,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> accountTypes =
                snapshot.data as List<Map<String, dynamic>>;
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    Text(
                      "Create account",
                      style: GoogleFonts.montserrat(
                          fontSize: size.height * 0.047,
                          color: const Color.fromARGB(255, 42, 129, 201),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    Text(
                      "Get your free IPPU account now. ",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(255, 42, 129, 201)
                            .withOpacity(0.6),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.006,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                // You can add more validation here if needed
                                return null;
                              },
                              onSaved: (value) {
                                _email = value!;
                              },
                            ),
                            SizedBox(height: size.height * 0.018),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                // You can add more validation here if needed
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                            SizedBox(height: size.height * 0.018),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSaved: (value) {},
                            ),
                            SizedBox(height: size.height * 0.018),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _confirmPassword = value!;
                              },
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
                                        child: Text(accountType['name']),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAccountType = value as int;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an account type';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: size.height * 0.04),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 42,
                                    129, 201), // Change button color to green
                                padding: EdgeInsets.all(size.height * 0.028),
                              ),
                              onPressed: _submitForm,
                              child: Text('Register',
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: size.height * 0.022,
                                  )),
                            ),
                            SizedBox(height: size.height * 0.026),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.08),
                                  child: Text(
                                    "Already have an account ?",
                                    style: GoogleFonts.lato(
                                      fontSize: size.height * 0.022,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const LoginScreen();
                                    }));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.015),
                                    child: Text(
                                      "SignIn",
                                      style: GoogleFonts.montserrat(
                                          fontSize: size.height * 0.022,
                                          color: const Color.fromARGB(
                                              255, 42, 129, 201),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                'An error occurred while fetching account types',
                style: GoogleFonts.lato(
                  color: Colors.red,
                ),
              ),
            );
          }
        });
  }
}
