import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Screens/DefaultScreen.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/ForgotPasswordScreen.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/PhoneAuthlogin.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/RegisterScreen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

import 'package:ippu/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginPasswordVisible = false;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginForm() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _isSigningIn = true);
      try {
        final authResponse = await AuthController().signIn(
          _emailController.text,
          _passwordController.text,
        );
        if (!mounted) return;
        if (authResponse.containsKey('error')) {
          _showErrorSnackBar("Invalid credentials. Please try again.");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DefaultScreen()),
          );
        }
      } catch (e) {
        _showErrorSnackBar("Something went wrong. Please try again later.");
      } finally {
        if (mounted) setState(() => _isSigningIn = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2A81C9),
                const Color(0xFF2A81C9).withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(size),
                  SizedBox(height: size.height * 0.025),
                  _buildWelcomeText(size),
                  SizedBox(height: size.height * 0.03),
                  _buildLoginForm(size),
                  SizedBox(height: size.height * 0.03),
                  _buildSocialLoginButtons(size),
                  SizedBox(height: size.height * 0.03),
                  _buildSignUpPrompt(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Container(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: size.height * 0.1,
        width: size.width * 0.7,
        child: Image.asset(
          "assets/ppulogo.png",
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildWelcomeText(size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.montserrat(
            fontSize: size.height * 0.026,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Sign in to continue to IPPU Membership App",
          style: GoogleFonts.lato(
            fontSize: size.height * 0.017,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(Size size) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            hintText: "Email",
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              final RegExp emailRegExp = RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
              );
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!emailRegExp.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: size.height * 0.018),
          _buildTextField(
            controller: _passwordController,
            hintText: "Password",
            prefixIcon: Icons.lock_outline,
            obscureText: !_isLoginPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _isLoginPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(
                  () => _isLoginPasswordVisible = !_isLoginPasswordVisible),
            ),
          ),
          SizedBox(height: size.height * 0.008),
          GestureDetector(
            onTap: _isSigningIn
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot password?",
                    style: GoogleFonts.lato(
                      fontSize: size.height * 0.014,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size.height * 0.018),
          ElevatedButton(
            onPressed: _isSigningIn ? null : _loginForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.height * 0.01),
              ),
            ),
            child: _isSigningIn
                ? const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2A81C9)),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.montserrat(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A81C9),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(Size size) {
    return Column(
      children: [
        const Text(
          "Or continue with",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              "assets/google.svg",
              "Google",
              () async {
                setState(() => _isSigningIn = true);
                try {
                  final response = await AuthController().signInWithGoogle();
                  if (!mounted) return;
                  if (response) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DefaultScreen()),
                    );
                  } else {
                    _showErrorSnackBar(
                        "Google Sign In failed. Please try again.");
                  }
                } finally {
                  if (mounted) setState(() => _isSigningIn = false);
                }
              },
            ),
            const SizedBox(width: 16),
            if (Platform.isAndroid)
              _buildSocialButton(
                null,
                "Phone",
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthLogin())),
              )
            else
              SignInWithAppleButton(
                onPressed: () async {
                  // Implement Apple Sign In logic here
                },
                style: SignInWithAppleButtonStyle.white,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      String? iconPath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: _isSigningIn ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconPath == null
                ? Icon(Icons.phone, color: Colors.blue[600]!)
                : SvgPicture.asset(iconPath, height: 24, width: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        GestureDetector(
          onTap: _isSigningIn
              ? null
              : () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: Text(
            "Sign Up",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
