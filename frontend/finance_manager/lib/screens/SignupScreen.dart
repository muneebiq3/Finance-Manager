import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupScreen> {

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  String? errorMessage = '';
  String successMessage ='';

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

  Future<int> _getNextUserId() async {
    DocumentReference counterDoc = FirebaseFirestore.instance.collection('MetaData').doc('UserCounter');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterDoc);

      int currentCount = snapshot.exists ? (snapshot.get('counter') as int) : 0;
      int nextCount = currentCount + 1;

      // Update the counter for the next user
      transaction.set(counterDoc, {'counter': nextCount}, SetOptions(merge: true));
      return nextCount;
    });
  }

  void _signUp() async {

    String name = _controllerName.text;
    String email = _controllerEmail.text;
    String contact = _controllerContact.text;
    String password = _controllerPassword.text;
    String confirmPassword = _controllerConfirmPassword.text;

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match!';
      });
      return; // Exit the function if passwords don't match
    }

    try {
      // Sign up using your custom FirebaseAuthService
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        
        name = capitalizeName(name);

        user.updateDisplayName(name);

        // Generate a new userId
        int userId = await _getNextUserId();

        // Save user details to Firestore in nested collection
        await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .set({
            'id': user.uid,
            'Email': email,
            'Name': name,
            'Contact': contact,
            'CreatedAt': DateTime.now(),
            'User Id' : userId.toString(),
        });

        setState(() {
            successMessage = 'Account created successfully!';
        });

        await Future.delayed(const Duration(seconds: 2));
        
        // Navigate to login screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
        setState(() {
          errorMessage = 'An unexpected error occurred. Please try again.';
      });
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

  Widget _entryField(String title, TextEditingController controller, String placeholder) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
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
      ),
    );
  }

  Widget _passwordField(String title, TextEditingController controller, String placeholder, bool obscureText, VoidCallback toggleVisibility) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
            onPressed: toggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            )
          )
        ),
        style: const TextStyle(color: Colors.white),
      ),
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

  Widget _signUpButton() {
    return ElevatedButton(
      onPressed: _signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Register'),
    );
  }

  Widget _logInButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => const LoginScreen()
          )
        );
      },
      child: const Text(
        'Already a User? Sign In!',
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
                const SizedBox(height: 20),
                _entryField('Name', _controllerName, 'Enter your name'),
                const SizedBox(height: 20),
                _entryField('Email', _controllerEmail, 'Enter your email'),
                const SizedBox(height: 20),
                _entryField('Contact', _controllerContact, 'Enter your contact'),
                const SizedBox(height: 20),
                _passwordField(
                  'Password',
                  _controllerPassword, 
                  'Enter Password', 
                  hidePassword, 
                  () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  }
                ),
                const SizedBox(height: 20),
                _passwordField(
                  'Confirm Password',
                  _controllerConfirmPassword, 
                  'Please confirm Password', 
                  hideConfirmPassword, () {
                    setState(() {
                      hideConfirmPassword = !hideConfirmPassword;
                    });
                  }
                ),
                const SizedBox(height: 4),
                _errorMessage(),
                const SizedBox(height: 10),
                _successMessage(),
                const SizedBox(height: 10),
                _signUpButton(),
                const SizedBox(height: 10),
                _logInButton(),
              ], 
            ),
          ),
        ),
      ),
    );
  }
}