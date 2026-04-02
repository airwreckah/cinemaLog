import 'dart:math';
import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/services/authService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/controller.dart';
import 'welcome_user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final Controller _controller = Controller();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _controller.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeUser()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                'Please sign in to start tracking what you watch',
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
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 16, height: 2.0),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      contentPadding: EdgeInsets.all(15), // Example of a moving label
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
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16, height: 2.0),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      contentPadding: EdgeInsets.all(15), // Example of a moving label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Example of a moving label
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
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
                    style:TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4F39F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding( 
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                      "Don't have an account? ",
                      style: TextStyle(color: const Color(0xFF99A1AF), fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Sign_Up()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), 
                        child: Text(
                        'Sign Up',
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
