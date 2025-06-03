import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../themes/images.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _controllerEmail = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future <void> _resetPassword(BuildContext context) async{

    String email = _controllerEmail.text.trim();

    if(!_formKey.currentState!.validate()) return;

    try {
      
      if(email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please enter your email!"
            )
          )
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Reset Password link sent to $email"
            )
          )
        );

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${e.message}'
          )
        )
      );
    } 
    finally {
      setState(() {
        _isLoading = false;
      });
    }

    return;
  }

  @override
  void dispose () {
    _controllerEmail.dispose();
    super.dispose();
  }

  Widget _title() {
    return Image.asset(Images.wallet, height: 100, width: 100,);
  }

  Widget _message() {
    return const Text(
      "Smart Finance - Reset Password",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller, String placeholder, bool hide) {
    return Form(
      key: _formKey,
      child: TextFormField(
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
        validator: (value) => value == null || !value.contains('@')
          ? 'Enter a valid email!'
          : null
      ),
    );
  }

  Widget _sendButton(double width, BuildContext context) {
    return SizedBox(
      width: width * 1,
      child: ElevatedButton(
        onPressed: () => _isLoading ? null : _resetPassword(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text('Reset Password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

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
          )
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white,
                    size: 25,
                  )
                )
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _title(),
                      const SizedBox(height: 40),
                      _message(),
                      const SizedBox(height: 40),
                      _entryField('Email', _controllerEmail, 'Enter your Email', false),
                      const SizedBox(height: 20),
                      Builder(builder: (context) => _sendButton(width, context)),
                    ],
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}