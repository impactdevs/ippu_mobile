import 'package:flutter/material.dart';
import 'package:ippu/Util/PhoneNumberFormatter%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/DigitCode.dart';
import 'package:ippu/controllers/auth_controller.dart';

class PhoneAuthLogin extends StatefulWidget {
  final String? phoneNumber;
  const PhoneAuthLogin({super.key, this.phoneNumber});

  @override
  State<PhoneAuthLogin> createState() => _WelcomeState();
}

class _WelcomeState extends State<PhoneAuthLogin> {
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  var verificationId = ''.obs;
  var OTPCode;
  bool isLoading = false; // Variable to control the visibility of the spinner

  TextEditingController phoneNumber = TextEditingController(text: '+256');
  TextEditingController otp = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    // Check if phoneNumber is provided and initialize the controller
    if (widget.phoneNumber != null) {
      // Remove spaces from the phone number
      String phoneNumberWithoutSpaces = widget.phoneNumber!.replaceAll(' ', '');

      // Format the phone number as desired "+256 700 000 000"
      String formattedPhoneNumber =
          '${phoneNumberWithoutSpaces.substring(0, 4)} ${phoneNumberWithoutSpaces.substring(4, 7)} ${phoneNumberWithoutSpaces.substring(7, 10)} ${phoneNumberWithoutSpaces.substring(10)}';

      // Set the formatted phone number to the controller
      phoneNumber.text = formattedPhoneNumber;
    }
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
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center content horizontally
              children: [
                const SizedBox(height: 20),
                //Enter 6 digit code sent to your phone
                const Text(
                  "Enter phone number registered with IPPU Membership APP(eg. +256 700 000 000)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center, // Center text
                ),
                const SizedBox(height: 20),
                inputTextField("Phone Number", phoneNumber, context),
                const SizedBox(height: 20),
                SendOTPButton("NEXT"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget SendOTPButton(String text) => ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                //get the phone number and remove all spaces
                String formattedPhoneNumber =
                    phoneNumber.text.replaceAll(' ', '');
                await phoneAuthentication(formattedPhoneNumber);
              },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              Colors.blue), // Set button background color to blue
        ),
        child: isLoading
            ? const Text("loading........")
            : Text(
                text,
                style: const TextStyle(
                    color: Colors.white), // Set text color to white
              ),
      );

  Widget inputTextField(String labelText,
          TextEditingController textEditingController, BuildContext context) =>
      Padding(
        padding: const EdgeInsets.all(2.00),
        child: SizedBox(
            child: TextFormField(
          controller: textEditingController,
          inputFormatters: [PhoneNumberFormatter()],
          enabled: !isLoading,
          //set keyboard type to phone
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number.';
            }
            // You can add more validation here if needed
            return null;
          },
          onSaved: (value) {},
        )),
      );

  Future<void> phoneAuthentication(String phoneNo) async {
    if (mounted) {
      setState(() {
        isLoading = true; // Set isLoading to true when authentication starts
      });
    }
    //check if phone number is valid
    var isPhoneValid = await checkPhoneNumber(phoneNo);

    if (isPhoneValid) {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          verificationCompleted: (PhoneAuthCredential credential) async {
            //get the otp code
            OTPCode = credential.smsCode;
          },
          verificationFailed: (e) {
            if (e.code == 'invalid-phone-number') {
              Get.snackbar('Error', 'The provided phone number is not valid.');
            } else {
              Get.snackbar('Error', 'Something went wrong. Try again');
            }
            if (mounted) {
              setState(() {
                isLoading =
                    false; // Set isLoading to false when authentication ends
              });
            }
          },
          codeSent: (verificationId, resendToken) async {
            this.verificationId.value = verificationId;

            //Navigate Digitcode screen()
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Digitcode(
                  phoneNumber: phoneNo,
                  auth: _auth,
                  verificationId: verificationId,
                  OTPCode: OTPCode,
                ),
              ),
            );

            if (mounted) {
              setState(() {
                isLoading =
                    false; // Set isLoading to false when authentication ends
              });
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {
            this.verificationId.value = verificationId;
            if (mounted) {
              setState(() {
                isLoading =
                    false; // Set isLoading to false when authentication ends
              });
            }
          },
        );
      } catch (e) {
        Get.snackbar('Error', 'Something went wrong. Try again');
        if (mounted) {
          setState(() {
            isLoading =
                false; // Set isLoading to false when authentication ends
          });
        }
      }
    } else {
      Get.snackbar('Error', 'Phone number not registered. Please register');
      if (mounted) {
        setState(() {
          isLoading = false; // Set isLoading to false when authentication ends
        });
      }
    }
  }

  Future<bool> checkPhoneNumber(String phone) async {
    AuthController authController = AuthController();

    final response = await authController.checkPhoneNumber(phone);
    //check if response status is success
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }
}
