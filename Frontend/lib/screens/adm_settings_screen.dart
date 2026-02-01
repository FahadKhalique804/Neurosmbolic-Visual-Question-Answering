import 'package:flutter/material.dart';
import 'validate_cfg_screen.dart';
import 'see_all_blinds_screen.dart';
import 'see_all_assistants_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(
        color: Colors.white, // <-- back arrow color
        ),
        title: const Text("Settings",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(
            context,
            "Validate CFG",
            Icons.rule,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ValidateCFGScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            "See All Blinds",
            Icons.remove_red_eye,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeeAllBlindsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            "See All Assistants",
            Icons.group,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeeAllAssistantsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
