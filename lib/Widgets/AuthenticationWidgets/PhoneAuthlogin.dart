import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isLoading = false;

  TextEditingController phoneNumber = TextEditingController(text: '+256');
  TextEditingController otp = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      String phoneNumberWithoutSpaces = widget.phoneNumber!.replaceAll(' ', '');
      String formattedPhoneNumber =
          '${phoneNumberWithoutSpaces.substring(0, 4)} ${phoneNumberWithoutSpaces.substring(4, 7)} ${phoneNumberWithoutSpaces.substring(7, 10)} ${phoneNumberWithoutSpaces.substring(10)}';
      phoneNumber.text = formattedPhoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A81C9),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A81C9), Color(0xFF1E5F94)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.18),
                  Text(
                    "Phone Login",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Enter your registered phone number\n(Format: +256 75xxxxxxx)",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.06),
                  inputTextField("Phone Number", phoneNumber, context),
                  SizedBox(height: size.height * 0.06),
                  SendOTPButton("SEND OTP"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget SendOTPButton(String text) => ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                String formattedPhoneNumber =
                    phoneNumber.text.replaceAll(' ', '');
                await phoneAuthentication(formattedPhoneNumber);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A81C9)),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  color: Color(0xFF2A81C9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );

  Widget inputTextField(String labelText,
          TextEditingController textEditingController, BuildContext context) =>
      TextFormField(
        controller: textEditingController,
        inputFormatters: [PhoneNumberFormatter()],
        enabled: !isLoading,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number.';
          }
          return null;
        },
        onSaved: (value) {},
      );

  Future<void> phoneAuthentication(String phoneNo) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    var isPhoneValid = await checkPhoneNumber(phoneNo);

    if (isPhoneValid) {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          verificationCompleted: (PhoneAuthCredential credential) async {
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
                isLoading = false;
              });
            }
          },
          codeSent: (verificationId, resendToken) async {
            this.verificationId.value = verificationId;

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
                isLoading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {
            this.verificationId.value = verificationId;
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        );
      } catch (e) {
        Get.snackbar('Error', 'Something went wrong. Try again');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      Get.snackbar('Error', 'Phone number not registered. Please register');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> checkPhoneNumber(String phone) async {
    AuthController authController = AuthController();

    final response = await authController.checkPhoneNumber(phone);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }
}
