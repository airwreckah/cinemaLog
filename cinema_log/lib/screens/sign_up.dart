import 'package:cinema_log/screens/login.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/services/authService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_log/screens/welcome_new.dart';

class Sign_Up extends StatefulWidget {
  const Sign_Up({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<Sign_Up> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  String error = '';
  String email = '';
  String password = '';
  String fullName = '';
  String age = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GradientText(
          'Cinema Log',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)], //header title
        ),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Watch With Us ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
                height: 1.11,
                letterSpacing: -1.80,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 280,
              child: Text(
                'Please create an account to start tracking what you watch',
                style: TextStyle(
                  color: const Color(0xFF99A1AF),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 25),
                SizedBox(
                  height: 75,
                  width: 350,
                  child: TextFormField(
                    style: TextStyle(fontSize: 16, height: 2.0),
                    onChanged: (value) {
                      setState(() {
                        fullName = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      contentPadding: EdgeInsets.all(
                        15,
                      ), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 75,
                  width: 350,
                  child: TextFormField(
                    style: TextStyle(fontSize: 16, height: 2.0),
                    onChanged: (value) {
                      setState(() => email = value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      contentPadding: EdgeInsets.all(
                        15,
                      ), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Example of a moving label
                    ),
                  ),
                ),
                SizedBox(
                  height: 75.0,
                  width: 350,
                  child: TextFormField(
                    style: TextStyle(fontSize: 16, height: 2.0),
                    onChanged: (value) {
                      setState(() => age = value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter your age',
                      contentPadding: EdgeInsets.all(
                        15,
                      ), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Example of a moving label
                    ),
                  ),
                ),
                SizedBox(
                  height: 75,
                  width: 350,
                  child: TextFormField(
                    controller: _passwordController,
                    style: TextStyle(fontSize: 16, height: 2.0),
                    obscureText: _obscurePassword,
                    onChanged: (value) {
                      setState(() => password = value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      contentPadding: EdgeInsets.all(
                        15,
                      ), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Example of a moving label
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 75.0,
                  width: 350,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onChanged: (value) {
                      setState(() => password = value);
                    },
                    style: TextStyle(fontSize: 16, height: 2.0),
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      contentPadding: EdgeInsets.all(
                        15,
                      ), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Example of a moving label
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                if (_confirmPasswordController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: Text(
                      _confirmPasswordController.text ==
                              _passwordController.text
                          ? 'Passwords match'
                          : 'Passwords do not match',
                      style: TextStyle(
                        color:
                            _confirmPasswordController.text ==
                                _passwordController.text
                            ? Colors.green
                            : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  width: 350,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF4F39F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4F39F6),
                    ),
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        dynamic result = _authService.signUp(
                          email,
                          password,
                          age,
                          fullName,
                        );
                        if (result == null) {
                          setState(() {
                            error = 'Could not sign in';
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => WelcomeUser(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding( 
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                      "Already have an account? ",
                      style: TextStyle(color: const Color(0xFF99A1AF), fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), 
                        child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: const Color(0xFF4F39F6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), //Home tab
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), //Searflch tab
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), //List tab
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), //Profile tab
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
