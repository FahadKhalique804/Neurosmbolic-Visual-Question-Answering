// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../services/api.dart';
// import 'add_pos_tag_screen.dart';

// class AddRuleScreen extends StatefulWidget {
//   const AddRuleScreen({super.key});

//   @override
//   State<AddRuleScreen> createState() => _AddRuleScreenState();
// }

// class _AddRuleScreenState extends State<AddRuleScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   bool _loading = false;

//   Future<void> _fetchPosTags() async {
//     final question = _questionController.text.trim();

//     if (question.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a question")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final response = await http.post(
//         Uri.parse(Api.getPosTags),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({"question": question}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddPosTagScreen(
//               question: question,
//               posTags: data["PosTags"],
//               rule: data["Rule"],
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Rule")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _questionController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Question",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _fetchPosTags,
//                     child: const Text("Generate POS Tags"),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import 'add_pos_tag_screen.dart';

class AddRuleScreen extends StatefulWidget {
  const AddRuleScreen({super.key});

  @override
  State<AddRuleScreen> createState() => _AddRuleScreenState();
}

class _AddRuleScreenState extends State<AddRuleScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _loading = false;

  Future<void> _fetchPosTags() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(Api.getPosTags),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"question": question}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPosTagScreen(
              question: question,
              posTags: data["PosTags"],
              rule: data["Rule"],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], 
      appBar: AppBar(
        title: const Text(
          "Add Rule",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ), 
        ),
        backgroundColor: Colors.blue[800], 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: "Enter Question",
                labelStyle: TextStyle(color: Colors.blue.shade900),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator(color: Colors.blue.shade900)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700], 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _fetchPosTags,
                    child: const Text(
                      "Generate POS Tags",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
