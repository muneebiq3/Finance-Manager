import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/LoginScreen.dart';
import 'screens/SignupScreen.dart';
import 'screens/HomeScreen.dart';
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
        primarySwatch: Colors.orange
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