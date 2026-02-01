import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import 'bli_signup_screen.dart';

class Ass_Sign_Screen extends StatefulWidget {
  const Ass_Sign_Screen({super.key});

  @override
  State<Ass_Sign_Screen> createState() => _Ass_Sign_ScreenState();
}

class _Ass_Sign_ScreenState extends State<Ass_Sign_Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _gender = "Male";
  bool _loading = false;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

 Future<void> _signupAssistant() async {
  final name = _nameController.text.trim();
  final age = _ageController.text.trim();
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if (name.isEmpty || age.isEmpty || username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("All fields are required")));
    return;
  }

  if (_image == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Please select an image")));
    return;
  }

  setState(() => _loading = true);

  try {
    // ✅ Multipart form-data setup
    var request = http.MultipartRequest('POST', Uri.parse(Api.assistantSignup));

    request.fields['name'] = name;
    request.fields['age'] = age;
    request.fields['gender'] = _gender;
    request.fields['username'] = username;
    request.fields['password'] = password;

    // Attach image file
    request.files.add(await http.MultipartFile.fromPath('pic', _image!.path));

    // Send request
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assistant Registered ✅")));

      final data = jsonDecode(responseBody);
      final assistantId = data["id"] ?? 1;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Bli_Sign_Screen(assistantId: assistantId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $responseBody")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistant Signup"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _image != null ? FileImage(File(_image!.path)) : null,
                    child: _image == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Camera"),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        label: const Text("Gallery"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: _inputDecoration("Name")),
            const SizedBox(height: 15),
            TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: _inputDecoration("Age")),
            const SizedBox(height: 15),
            const Text("Gender"),
            Row(
              children: [
                Radio(value: "Male", groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text("Male"),
                Radio(value: "Female", groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text("Female"),
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: _usernameController, decoration: _inputDecoration("Username")),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration("Password")),
            const SizedBox(height: 30),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _signupAssistant,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}
