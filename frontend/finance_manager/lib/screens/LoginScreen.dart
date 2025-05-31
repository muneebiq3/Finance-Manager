import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool hidePassword = true;

  String? errorMessage = '';
  String successMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  void _signIn() async {

    String email = _controllerEmail.text;
    String password = _controllerPassword.text;

    try {

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      setState(() {
        successMessage = 'Logged in successfully!';
      });

      await Future.delayed(const Duration(seconds: 2));

      if (userCredential.user != null) {
        // Navigate to home screen if sign-in is successful
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home_screen');
        }
      }
    }

    on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }

    catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again!';
      });
    }
    
  }

  Widget _title() {
    return const Text(
      "Smart Finance",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller, String placeholder, bool hide) {
    return TextField(
      controller: controller,
      obscureText: hide,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _passwordField(String title, TextEditingController controller, String placeholder) {
    return TextField(
      controller: controller,
      obscureText: hidePassword,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              hidePassword = !hidePassword;
            });
          }, 
          icon: Icon(
            hidePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          )
        )
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _successMessage() {
    return Text(
    successMessage.isEmpty ? '' : successMessage,
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () {
        _signIn();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Login'),
    );
  }

  Widget _signUpButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => const SignupScreen()
          )
        );
      },
      child: const Text(
        'Not a User? Register Now!',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF266DD1), // Darker shade
              Color(0xFF90B3E9), // Primary theme color
              Color(0xFFB3CFF1), // Lighter shade
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _title(),
                const SizedBox(height: 40),
                _entryField('Email', _controllerEmail, 'Enter your Email', false),
                const SizedBox(height: 30),
                _passwordField('Password', _controllerPassword, 'Enter Password'),
                const SizedBox(height: 10),
                _errorMessage(),
                const SizedBox(height: 20),
                _successMessage(),
                const SizedBox(height: 10),
                _loginButton(),
                const SizedBox(height: 20),
                _signUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}