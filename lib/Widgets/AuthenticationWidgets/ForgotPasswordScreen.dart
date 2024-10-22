import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showEmailField = true;
  bool _showNewPasswordFields = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: const Color(0xFF2A81C9),
        elevation: 0,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.height * 0.024),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 30),
                if (_showEmailField) _buildEmailSection(),
                if (!_showEmailField && !_showNewPasswordFields)
                  _buildVerificationCodeSection(),
                if (_showNewPasswordFields) _buildNewPasswordSection(),
                const SizedBox(height: 20),
                _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Image.asset(
        "assets/ppulogo.png",
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Forgot Password",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Reset your password to regain access",
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: "Email",
          prefixIcon: Icons.email_outlined,
          validator: _validateEmail,
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          onPressed: _sendVerificationCode,
          label: 'Send Code',
        ),
      ],
    );
  }

  Widget _buildVerificationCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Enter the 6-digit verification code sent to ${_emailController.text}",
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _verificationCodeController,
          hintText: "• • • • • •",
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          onPressed: _verifyCode,
          label: 'Verify Code',
        ),
      ],
    );
  }

  Widget _buildNewPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _newPasswordController,
          hintText: "New Password",
          prefixIcon: Icons.lock_outline,
          obscureText: !_isPasswordVisible,
          validator: _validatePassword,
          suffixIcon: _buildVisibilityToggle(_isPasswordVisible, () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          }),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: "Confirm Password",
          prefixIcon: Icons.lock_outline,
          obscureText: !_isConfirmPasswordVisible,
          validator: _validateConfirmPassword,
          suffixIcon: _buildVisibilityToggle(_isConfirmPasswordVisible, () {
            setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
          }),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          onPressed: _resetPassword,
          label: 'Reset Password',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textAlign: textAlign,
      style: style ?? GoogleFonts.lato(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lato(color: Colors.white60),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        suffixIcon: suffixIcon,
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        counterText: '',
      ),
    );
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white70,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildActionButton(
      {required VoidCallback onPressed, required String label}) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isProcessing
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A81C9)))
          : Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2A81C9),
              ),
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Remember your password? ",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            "Login",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      try {
        final response = await http.post(
          Uri.parse('https://ippu.org/api/profile/reset-password-code'),
          body: {'email': _emailController.text},
        );

        if (response.statusCode == 200) {
          _showSnackBar('Verification code sent!');
          setState(() {
            _showEmailField = false;
            _isProcessing = false;
          });
        } else {
          _showErrorSnackBar(
              'Error sending verification code. Please try again.');
        }
      } catch (e) {
        _showErrorSnackBar('Network error. Please check your connection.');
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _isProcessing = true);
    if (await _verificationCodeIsValid()) {
      _showSnackBar('Code verified!');
      setState(() {
        _showNewPasswordFields = true;
        _isProcessing = false;
      });
    } else {
      _showErrorSnackBar('Invalid verification code. Please try again.');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      if (await _performPasswordReset()) {
        _showSnackBar('Password reset successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showErrorSnackBar('Error resetting password. Please try again.');
      }
      setState(() => _isProcessing = false);
    }
  }

  Future<bool> _verificationCodeIsValid() async {
    final response = await http.post(
      Uri.parse(
          'https://ippu.org/api/profile/verify-password-reset-email'),
      body: {
        'email': _emailController.text,
        'code': _verificationCodeController.text,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> _performPasswordReset() async {
    final response = await http.post(
      Uri.parse('https://ippu.org/api/profile/reset-password'),
      body: {
        'email': _emailController.text,
        'code': _verificationCodeController.text,
        'password': _newPasswordController.text,
      },
    );
    return response.statusCode == 200;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
