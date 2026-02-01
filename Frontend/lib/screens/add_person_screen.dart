import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../services/api.dart';

class AddPersonScreen extends StatefulWidget {
  final int blindId;

  const AddPersonScreen({Key? key, required this.blindId}) : super(key: key);

  @override
  _AddPersonScreenState createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String gender = "Male";
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  // Pick multiple images from gallery
  Future<void> pickFromGallery() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  // Take a single photo from camera
  Future<void> takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  // Handle saving the contact with images
  Future<void> handleSave() async {
    if (nameController.text.isEmpty ||
        relationController.text.isEmpty ||
        ageController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse(Api.createContactWithPics), 
    );

    // Add form fields
    request.fields['blind_id'] = widget.blindId.toString();
    request.fields['name'] = nameController.text.trim();
    request.fields['relation'] = relationController.text.trim();
    request.fields['age'] = ageController.text.trim();
    request.fields['gender'] = gender;

    // Attach images
    for (var img in images) {
      final mimeType = lookupMimeType(img.path) ?? "image/jpeg";
      request.files.add(await http.MultipartFile.fromPath(
        "images", // Must match the backend field name
        img.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact created with images!")),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create contact")),
        );
      }
    } catch (e) {
      print("Error creating contact: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
         iconTheme: const IconThemeData(
         color: Colors.white, // back arrow color
        ),
        title: const Text("Add Person",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: "Name", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: relationController,
              decoration: const InputDecoration(
                  labelText: "Relation", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Age", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),

            // Gender selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Male", "Female", "Other"].map((g) {
                return ChoiceChip(
                  label: Text(g),
                  selected: gender == g,
                  selectedColor: Colors.blue,
                  labelStyle:
                      TextStyle(color: gender == g ? Colors.white : Colors.black),
                  onSelected: (_) {
                    setState(() {
                      gender = g;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Image picker buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: pickFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text("Pick Images",
                  style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],),
                ),
                ElevatedButton.icon(
                  onPressed: takePhoto,
                   icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Take Photo",
                  style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: images
                  .map((img) => Image.file(img, width: 80, height: 80))
                  .toList(),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC83264),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50)),
              child: const Text("💾 Save",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,)),
            )
          ],
        ),
      ),
    );
  }
}
