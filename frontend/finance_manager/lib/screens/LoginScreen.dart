import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'SignupScreen.dart';
import '../themes/images.dart';

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

    
    if (email.isEmpty && password.isEmpty) {
      _showTopSnackBar(context, 'Please enter your credentials!');
      return;
    }

    if (email.isEmpty) {
      _showTopSnackBar(context, 'Please enter your email!');
      return;
    }

    
    if (!email.contains('@')) {
      _showTopSnackBar(context, "Please enter a valid email address!");
      return;
    }

    if (password.isEmpty) {
      _showTopSnackBar(context, 'Please enter the password!');
      return;
    }

    try {

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      _showTopSnackBar(context, 'Logged in successfully!');

      await Future.delayed(const Duration(seconds: 2));

      if (userCredential.user != null) {
        // Navigate to home screen if sign-in is successful
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home_screen');
        }
      }
    }

    on FirebaseAuthException catch (e) {

      String errorMessage = 'An error occurred';

      switch (e.code) {

        case 'invalid-email':
          errorMessage = 'The email is badly formatted!';
          break;

        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;

        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;

        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;

        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;

        default:
          errorMessage = e.message ?? errorMessage;

      }

      if (context.mounted) {
        _showTopSnackBar(context, errorMessage);
      }

    }

    catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again!';
      });
    }
    
  }

  Widget _title() {
    return Image.asset(
      Images.wallet, 
      height: 100, 
      width: 100
    );
  }

  Widget _message() {
    return const Text(
      "Welcome back, you have been missed!",
      style: TextStyle(
        fontSize: 16,
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

  void _showTopSnackBar(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF90B3E9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 3),
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

  Future <bool> _googleLogin() async {

    final user = await GoogleSignIn().signIn();

    GoogleSignInAuthentication userAuth = await user!.authentication;

    var credential = GoogleAuthProvider.credential(idToken: userAuth.idToken, accessToken: userAuth.accessToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    return FirebaseAuth.instance.currentUser != null;

  }

  Widget _googleLoginButton() {

    return InkWell(
      
      onTap: ()  async{

        bool isLogged = await _googleLogin();

        if (isLogged) {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home_screen');
          }
        }

      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Image.asset(
          Images.google,
          height: 30,
          width: 30,
        ),
      ),
    );
  }

    Widget _githubLoginButton() {
    
    return InkWell(
      
      onTap: ()  async{

      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Image.asset(
          Images.github,
          height: 30,
          width: 30,
        ),
      ),
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

    Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: ()  => Navigator.pushNamed(context, '/forgot_password_screen'),
      child: const Text(
        'Forgot Password?',
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _title(),
                  _message(),
                  const SizedBox(height: 20),
                  _entryField('Email', _controllerEmail, 'Enter your Email', false),
                  const SizedBox(height: 20),
                  _passwordField('Password', _controllerPassword, 'Enter Password'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _forgotPasswordButton(),
                    ],
                  ),
                  _loginButton(),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _googleLoginButton(),
                      const SizedBox(width: 10),
                      _githubLoginButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _signUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}