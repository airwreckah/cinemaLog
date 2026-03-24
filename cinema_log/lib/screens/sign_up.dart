import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Sign_Up extends StatefulWidget{
  const Sign_Up({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<Sign_Up>{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfController = TextEditingController();
  String? _nameErrorText;
  String? _emailErrorText;
  String? _ageErrorText;
  String? _passwordErrorText;
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override 
  void didChangeDependencies(){
    _nameErrorText = null;
    _emailErrorText = null;
    _ageErrorText = null;
    _passwordErrorText = null;
    super.didChangeDependencies();
  }

  void _nameValidate() {
    if (_nameController.value.text.isEmpty) {
      _nameErrorText = 'Can\'t be empty';
    } else {
      _nameErrorText = null;
    }
  }

  void _ageValidate() {
    if (_nameController.value.text.isEmpty) {
      _nameErrorText = 'Can\'t be empty';
    } else {
      _nameErrorText = null;
    }
  }

  void _passwordValidate() {
    if (_passwordController.value.text.isEmpty) {
      _passwordErrorText = 'Can\'t be empty';
    } else if (_passwordController.value.text.length < 4) {
      _passwordErrorText = 'Too short';
    } else {
      _passwordErrorText = null;
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:  GradientText(
          'Cinema Log',
          style: TextStyle(
          fontSize: 30,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
          height: 1.33,
          letterSpacing: -1.20,
          ), 
          colors : [Color(0xFF615FFF), Color(0xFFAD46FF)],//header title
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
                SizedBox(height:25),
          SizedBox(
            height:75,
            width: 350,
            child: TextFormField(
              style: TextStyle(
                fontSize:16,
                height: 2.0,
              ),
              decoration: InputDecoration(
                labelText: 'Full Name',
                contentPadding: EdgeInsets.all(15), // Example of a moving label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              controller: _nameController,
            ),
          ),
          SizedBox(
            height:75,
            width: 350,
            child:TextFormField(
              style: TextStyle(
              fontSize:16,
              height: 2.0,
              ),
            decoration: InputDecoration(
              labelText: 'Email Address',
              contentPadding: EdgeInsets.all(15), // Example of a moving label
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              ), // Example of a moving label
            ),
            controller: _emailController,
            ),
          ),
          SizedBox(
            height:75.0,
            width: 350,
            child: TextFormField(
              style: TextStyle(
              fontSize:16,
              height: 2.0,
              ),
              decoration:  InputDecoration(
              labelText: 'Enter your age',
              contentPadding: EdgeInsets.all(15), // Example of a moving label
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
                ), // Example of a moving label
              ),
              controller: _ageController,
              ),
          ),
          SizedBox(
            height:75,
            width: 350,
            child: TextFormField(
              style: TextStyle(
              fontSize:16,
              height: 2.0,
              ),
            decoration: InputDecoration(
              labelText: 'Enter your password',
              contentPadding: EdgeInsets.all(15), // Example of a moving label
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              ), // Example of a moving label
            ),
            controller: _passwordController,
            ),
          ),
          SizedBox(
            height:75.0,
            width: 350,
            child: TextFormField(
              style: TextStyle(
              fontSize:16,
              height: 2.0,
              ),
            decoration: InputDecoration(
              labelText: 'Confirm password',
              contentPadding: EdgeInsets.all(15), // Example of a moving label
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              ), // Example of a moving label
            ),
            controller: _passwordConfController
            ),
          ),
          Container(
          width: 350,
          height: 60,
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: const Color(0xFF4F39F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: ElevatedButton(
            child: Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16
              ),
            ),
            onPressed: (){
              if(_formKey.currentState!.validate()){

              }
            }
          ),
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
              icon: Icon(Icons.home),//Home tab
              label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),//Searflch tab
              label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),//List tab
              label: 'Lists'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),//Profile tab
              label: 'Profile',
              ),
          ],
        ), 
    );
  }
}