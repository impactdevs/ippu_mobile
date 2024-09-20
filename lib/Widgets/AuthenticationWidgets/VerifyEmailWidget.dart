import 'package:flutter/material.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:http/http.dart' as http;

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  //add key parameter
  const VerificationCodeScreen({super.key, required this.email});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter the 6-digit verification code sent to your email',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '• • • • • •',
                counterText: '',
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () async {
                // Validate the entered verification code and proceed accordingly
                num verificationCode =
                    num.parse(_verificationCodeController.text);
                print('verification code: $verificationCode');
                // Implement logic to validate the verification code (compare with the stored code)
                if (await verificationCodeIsValid(verificationCode)) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                } else {
                  // Code is invalid, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Invalid verification code. Please try again.')),
                  );
                }
              },
              child: const Text('Verify'),
            ),

            // Add a button to resend the verification code
            TextButton(
              onPressed: () async {
                // Implement logic to resend the verification code
                final email = widget.email;
                final response = await http.post(
                    Uri.parse(
                        'https://staging.ippu.org/api/profile/resend-verification-code'),
                    body: {'email': email});
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Verification code sent to your email. Please check your inbox.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Failed to send verification code. Please try again.')),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Text('Didn\'t get the code?Resend verification code'),
            ),

            //go to login screen
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize
                    .min, // Set to only take the minimum required width
                children: [
                  Icon(Icons.arrow_back_ios_rounded),
                  SizedBox(width: 8), // Adjust the space between icon and text
                  Text('Go to Login'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Implement your logic to validate the verification code
  Future<bool> verificationCodeIsValid(num verificationCode) async {
    final email = widget.email;

    final response = await http.post(
        Uri.parse('https://staging.ippu.org/api/profile/verify-email'),
        body: {'email': email, 'code': verificationCode.toString()});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
