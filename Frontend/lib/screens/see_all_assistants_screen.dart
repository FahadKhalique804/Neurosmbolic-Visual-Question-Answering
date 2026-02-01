import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';

class SeeAllAssistantsScreen extends StatefulWidget {
  const SeeAllAssistantsScreen({super.key});

  @override
  State<SeeAllAssistantsScreen> createState() => _SeeAllAssistantsScreenState();
}

class _SeeAllAssistantsScreenState extends State<SeeAllAssistantsScreen> {
  List<dynamic> assistants = [];
  bool _loading = true;

  Future<void> _fetchAssistants() async {
    try {
      final response = await http.get(Uri.parse(Api.seeAllAssistants));
      if (response.statusCode == 200) {
        setState(() => assistants = json.decode(response.body));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAssistants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
         iconTheme: const IconThemeData(
         color: Colors.white, // back arrow color
        ),
        title: const Text("All Assistants",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: assistants.length,
              itemBuilder: (context, index) {
                final assistant = assistants[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.support_agent, color: Colors.blue[700]),
                    title: Text(assistant["name"] ?? "Unknown"),
                    subtitle: Text("ID: ${assistant["id"] ?? "N/A"}"),
                  ),
                );
              },
            ),
    );
  }
}
