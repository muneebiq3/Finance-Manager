import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SavingsPlanScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double totalIncome = 0;
  double spentAmount = 0;
  Map<String, double> categoryExpenses = {};
  String? userId;
  String currentMonth = "";
  User? user;
  final TextEditingController _budgetController = TextEditingController();

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
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "User Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? "user@example.com", style: TextStyle(fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF266DD1)),
              ),
              decoration: BoxDecoration(color: Color(0xFF266DD1)),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFEEEEF1).withOpacity(0.8),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.savings, color: Colors.black),
                      title: Text("Savings Plan", style: TextStyle(color: Colors.black, fontSize: 18)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SavingsPlanScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        }, 
                        icon: const Icon(Icons.menu),
                        iconSize: 30,
                        color: Colors.white,
                      ),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        )
                      ),
                      IconButton(
                        onPressed: logout, 
                        icon: const Icon(Icons.logout),
                        color: Colors.white,
                        iconSize: 30,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 40),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
                        width: MediaQuery.of(context).size.width / 1,
                        decoration: BoxDecoration(
                          color:  const Color(0xFFEEEEF1).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(7)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Month: $currentMonth', 
                              style: TextStyle(
                                color: const Color(0xFF898C8D), 
                                fontSize: 16
                              )
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Total Income: \$${totalIncome.toStringAsFixed(2)}", 
                              style: TextStyle(
                                fontSize: 16, 
                                color: const Color(0xFF898C8D)
                              )
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}", 
                              style: TextStyle(
                                fontSize: 19, 
                                color:  Color(0xFF343740),
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Enter this month's budget (PKR)",
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white
                              )
                            )
                          ),
                        ),
                      ),
                      // SizedBox(width: 20),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     final result = await Navigator.pushNamed(context, '/add_expense');
                      //     if (result != null) {
                      //       Map<String, dynamic> expenseData = result as Map<String, dynamic>;
                      //       addExpense(expenseData['category'], expenseData['amount']);
                      //     }
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      //     backgroundColor: Color(0xFF266DD1),
                      //   ),
                      //   child: Text(
                      //     "Add Expense", 
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold, 
                      //       fontSize: 12, 
                      //       color: Colors.white
                      //     )
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, '/add_income');
                            if (result != null) {
                              double newIncome = result as double;
                              updateIncome(newIncome);
                            }
                          }, style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF266DD1)
                          ),
                          child: const Text(
                            "Set Monthly Budget",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Updated Expenses List
                  SizedBox(
                    height: 300, // or MediaQuery.of(context).size.height * 0.4
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
        ),
      ),
    );
  }
}
