import 'package:flutter/material.dart';
import 'package:ippu/Screens/DefaultScreen.dart';
import 'package:ippu/Util/OTPBoxes.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ippu/controllers/auth_controller.dart';

class Digitcode extends StatefulWidget {
  final String phoneNumber;
  final FirebaseAuth auth; // Add FirebaseAuth parameter
  final verificationId;
  final OTPCode;
  const Digitcode(
      {super.key,
      required this.phoneNumber,
      required this.auth,
      required this.verificationId,
      required this.OTPCode});

  @override
  State<Digitcode> createState() => _WelcomeState();
}

class _WelcomeState extends State<Digitcode> {
  TextEditingController otp = TextEditingController();

  @override
  void initState() {
    super.initState();
    otp = TextEditingController(text: widget.OTPCode); // Set initial text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Set app bar background color
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              const SizedBox(height: 20),
              //Enter 6 digit code sent to your phone
              const Text(
                "Enter 6 digit code sent to your phone",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),

              PinInputBoxes(otp),
              const SizedBox(height: 20),
              const Text("If you didn't receive the code, tap"),
              //Resend code
              TextButton(
                onPressed: () {
                  Navigator.pop(context, widget.phoneNumber);
                },
                child: const Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  ),
                ),
              ),
              const Text("and check your phone number to try again."),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget PinInputBoxes(TextEditingController otpController) {
    //set controller value to the OTP code
    return PinInput(
      controller: otpController,
      onPinComplete: (value) async {
        // You can call the verifyOTP method here
        var isloggedIn = await verifyOTP(value);

        if (isloggedIn) {
          Get.snackbar('Success', 'OTP Verified successfully');
          String formattedPhoneNumber = widget.phoneNumber.replaceAll(' ', '');

          //phone login
          var isPhoneLoggedIn = await phoneLogin(formattedPhoneNumber);
          if (isPhoneLoggedIn) {
            Get.snackbar('Success', 'Login successful');

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              //save the fcm token to the database
              return const DefaultScreen();
            }));
          } else {
            Get.snackbar('Error', 'Login failed. Please try again');
          }
        } else {
          Get.snackbar('Error', 'Invalid OTP. Please try again');
        }
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await widget.auth.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: widget.verificationId, smsCode: otp));

    return credentials.user != null ? true : false;
  }

  Future<bool> phoneLogin(String phone) async {
    AuthController authController = AuthController();

    final response = await authController.phoneLogin(phone);

    //check if response status is success
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }
}
