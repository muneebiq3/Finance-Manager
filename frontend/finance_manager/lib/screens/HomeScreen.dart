import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SavingsPlanScreen.dart';
import 'ProfileScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalIncome = 0;
  double spentAmount = 0;
  Map<String, double> categoryExpenses = {};
  String? userId;
  String currentMonth = "";
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    currentMonth = getCurrentMonth();
    if (user != null) {
      fetchNumericUserId(user!.uid);
    }
    currentMonth = getCurrentMonth();
  }

  Future<void> fetchNumericUserId(String firebaseUid) async {
  // Find the user document with matching `id` field (Firebase UID)
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Users')
      .where('id', isEqualTo: firebaseUid)
      .get();

  if (snapshot.docs.isNotEmpty) {
    setState(() {
      userId = snapshot.docs.first.id; // This is your numeric ID as string
    });
    checkAndCreateNewMonth();
  }
}

  String getCurrentMonth() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  Future<void> checkAndCreateNewMonth() async {
    if (userId == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('records')
        .doc(currentMonth)
        .get();

    if (!snapshot.exists) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('records')
          .doc(currentMonth)
          .set({
        'totalIncome': 0,
        'spentAmount': 0,
        'categoryExpenses': {},
      });
    }

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (userId == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('records')
        .doc(currentMonth)
        .get();

    if (snapshot.exists) {
      setState(() {
        totalIncome = (snapshot['totalIncome'] ?? 0).toDouble();
        spentAmount = (snapshot['spentAmount'] ?? 0).toDouble();
        categoryExpenses = Map<String, double>.from(
            snapshot['categoryExpenses']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {});
      });
    }
  }

  Future<void> updateIncome(double income) async {
    if (userId == null) return;
    setState(() {
      totalIncome = income;
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('records')
        .doc(currentMonth)
        .set({
      'totalIncome': totalIncome,
    }, SetOptions(merge: true));
  }

  Future<void> addExpense(String category, double amount) async {
    if (userId == null) return;

    setState(() {
      spentAmount += amount;
      categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('records')
        .doc(currentMonth)
        .set({
      'spentAmount': spentAmount,
      'categoryExpenses': categoryExpenses,
    }, SetOptions(merge: true));
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login_screen');
  }

  @override
  Widget build(BuildContext context) {
    double remainingBalance = totalIncome - spentAmount;

    return Scaffold(
      drawer: Drawer(
        
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    )
                  ),
                ],
              ),
              SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color:  const Color(0xFFEEEEF1).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(7)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7)
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Month: $currentMonth', 
                            style: TextStyle(
                              color: const Color(0xFF898C8D), 
                              fontSize: 14
                            )
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Total Income: \$${totalIncome.toStringAsFixed(2)}", 
                            style: TextStyle(
                              fontSize: 14, 
                              color: const Color(0xFF898C8D)
                            )
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}", 
                            style: TextStyle(
                              fontSize: 14, 
                              color: Colors.green, 
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: totalIncome == 0 ? 0 : spentAmount / totalIncome,
                backgroundColor: Colors.grey[300],
                color: Colors.red,
                minHeight: 15,
              ),
              SizedBox(height: 10),
              Text("Spent: \$${spentAmount.toStringAsFixed(2)} / \$${totalIncome.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/add_income');
                      if (result != null) {
                        double newIncome = result as double;
                        updateIncome(newIncome);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      backgroundColor: Colors.deepPurple[800], // Replace primary with backgroundColor
                    ),
                    child: Text("Add Income", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/add_expense');
                      if (result != null) {
                        Map<String, dynamic> expenseData = result as Map<String, dynamic>;
                        addExpense(expenseData['category'], expenseData['amount']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      backgroundColor: Colors.deepPurple[800], // Replace primary with backgroundColor
                    ),
                    child: Text("Add Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Updated Expenses List
              Expanded(
                child: ListView(
                  children: categoryExpenses.entries.map((entry) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("\$${entry.value.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
