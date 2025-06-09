import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/AnimatedSnackBar.dart';
import '../widgets/ManualWidgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _controllerEmail = TextEditingController();
  bool _isLoading = false;

  Future <void> _resetPassword(BuildContext context) async{

    String email = _controllerEmail.text.trim();

    try {
      
      if(email.isEmpty) {
        AnimatedSnackBar.show(context, 'Please enter your email!');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      AnimatedSnackBar.show(context, 'If this email is registered, a reset link has been sent to: $email');

    } on FirebaseAuthException catch (e) {

      String errorMessage = 'An error occurred';
      final code = e.code.toLowerCase();

      switch (code) {

        case 'invalid-email':
          errorMessage = 'The email is badly formatted!';
          break;

        case 'user-not-found':
          errorMessage = 'No user found for that email!';
          break;

        case 'network-request-failed':
          errorMessage = 'No internet connection. Please check your connection and try again!';
          break;

        case 'too-many-requests':
          errorMessage = 'Too many attempts! Try again later.';
          break;

        default:
          errorMessage = e.message ?? errorMessage;

      }

      if (context.mounted) {
        AnimatedSnackBar.show(context, errorMessage);
      }
      
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

                      ManualWidgets.title(),
                      const SizedBox(height: 40),
                      ManualWidgets.message("Smart Finance - Forgot Password"),
                      const SizedBox(height: 40),

                      ManualWidgets.entryField(
                        'Email',
                        _controllerEmail, 
                        'Enter your Email', 
                        false
                      ),
                      const SizedBox(height: 20),
                      ManualWidgets.sendButton(
                        text: 'Forgot Password',
                        width: MediaQuery.of(context).size.width * 1, // or just any width you want
                        isLoading: _isLoading,
                        onPressed: () => _resetPassword(context),
                      )

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