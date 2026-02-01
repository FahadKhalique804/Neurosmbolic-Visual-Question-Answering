import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/assistant_home_screen.dart';
import 'screens/qna_screen.dart';
import 'screens/add_rule_screen.dart';   


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),

        // Role-based dashboards
        '/admin': (context) => AdminScreen(),
        '/assistant': (context) => const AssistantHomeScreen(user: {}), 

        '/qa': (context) => const QAScreen(),

        // Rule management
        '/add-rule': (context) => AddRuleScreen(),
        
      },
    );
  }
}
