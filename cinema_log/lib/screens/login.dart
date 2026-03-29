import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:cinema_log/services/authService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login>{
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String email = '';
  String password = '';


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
                SizedBox(height:25),
                SizedBox(
                  height:75,
                  width: 350,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                         return 'Please enter some text';
                      }
                      return null;
                    }, 
                    onChanged: (value) {
                      setState(() => email = value);
                    },
                    style: TextStyle(
                      fontSize:16,
                      height: 2.0,
                    ),
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
                  height:75,
                  width: 350,
                  child:TextFormField(
                    validator: (value){
                       if (value == null || value.isEmpty) {
                         return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() => password = value);
                    },
                    style: TextStyle(
                    fontSize:16,
                    height: 2.0,
                    ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: EdgeInsets.all(15), // Example of a moving label
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    ), // Example of a moving label
                  ),
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
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                    ),
                  ),
                  onPressed: () async{
                    if(_formKey.currentState!.validate()){
                      dynamic result = await _authService.signIn(email, password);
                      if(result == null){
                        setState((){
                          error = 'Could not sign in';
                        });
                      }else{
                        Navigator.push(context, MaterialPageRoute<void>(builder: (context) => Welcome_new()),
                    );
                      }
                    }
                  }
                ),
                ),
              ]
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