import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/LoginScreen.dart';
import 'screens/SignupScreen.dart';
import 'screens/VerifyEmailScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/SavedSavingsPlanScreen.dart';
import 'screens/ForgotPasswordScreen.dart';
import 'screens/AddExpenseScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Smart Finance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF266DD1),
          secondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF266DD1), 
          brightness: Brightness.dark
        )
      ),
      themeMode: ThemeMode.system,

      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
      routes: {
        '/signup_screen': (context) => SignupScreen(),
        '/verify_email_screen': (context) => VerifyEmailScreen(),
        '/login_screen': (context) => LoginScreen(),
        '/forgot_password_screen' : (context) => ForgotPasswordScreen(),
        '/home_screen': (context) => HomeScreen(),
        '/add_expense': (context) => AddExpenseScreen(),
        '/saved_savings_plans': (context) => SavedSavingsPlansScreen(),

      },
    );
  }
}