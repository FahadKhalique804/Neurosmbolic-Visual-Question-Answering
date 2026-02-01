// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../services/api.dart';
// import 'qna_screen.dart';
// import 'admin_home_screen.dart';
// import 'assistant_home_screen.dart';
// import 'ass_signup_screen.dart'; 

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;
//   bool _obscurePassword = true;

//   Future<void> _login() async {
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (username.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter username & password")),
//       );
//       return;
//     }

//     //  Admin hardcoded login
//     if (username == "admin" && password == "123") {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const AdminScreen()),
//         (Route<dynamic> route) => false,
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       //  Assistant login via backend 
//       final response = await http.post(
//         Uri.parse(Api.assistantLogin),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({"username": username, "password": password}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         // backend returns assistant data like:
//         // { "id": 1, "name": "Ali Khan", "age": 30, "gender": "Male", "message": "Login successful" }
//         if (data["message"] == "Login successful") {
//           final user = {
//             "id": data["id"],
//             "name": data["name"] ?? "",
//             "age": data["age"]?.toString() ?? "",
//             "gender": data["gender"] ?? "",
//           };

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => AssistantHomeScreen(user: user)),
//            (Route<dynamic> route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Login failed: ${data["message"]}")),
//           );
//         }
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
//       appBar: AppBar(
//         title: const Text("Login",
//         style: TextStyle(       
//         fontWeight: FontWeight.bold,
//         ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),

//         // Added Sign Up button here
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const Ass_Sign_Screen()),
//               );
//             },
//             child: const Text(
//               "Sign Up",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),

//       // teal background 
//       backgroundColor: const Color(0xFFA8D5C5),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // Logo / Eye icon and SEEFORME title (visual only)
//             Icon(Icons.remove_red_eye, size: 100, color: Colors.blue.shade900),
//             const SizedBox(height: 10),
//             const Text(
//               "Login",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),

//             // Username field 
//             TextField(
//               controller: _usernameController,
//               decoration: InputDecoration(
//                 labelText: "Username",
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Password field 
//             TextField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               decoration: InputDecoration(
//                 labelText: "Password",
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 suffixIcon: IconButton(
//                 icon: Icon(
//                _obscurePassword ? Icons.visibility_off : Icons.visibility,
//             ),
//                 onPressed: () {
//                 setState(() {
//                _obscurePassword = !_obscurePassword;
//              });
//       },
//     ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Black rounded Login button 
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                       padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
//                     ),
//                     child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
//                   ),

//             const SizedBox(height: 24),

//             // 🎤 Blind login (mic button)
//             IconButton(
//               icon: const Icon(Icons.mic, size: 40, color: Colors.blue),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const QAScreen()),
//                 );
//               },
//             ),
//             const Text("Blind Login"),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';

// import '../services/api.dart';
// import 'qna_screen.dart';
// import 'admin_home_screen.dart';
// import 'assistant_home_screen.dart';
// import 'ass_signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;
//   bool _obscurePassword = true;

//   // 🔊 Wake-word
//   PorcupineManager? _porcupineManager;

//   @override
//   void initState() {
//     super.initState();
//     _initWakeWord();
//   }

//   Future<void> _initWakeWord() async {
//     await Permission.microphone.request();

//     try {
//       _porcupineManager = await PorcupineManager.fromKeywordPaths(
//         "5cxfVHSg4dB/W5qq25jgA3q8yoi/Jc+Q0cLCjmGXFaEu3meeNLns8A==",
//         ["assets/wake_words/Open-App_en_android_v4_0_0.ppn"],
//         _onWakeWordDetected,
//       );

//       await _porcupineManager?.start();
//     } catch (e) {
//       debugPrint("Wake-word init error: $e");
//     }
//   }

//   void _onWakeWordDetected(int index) async {
//     debugPrint("Wake-word detected: OPEN APP");

//     await _porcupineManager?.stop();

//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const QAScreen()),
//     );
//   }

//   Future<void> _login() async {
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (username.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter username & password")),
//       );
//       return;
//     }

//     if (username == "admin" && password == "123") {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const AdminScreen()),
//         (_) => false,
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final response = await http.post(
//         Uri.parse(Api.assistantLogin),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({"username": username, "password": password}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data["message"] == "Login successful") {
//           final user = {
//             "id": data["id"],
//             "name": data["name"] ?? "",
//             "age": data["age"]?.toString() ?? "",
//             "gender": data["gender"] ?? "",
//           };

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => AssistantHomeScreen(user: user)),
//             (_) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Login failed: ${data["message"]}")),
//           );
//         }
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
//   void dispose() {
//     _porcupineManager?.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const Ass_Sign_Screen()),
//               );
//             },
//             child: const Text("Sign Up",
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFA8D5C5),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Icon(Icons.remove_red_eye, size: 100, color: Colors.blue.shade900),
//             const SizedBox(height: 10),
//             const Text("Login",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 30),

//             TextField(
//               controller: _usernameController,
//               decoration: InputDecoration(
//                 labelText: "Username",
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//             const SizedBox(height: 20),

//             TextField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               decoration: InputDecoration(
//                 labelText: "Password",
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() => _obscurePassword = !_obscurePassword);
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 80, vertical: 16),
//                     ),
//                     child: const Text("Login",
//                         style: TextStyle(color: Colors.white, fontSize: 18)),
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
import 'admin_home_screen.dart';
import 'assistant_home_screen.dart';
import 'ass_signup_screen.dart';
import 'home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter username & password")),
      );
      return;
    }

    // 🔐 Admin hardcoded login
    if (username == "admin" && password == "123") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
        (_) => false,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(Api.assistantLogin),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["message"] == "Login successful") {
          final user = {
            "id": data["id"],
            "name": data["name"] ?? "",
            "age": data["age"]?.toString() ?? "",
            "gender": data["gender"] ?? "",
          };

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => AssistantHomeScreen(user: user),
            ),
            (_) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${data["message"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Error ${response.statusCode}: ${response.body}"),
          ),
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
    return WillPopScope(
      // ✅ SYSTEM BACK HANDLER
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),

          // ✅ APP BAR BACK ARROW HANDLER
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
         
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Ass_Sign_Screen()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        backgroundColor: const Color(0xFFA8D5C5),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Icon(Icons.remove_red_eye,
                  size: 100, color: Colors.blue.shade900),
              const SizedBox(height: 10),

              const Text(
                "Login",
                style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 16),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

