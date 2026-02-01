// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../services/api.dart';

// class AddPosTagScreen extends StatelessWidget {
//   final String question;
//   final List<dynamic> posTags; // List of maps {word, pos}
//   final String rule;

//   const AddPosTagScreen({
//     super.key,
//     required this.question,
//     required this.posTags,
//     required this.rule,
//   });

//   Future<void> _saveRule(BuildContext context) async {
//     try {
//       final response = await http.post(
//         Uri.parse(Api.addRule),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           "question": question,
//           "rule": rule,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data["message"] ?? "Rule added successfully")),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("POS Tags")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Rule: $rule",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
//             const SizedBox(height: 10),
//             Text("Question: $question",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: posTags.length,
//                 itemBuilder: (context, index) {
//                   final item = posTags[index];
//                   return ListTile(
//                     title: Text(item["word"] ?? ""),
//                     trailing: Text(item["pos"] ?? "",
//                         style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _saveRule(context),
//               child: const Text("Save Rule"),
//             ),
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

class AddPosTagScreen extends StatelessWidget {
  final String question;
  final List<dynamic> posTags; // List of maps {word, pos}
  final String rule;

  const AddPosTagScreen({
    super.key,
    required this.question,
    required this.posTags,
    required this.rule,
  });

  Future<void> _saveRule(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(Api.addRule),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "question": question,
          "rule": rule,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Rule added successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // light blue background
      appBar: AppBar(
        title: const Text("POS Tags"),
        backgroundColor: const Color(0xFF0D47A1), // dark blue appbar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Rule: $rule",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Question: $question",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: posTags.length,
                itemBuilder: (context, index) {
                  final item = posTags[index];
                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(item["word"] ?? ""),
                      trailing: Text(
                        item["pos"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveRule(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC83264),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Rule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
