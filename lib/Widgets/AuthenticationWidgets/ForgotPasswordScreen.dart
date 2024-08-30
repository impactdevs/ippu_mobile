import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() {
    return ForgotPasswordScreenState();
  }
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showEmailField = true;
  bool _showNewPasswordFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Visibility(
                visible: _showEmailField,
                child: Column(
                  children: [
                    const Text(
                        'Enter your email to receive a code to reset your password'),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await http.post(
                              Uri.parse(
                                  'https://staging.ippu.org/api/profile/reset-password-code'),
                              body: {'email': _emailController.text});

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Verification code sent!')));
                            setState(() {
                              _showEmailField = false;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error sending verification code!')));
                          }
                        }
                      },
                      child: const Text('Send Code'),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !_showEmailField && !_showNewPasswordFields,
                child: Column(
                  children: [
                    Text(
                        "Enter the 6-digit verification code sent to ${_emailController.text}",
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _verificationCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '• • • • • •',
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (await verificationCodeIsValid()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Code verified!')));
                            setState(() {
                              _showNewPasswordFields = true;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Invalid verification code!')));
                          }
                        }
                      },
                      child: const Text('Verify Code'),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _showNewPasswordFields,
                child: Column(
                  children: [
                    const Text('Enter your new password'),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      validator: (value) {
                        // Implement your password validation logic here
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        //check if the passwords match
                        if (_formKey.currentState!.validate()) {
                          //reset the password
                          if (await resetPassword()) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginScreen();
                            }));
                          }
                        }
                      },
                      child: const Text('Change Password'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verificationCodeController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //verify code is valid
  // Implement your logic to validate the verification code
  Future<bool> verificationCodeIsValid() async {
    final email = _emailController.text;
    final code = _verificationCodeController.text;

    final response = await http.post(
        Uri.parse('https://staging.ippu.org/api/profile/verify-password-reset-email'),
        body: {'email': email, 'code': code});

    //print the body
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resetPassword() async {
    final email = _emailController.text;
    final code = _verificationCodeController.text;
    final password = _newPasswordController.text;

    final response = await http.post(
        Uri.parse('https://staging.ippu.org/api/profile/reset-password'),
        body: {'email': email, 'code': code, 'password': password});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
