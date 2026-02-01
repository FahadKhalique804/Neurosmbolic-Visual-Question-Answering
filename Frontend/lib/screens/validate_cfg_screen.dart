// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../services/api.dart';

// class ValidateCFGScreen extends StatefulWidget {
//   const ValidateCFGScreen({super.key});

//   @override
//   State<ValidateCFGScreen> createState() => _ValidateCFGScreenState();
// }

// class _ValidateCFGScreenState extends State<ValidateCFGScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   String? _result;
//   bool _loading = false;

//   Future<void> _validateQuestion() async {
//     final question = _questionController.text.trim();

//     if (question.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a question")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final url = Uri.parse(Api.validateCFG);

//       print("📤 Sending request to $url");
//       print("📤 Body: ${jsonEncode({"question": question})}");

//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",  // must be exact
//         },
//         body: jsonEncode({"question": question}),
//       );

//       print("📥 Response: ${response.statusCode} ${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() => _result = data["message"]);
//       } else {
//         setState(() => _result =
//             "Error ${response.statusCode}: ${response.body}");
//       }
//     } catch (e) {
//       setState(() => _result = "❌ Error: $e");
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Validate CFG")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
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
//                     onPressed: _validateQuestion,
//                     child: const Text("Validate"),
//                   ),
//             const SizedBox(height: 20),
//             if (_result != null)
//               Text(
//                 "Result: $_result",
//                 style: const TextStyle(fontSize: 16),
//               ),
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

class ValidateCFGScreen extends StatefulWidget {
  const ValidateCFGScreen({super.key});

  @override
  State<ValidateCFGScreen> createState() => _ValidateCFGScreenState();
}

class _ValidateCFGScreenState extends State<ValidateCFGScreen> {
  final TextEditingController _questionController = TextEditingController();
  String? _result;
  bool _loading = false;

  Future<void> _validateQuestion() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a question")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final url = Uri.parse(Api.validateCFG);

      print("📤 Sending request to $url");
      print("📤 Body: ${jsonEncode({"question": question})}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // must be exact
        },
        body: jsonEncode({"question": question}),
      );

      print("📥 Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _result = data["message"]);
      } else {
        setState(() =>
            _result = "Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      setState(() => _result = "❌ Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // light blue background
      appBar: AppBar(
         iconTheme: const IconThemeData(
         color: Colors.white, // back arrow color
        ),
        title: const Text("Validate CFG",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: "Enter Question",
                labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFF0D47A1), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator(color: Color(0xFF0D47A1))
                : ElevatedButton(
                    onPressed: _validateQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC83264),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Validate",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
            const SizedBox(height: 20),
            if (_result != null)
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "Result: $_result",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
