import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import 'add_rule_screen.dart';
import 'add_vocabulary_screen.dart';
import 'login_screen.dart';
import 'adm_settings_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> rules = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchRules();
  }

  Future<void> fetchRules() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse(Api.getCfgRules));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rules = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Admin Home",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.accessibility_new, size: 80, color: Colors.black87),
                SizedBox(width: 20),
                Icon(Icons.remove_red_eye, size: 80, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            const Text(
              "CFG Manager",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),

            // Rules Card
            Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CFG Rules",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : rules.isEmpty
                          ? const Text(
                              "No rules found",
                              style: TextStyle(color: Colors.white70),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rules.length,
                              itemBuilder: (context, index) {
                                final rule = rules[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                   "${rule["lhs"]} → ${rule["rhs"]}",
                                    style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add New Rule",
              style: TextStyle(color: Colors.white),),
              onPressed: () async {
              final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddRuleScreen()),
              );
             if (result == true) {
                fetchRules(); // refresh after adding
              }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.book, color: Colors.white),
              label: const Text("Add New Vocabulary",
              style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddVocabularyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
