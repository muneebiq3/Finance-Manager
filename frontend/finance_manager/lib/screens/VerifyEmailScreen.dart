import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/AnimatedSnackBar.dart';
import '../widgets/ManualWidgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {

  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    
    if (!isEmailVerified) {

      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );

    }

  }

  @override
  void dispose () {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {

      timer?.cancel();
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login_screen');
      }

    }

  }

  Future sendVerificationEmail () async {

    try {
      
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

    } catch (e) {
      AnimatedSnackBar.show(context, e.toString());
    }
    
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

              child: isEmailVerified

              ? const CircularProgressIndicator()
              : Column(

                mainAxisSize: MainAxisSize.min,
                children: <Widget> [

                  ManualWidgets.title(),
                  Center(
                    child: ManualWidgets.message("A verificiation email has been sent to your email address.\n\nPlease verify to continue!")
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(

                    icon: const Icon(Icons.refresh),
                    label: const Text('Resend Email'),
                    onPressed: sendVerificationEmail,
                    
                    style: ElevatedButton.styleFrom(
              
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
              
                    ),
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