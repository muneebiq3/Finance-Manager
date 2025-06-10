import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/AnimatedSnackBar.dart';
import '../widgets/ManualWidgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupScreen> {

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerContact = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  String capitalizeName(String name) {

    if (name.isEmpty) return '';
    
    List<String> words = name.split(' '); // Split by space to handle first and last name
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase(); // Capitalize first letter, lowercase rest
      }
    }
    return words.join(' '); // Join the words back together

  }

  void _signUp() async {

  String name = _controllerName.text;
  String email = _controllerEmail.text;
  String contact = _controllerContact.text;
  String password = _controllerPassword.text;
  String confirmPassword = _controllerConfirmPassword.text;

  if (name.isEmpty || email.isEmpty || contact.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    AnimatedSnackBar.show(context, 'Please fill all the form fields!');
    return;
  }

  if (password != confirmPassword) {
    AnimatedSnackBar.show(context, 'Passwords do not match!');
    return;
  }

  try {
    // Attempt to create the user
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // Send verification email
      await user.sendEmailVerification();

      AnimatedSnackBar.show(context, 'Please verify your email to continue!');

      // Navigate to verification screen with arguments
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/verify_email_screen',
          arguments: {
            'name': capitalizeName(name),
            'contact': contact,
            'email': email,
          },
        );
      }
    }

  } on FirebaseAuthException catch (e) {
    String errorMessage = 'An error occurred';
    final code = e.code.toLowerCase();

    switch (code) {

      case 'email-already-in-use':
        errorMessage = 'This email is already in use.';
        break;

      case 'invalid-email':
        errorMessage = 'The email is badly formatted.';
        break;

      case 'too-many-requests':
        errorMessage = 'Too many attempts! Try again later.';
        break;

      case 'network-request-failed':
          errorMessage = 'No internet connection. Please check your connection and try again!';
          break;
          
      default:
        errorMessage = e.message ?? errorMessage;
    }

    if (context.mounted) {
      AnimatedSnackBar.show(context, errorMessage);
    }
  } catch (e) {
    AnimatedSnackBar.show(context, 'An unexpected error occurred. Please try again.');
  }
}


  @override
  void dispose() {
    _controllerName.dispose();
    _controllerEmail.dispose();
    _controllerContact.dispose();
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
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
          ),

        ),
        child: SafeArea(

          child: Center(

            child: SingleChildScrollView( 

              padding: const EdgeInsets.all(20),
            
              child: Column(
              
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  
                  ManualWidgets.title(),
                  ManualWidgets.message("Register for a better, faster experience!"),
                  const SizedBox(height: 20,),
              
                  ManualWidgets.entryField(
                    'Name',
                    _controllerName, 
                    'Enter your name', 
                    false
                  ),
              
                  const SizedBox(height: 20),
                  ManualWidgets.entryField(
                    'Email',
                    _controllerEmail, 
                    'Enter your Email', 
                    false
                  ),
                  const SizedBox(height: 20),
                  ManualWidgets.entryField(
                    'Contact',
                    _controllerContact, 
                    'Enter your contact number', 
                    false
                  ),
                  const SizedBox(height: 20),
                  ManualWidgets.passwordField(
                    
                    title: 'Password',
                    controller: _controllerPassword,
                    placeholder: 'Enter your password',
                    hidePassword: _hidePassword,
                    onToggleVisibility: () {
                      
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
              
                    },
              
                  ),
                  const SizedBox(height: 20),
                  ManualWidgets.passwordField(
                    
                    title: 'Password',
                    controller: _controllerConfirmPassword,
                    placeholder: 'Enter your password',
                    hidePassword: _hideConfirmPassword,
                    onToggleVisibility: () {
                      
                      setState(() {
                        _hideConfirmPassword = !_hideConfirmPassword;
                      });
              
                    },
              
                  ),
                  const SizedBox(height: 15),
                  ManualWidgets.loginRegisterButton('Register', _signUp),
                  const SizedBox(height: 10),
                  ManualWidgets.labelButton(
              
                    text: 'Already a User? Sign In!',
                    onPressed: () => Navigator.pushNamed(context, '/login_screen'),
              
                  ),
              
                ], 
              
              ),
            
            ),
          ),

        ),

      ),

    );

  }

}