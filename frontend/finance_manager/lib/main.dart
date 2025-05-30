import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/LoginScreen.dart';
import 'screens/SignupScreen.dart';
import 'screens/DashboardScreen.dart';
import 'screens/SavedSavingsPlanScreen.dart';
import 'screens/AddIncomeScreen.dart';
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
      title: 'AI-Powered Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const DashboardScreen(),
      routes: {
        '/signup_screen': (context) => SignupScreen(),
        '/login_screen': (context) => LoginScreen(),
        '/dashboard_screen': (context) => DashboardScreen(),
        '/add_income': (context) => AddIncomeScreen(),
        '/add_expense': (context) => AddExpenseScreen(),
        '/saved_savings_plans': (context) => SavedSavingsPlansScreen(),

      },
    );
  }
}