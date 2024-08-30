import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ippu/Screens/DefaultScreen.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/ForgotPasswordScreen.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/PhoneAuthlogin.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/RegisterScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/controllers/auth_controller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userPassword = '';
  bool _isLoginPasswordVisible = false;
  bool _isSigningIn = false; // Add a boolean variable to track sign-in process

  Future<void> _loginForm() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();

      try {
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
        final authResponse =
            await authController.signIn(_userEmail, _userPassword);


        // Close the loading indicator dialog
        Navigator.pop(context);

        if (authResponse.containsKey('error')) {
          // Handle authentication error
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Invalid credentials, check your email and password and try again!"),
          ));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            //save the fcm token to the database
            return const DefaultScreen();
          }));
        }
      } catch (e) {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong. Please try again later."),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: size.height * 0.20,
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 42, 129, 201),
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage("assets/ppulogo.png"),
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    margin: EdgeInsets.only(top: size.height * 0.18),
                    height: size.height * 0.06,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.010,
            ),
            Text("Login Page",
                style: GoogleFonts.montserrat(
                    fontSize: size.height * 0.047,
                    color: const Color.fromARGB(255, 42, 129, 201),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            SizedBox(height: size.height * 0.029),
            Text(
              "Sign in to continue to IPPU Membership App",
              style: GoogleFonts.lato(
                color: const Color.fromARGB(255, 42, 129, 201).withOpacity(0.4),
              ),
            ),
            SizedBox(
              height: size.height * 0.006,
            ),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      buttonItem(
                          "assets/google.svg",
                          "Continue with Google",
                          25,
                          _isSigningIn
                              ? () {}
                              : () async {
                                  setState(() {
                                    _isSigningIn = true;
                                  });

                                  // Implement Google Sign In here
                                  final authController = AuthController();
                                  bool response =
                                      await authController.signInWithGoogle();

                                  if (response) {
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      //save the fcm token to the database
                                      return const DefaultScreen();
                                    }));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Something went wrong. Please try again later."),
                                      ),
                                    );
                                  }

                                  setState(() {
                                    _isSigningIn = false;
                                  });
                                }),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      //check if platform is android
                      Platform.isAndroid
                          ? buttonItem(
                              "assets/phone.svg",
                              "Continue with Phone",
                              30,
                              _isSigningIn
                                  ? () {}
                                  : () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const PhoneAuthLogin();
                                      }));
                                    })
                          : SignInWithAppleButton(
                            style: SignInWithAppleButtonStyle.white,
                              onPressed: () async {
                                final credential =
                                    await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );
                                var firstName = "";
                                var lastName = "";
                                if (credential.givenName != null) {
                                  firstName = "${credential.givenName}";
                                }
                                if (credential.familyName != null) {
                                  lastName = "${credential.familyName}";
                                }

                                var fullName = "$firstName $lastName";

                                final authController = AuthController();
                                bool response =
                                    await authController.authenticateWithAppleEmail({"email":credential.email!, "fullName":fullName});

                                if (response) {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    //save the fcm token to the database
                                    return const DefaultScreen();
                                  }));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Something went wrong. Please try again later."),
                                    ),
                                  );
                                }
                              },
                            ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      const Center(
                        child: Text(
                          "Or",
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      SizedBox(
                        width: size.width, // Set the desired width
                        height: size.height * 0.06, // Set the desired height
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            // You can add more validation here if needed
                            return null;
                          },
                          onSaved: (value) {
                            _userEmail = value!;
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.028),
                      SizedBox(
                        width: size.width, // Set the desired width
                        height: size.height * 0.06, // Set the desired height
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLoginPasswordVisible =
                                      !_isLoginPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isLoginPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: !_isLoginPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            // You can add more validation here if needed
                            return null;
                          },
                          onSaved: (value) {
                            _userPassword = value!;
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.034),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 42, 129,
                              201), // Change button color to green
                          padding: EdgeInsets.all(size.height * 0.011),
                        ),
                        onPressed: _isSigningIn ? null : _loginForm,
                        child: const Text('Sign In',
                            style:
                                TextStyle(color: Colors.white, fontSize: 25)),
                      ),
                      SizedBox(height: size.height * 0.020),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: size.width * 0.08),
                            child: Text(
                              "Don't have an account ?",
                              style: GoogleFonts.lato(
                                fontSize: size.height * 0.022,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _isSigningIn
                                ? null
                                : () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const RegisterScreen();
                                    }));
                                  },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.015),
                              child: Text(
                                "SignUp",
                                style: GoogleFonts.montserrat(
                                    fontSize: size.height * 0.022,
                                    color:
                                        const Color.fromARGB(255, 42, 129, 201),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _isSigningIn
                            ? null
                            : () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ForgotPasswordScreen();
                                }));
                              },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: size.width * 0.02),
                            child: Text(
                              "forgot password ?",
                              style: GoogleFonts.lato(
                                fontSize: size.height * 0.020,
                                color: const Color.fromARGB(255, 42, 129, 201)
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonItem(
      String imagePath, String buttonName, double size, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          elevation: 8,
          color: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: Colors.white,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imagePath,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
