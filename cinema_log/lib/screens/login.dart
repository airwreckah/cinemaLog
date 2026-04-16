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
import 'package:firebase_auth/firebase_auth.dart';

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

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  // Reset password dialog
  Future<void> _resetPassword() async {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101728),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Reset Password",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Enter your email",
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4F39F6)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email")),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(color: Color(0xFF4F39F6)),
              ),
            ),
          ],
        );
      },
    );
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
                      ),
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

                // Forgot Password button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25.0, bottom: 10),
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFF4F39F6)),
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
            icon: Icon(Icons.bookmark_border), //List tab
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
