import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/RegistrationFeedback.dart';
import 'package:ippu/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isRegistering = false;
  late Future<List<Map<String, dynamic>>> _accountTypes;
  int? _selectedAccountType;

  @override
  void initState() {
    super.initState();
    _accountTypes = _fetchAccountTypes();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchAccountTypes() async {
    try {
      final response = await http
          .get(Uri.parse('https://staging.ippu.org/api/account-types'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] is List && (jsonData['data'] as List).isNotEmpty) {
          final types = (jsonData['data'] as List)
              .map((entry) => {'id': entry['id'], 'name': entry['name']})
              .toList();
          // Set the first account type as the default selected value
          if (mounted) {
            setState(() {
              _selectedAccountType = types[0]['id'] as int;
            });
          }
          return types;
        }
      }
    } catch (e) {
      print('Error fetching account types: $e');
    }
    return [];
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      try {
        final Map<String, dynamic> requestData = {
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "account_type_id": _selectedAccountType,
        };

        AuthController authController = AuthController();
        final response = await authController.signUp(requestData);

        if (!response.containsKey('error')) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    RegistrationFeedback(email: _emailController.text)),
          );
        } else {
          _showErrorSnackBar(response['error']);
        }
      } catch (e) {
        _showErrorSnackBar("An error occurred. Please try again later.");
      } finally {
        if (mounted) setState(() => _isRegistering = false);
      }
    } else {
      _showErrorSnackBar(
          "Please fill in all fields and select an account type.");
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
                children: [
                  SizedBox(height: size.height * 0.05),
                  _buildLogo(size),
                  SizedBox(height: size.height * 0.025),
                  _buildWelcomeText(size),
                  SizedBox(height: size.height * 0.03),
                  _buildRegistrationForm(size),
                  SizedBox(height: size.height * 0.03),
                  _buildSignInPrompt(size),
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

  Widget _buildWelcomeText(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: GoogleFonts.montserrat(
            fontSize: size.height * 0.026,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Sign up to join IPPU Membership App",
          style: GoogleFonts.lato(
            fontSize: size.height * 0.017,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(Size size) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            hintText: "Email",
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: size.height * 0.018),
          _buildTextField(
            controller: _nameController,
            hintText: "Full Name",
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: size.height * 0.018),
          _buildTextField(
            controller: _passwordController,
            hintText: "Password",
            prefixIcon: Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          SizedBox(height: size.height * 0.018),
          _buildTextField(
            controller: _confirmPasswordController,
            hintText: "Confirm Password",
            prefixIcon: Icons.lock_outline,
            obscureText: !_isConfirmPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
          SizedBox(height: size.height * 0.018),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _accountTypes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return DropdownButtonFormField<int>(
                  value: _selectedAccountType,
                  items: snapshot.data!.map((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'] as int,
                      child: Text(type['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedAccountType = value),
                  decoration: InputDecoration(
                    hintText: "Select Account Type",
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.account_circle_outlined,
                        color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color(0xFF2A81C9),
                  style: const TextStyle(color: Colors.white),
                );
              } else {
                return const Text('No account types available',
                    style: TextStyle(color: Colors.white));
              }
            },
          ),
          SizedBox(height: size.height * 0.03),
          ElevatedButton(
            onPressed: _isRegistering ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.height * 0.01),
              ),
            ),
            child: _isRegistering
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2A81C9)),
                    ),
                  )
                : Text(
                    'Sign Up',
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

  Widget _buildSignInPrompt(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: GoogleFonts.lato(
            fontSize: size.height * 0.016,
            color: Colors.white70,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            "Sign In",
            style: GoogleFonts.montserrat(
              fontSize: size.height * 0.018,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
