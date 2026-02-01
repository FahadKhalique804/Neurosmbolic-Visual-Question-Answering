import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';

class SeeAllBlindsScreen extends StatefulWidget {
  const SeeAllBlindsScreen({super.key});

  @override
  State<SeeAllBlindsScreen> createState() => _SeeAllBlindsScreenState();
}

class _SeeAllBlindsScreenState extends State<SeeAllBlindsScreen> {
  List<dynamic> blinds = [];
  bool _loading = true;

  Future<void> _fetchBlinds() async {
    try {
      final response = await http.get(Uri.parse(Api.seeAllBlinds));
      if (response.statusCode == 200) {
        setState(() => blinds = json.decode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
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

  @override
  void initState() {
    super.initState();
    _fetchBlinds();
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
        title: const Text("All Blinds",
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
              itemCount: blinds.length,
              itemBuilder: (context, index) {
                final blind = blinds[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue[700]),
                    title: Text(blind["blind_name"] ?? "Unknown"),
                    subtitle: Text(
                      "ID: ${blind["id"] ?? "N/A"} • Age: ${blind["blind_age"] ?? "-"} • Gender: ${blind["blind_gender"] ?? "-"}\n"
                      "Assistant: ${blind["assistant_name"] ?? "None"}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
