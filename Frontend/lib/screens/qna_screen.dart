// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import '../services/api.dart';

// class QAScreen extends StatefulWidget {
//   const QAScreen({super.key});

//   @override
//   State<QAScreen> createState() => _QAScreenState();
// }

// class _QAScreenState extends State<QAScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   File? _selectedImage;
//   String? _answer;
//   bool _loading = false;

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _askQuestion() async {
//     if (_selectedImage == null || _questionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select an image and enter a question")),
//       );
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _answer = null;
//     });

//     try {
//       var request = http.MultipartRequest(
//         "POST",
//         Uri.parse(Api.getAnswer),
//       );

//       request.fields['question'] = _questionController.text;
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         _selectedImage!.path,
//       ));

//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         var data = json.decode(respStr);
//         setState(() {
//           _answer = data["answer"];
//         });
//       } else {
//         setState(() {
//           _answer = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _answer = "Error: $e";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3F2FD), // light blue background
//       appBar: AppBar(
//       title: const Text("Q/A Screen (Blind User)"),
//       backgroundColor: const Color(0xFF0D47A1), // dark blue appbar
//       actions: [
//       IconButton(
//       icon: const Icon(Icons.logout, color: Colors.white),
//          onPressed: () {
//          Navigator.pushNamedAndRemoveUntil(
//           context,
//           "/login", // make sure you have this route set for LoginScreen
//           (route) => false,
//         );
//       },
//     ),
//   ],
// ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Image Preview
//             if (_selectedImage != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   _selectedImage!,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Row for Pick Image & Take Photo
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _pickImage,
//                   icon: const Icon(Icons.photo_library, color: Colors.white),
//                   label: const Text("Pick Image",
//                       style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _takePhoto,
//                   icon: const Icon(Icons.camera_alt, color: Colors.white),
//                   label: const Text("Take Photo",
//                       style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Question Field
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: "Enter your question",
//                 labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Ask Button
//             ElevatedButton(
//               onPressed: _askQuestion,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFC83264),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "❓ Ask Question",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Answer Section
//             if (_loading)
//               const CircularProgressIndicator(color: Color(0xFF0D47A1)),
//             if (_answer != null && !_loading)
//               Card(
//                 color: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Text(
//                     "Answer: $_answer",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Color(0xFF0D47A1),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// import '../services/api.dart';

// class QAScreen extends StatefulWidget {
//   const QAScreen({super.key});

//   @override
//   State<QAScreen> createState() => _QAScreenState();
// }

// class _QAScreenState extends State<QAScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   File? _selectedImage;
//   String? _answer;
//   bool _loading = false;

//   final ImagePicker _picker = ImagePicker();

//   // 🎤 STT related
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isRecording = false;
//   String? _audioFilePath;

//   // 🔊 TTS
//   final FlutterTts _flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//   }

//   Future<void> _initRecorder() async {
//     await _recorder.openRecorder();
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   // 📸 Pick image from gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   // 📷 Take photo using camera
//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   // 🧠 Ask Question (Existing Function)
//   Future<void> _askQuestion() async {
//     if (_selectedImage == null || _questionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select an image and enter a question")),
//       );
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _answer = null;
//     });

//     try {
//       var request = http.MultipartRequest(
//         "POST",
//         Uri.parse(Api.getAnswer),
//       );

//       request.fields['question'] = _questionController.text;
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         _selectedImage!.path,
//       ));

//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         var data = json.decode(respStr);
//         setState(() {
//           _answer = data["answer"];
//         });
//         // 🔊 Speak out the answer automatically
//         await _flutterTts.speak(_answer ?? "");
//       } else {
//         setState(() {
//           _answer = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _answer = "Error: $e";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   // 🎤 Start or stop STT recording
//   Future<void> _toggleRecording() async {
//     if (_isRecording) {
//       await _stopRecordingAndTranscribe();
//     } else {
//       await _startRecording();
//     }
//   }

//   Future<void> _startRecording() async {
//     var status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Microphone permission denied")),
//       );
//       return;
//     }

//     Directory tempDir = await getTemporaryDirectory();
//     _audioFilePath = '${tempDir.path}/qa_audio.m4a';

//     await _recorder.startRecorder(
//       toFile: _audioFilePath,
//       codec: Codec.aacMP4,
//     );

//     setState(() {
//       _isRecording = true;
//     });
//   }

//   Future<void> _stopRecordingAndTranscribe() async {
//   await _recorder.stopRecorder();

//   setState(() {
//     _isRecording = false;
//   });

//   if (_audioFilePath != null) {
//     try {
//       var uri = Uri.parse(Api.sttTranscribe); // whisper endpoint
//       var request = http.MultipartRequest("POST", uri);
//       request.files.add(await http.MultipartFile.fromPath("audio", _audioFilePath!));

//       var response = await request.send();
//       if (response.statusCode == 200) {
//         var respStr = await response.stream.bytesToString();
//         var jsonData = json.decode(respStr); // ✅ Decode JSON

//         setState(() {
//           _questionController.text = jsonData["text"]; // ✅ Extract only "text"
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Transcription failed: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3F2FD),
//       appBar: AppBar(
//         title: const Text("Q/A Screen (Blind User)"),
//         backgroundColor: const Color(0xFF0D47A1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 "/login",
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (_selectedImage != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   _selectedImage!,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _pickImage,
//                   icon: const Icon(Icons.photo_library, color: Colors.white),
//                   label: const Text("Pick Image", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _takePhoto,
//                   icon: const Icon(Icons.camera_alt, color: Colors.white),
//                   label: const Text("Take Photo", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 📝 Question Field + 🎤 Mic Button
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: "Enter your question",
//                 labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _isRecording ? Icons.stop_circle : Icons.mic,
//                     color: _isRecording ? Colors.red : const Color(0xFF0D47A1),
//                   ),
//                   onPressed: _toggleRecording,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: _askQuestion,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFC83264),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "❓ Ask Question",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 20),

//             if (_loading)
//               const CircularProgressIndicator(color: Color(0xFF0D47A1)),
//             if (_answer != null && !_loading)
//               Card(
//                 color: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Text(
//                     "Answer: $_answer",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Color(0xFF0D47A1),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:porcupine_flutter/porcupine.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';
// import 'package:vad/vad.dart';
// import '../services/api.dart';

// class QAScreen extends StatefulWidget {
//   const QAScreen({super.key});

//   @override
//   State<QAScreen> createState() => _QAScreenState();
// }

// class _QAScreenState extends State<QAScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _blindIdController = TextEditingController();
//   File? _selectedImage;
//   String? _answer;
//   bool _loading = false;
//   final ImagePicker _picker = ImagePicker();

//   // 🎤 STT
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool isRecording = false;
//   String? _audioFilePath;

//   // 🔊 TTS
//   final FlutterTts _flutterTts = FlutterTts();

//   // --- Wake-word + VAD ---
//   PorcupineManager? _porcupineManager;
//   late VadHandler _vadHandler;
//   bool isListening = false;

//   final List<String> events = []; // For debug

//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//     _initVAD();
//     _initPorcupine();

//     // 🔊 Welcome TTS
//     // Future.delayed(const Duration(milliseconds: 500), _speakWelcome);
//   }

//   Future<void> _initRecorder() async {
//     await _recorder.openRecorder();
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     _flutterTts.stop();
//     _vadHandler.dispose();
//     _porcupineManager?.stop();
//     super.dispose();
//   }
//   //.................Welcome TTS...................
// //     Future<void> _speakWelcome() async {
// //   await _flutterTts.setSpeechRate(0.45);
// //   await _flutterTts.setPitch(1.0);
// //   await _flutterTts.setLanguage("en-US");

// //   await _flutterTts.speak(
// //     "Welcome to blind home screen. Say hey siri to ask question",
// //   );
// // }

//   // ---------------- IMAGE PICKER ----------------
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   // ---------------- Q/A ----------------
//   Future<void> _askQuestion() async {
//     if (_selectedImage == null || _questionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select an image and enter a question")),
//       );
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _answer = null;
//     });

//     try {
//       final id = int.tryParse(_blindIdController.text);

//    if (id == null) {
//      ScaffoldMessenger.of(context).showSnackBar(
//      const SnackBar(content: Text("Please enter a valid Blind ID")),
//   );
//       return;
// }

//    var request = http.MultipartRequest(
//      "POST",
//     Uri.parse(Api.getAnswerWithId(id)),
// );

//       request.fields['question'] = _questionController.text;
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         _selectedImage!.path,
//       ));

//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         var data = json.decode(respStr);
//         setState(() {
//           _answer = data["answer"];
//         });
//         await _flutterTts.speak(_answer ?? "");
//       } else {
//         setState(() {
//           _answer = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _answer = "Error: $e";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   // ---------------- STT ----------------
//   Future<void> _startRecording() async {
//     var status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Microphone permission denied")),
//       );
//       return;
//     }

//     Directory tempDir = await getTemporaryDirectory();
//     _audioFilePath = '${tempDir.path}/qa_audio.m4a';

//     await _recorder.startRecorder(
//       toFile: _audioFilePath,
//       codec: Codec.aacMP4,
//     );

//     setState(() {
//       isRecording = true;
//     });
//   }

//   Future<void> _stopRecordingAndTranscribe() async {
//     await _recorder.stopRecorder();
//     setState(() {
//       isRecording = false;
//     });

//     if (_audioFilePath != null) {
//       try {
//         var uri = Uri.parse(Api.sttTranscribe); // whisper endpoint
//         var request = http.MultipartRequest("POST", uri);
//         request.files.add(await http.MultipartFile.fromPath("audio", _audioFilePath!));

//         var response = await request.send();
//         if (response.statusCode == 200) {
//           var respStr = await response.stream.bytesToString();
//           var jsonData = json.decode(respStr);
//           setState(() {
//             _questionController.text = jsonData["text"];
//           });

//           // Automatically ask question after STT
//           await _askQuestion();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Transcription failed: ${response.statusCode}")),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     }
//   }

//   // ---------------- Wake-word + VAD ----------------
//   void _initVAD() {
//     _vadHandler = VadHandler.create(isDebug: true);

//     _vadHandler.onSpeechStart.listen((_) {
//       debugPrint("[VAD] Speech started");
//       setState(() => events.add("[VAD] Speech started"));
//     });

//     _vadHandler.onSpeechEnd.listen((_) async {
//       debugPrint("[VAD] Speech ended, stopping listening");
//       setState(() => events.add("[VAD] Speech ended, stopping listening"));
//       await _stopListening();
//       await _stopRecordingAndTranscribe();
//     });

//     _vadHandler.onError.listen((e) {
//       debugPrint("[VAD] Error: $e");
//       setState(() => events.add("[VAD] Error: $e"));
//     });
//   }

//   void _initPorcupine() async {
//     final status = await Permission.microphone.request();
//     debugPrint("[Permission] Microphone status: $status");
//     setState(() => events.add("[Permission] Microphone status: $status"));

//     try {
//       debugPrint("[Porcupine] Initializing custom model...");
//       _porcupineManager = await PorcupineManager.fromKeywordPaths(
//         //7AaVdaK+lLVqiYwKt9dn4XEKcP2MvnYT+nfEkyh4IvhmI85Gd2q3Yg==
//         "J5xSDc8Kz/7MpSK/DnZHphTWHu6zTFv7XEXjVial/0g4ird7dUGxIA==",
//         ["assets/wake_words/Hey-Siri_en_android_v3_0_0.ppn"],
//         _wakeWordCallback,
//       );

//       debugPrint("[Porcupine] Starting...");
//       await _porcupineManager?.start();
//       debugPrint("[Porcupine] Started successfully");
//       setState(() => events.add("[Porcupine] Started successfully"));
//     } catch (err) {
//       debugPrint("[Porcupine] Init error: $err");
//       setState(() => events.add("[Porcupine] Init error: $err"));
//     }
//   }

//   void _wakeWordCallback(int keywordIndex) async {
//     debugPrint("[Porcupine] Wake-word detected! index: $keywordIndex");
//     setState(() => events.add("[Porcupine] Wake-word detected! index: $keywordIndex"));

//     await _porcupineManager?.stop();

//     // Start VAD + STT automatically
//     await _startListening();
//     await _startRecording();
//   }

//   Future<void> _startListening() async {
//     if (!isListening) {
//       debugPrint("[VAD] Starting listening...");
//       await _vadHandler.startListening();
//       setState(() => isListening = true);
//     }
//   }

//   Future<void> _stopListening() async {
//     if (isListening) {
//       debugPrint("[VAD] Stopping listening...");
//       await _vadHandler.stopListening();
//       setState(() => isListening = false);
//     }
//     await _porcupineManager?.start(); // Restart Porcupine
//   }

//   // ---------------- BUILD ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3F2FD),
//       appBar: AppBar(
//         title: const Text("Q/A Screen (Blind User)",
//         style: TextStyle(
//         color: Colors.white,       
//         fontWeight: FontWeight.bold 
//         ),),
//         backgroundColor: const Color(0xFF0D47A1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 "/home",
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (_selectedImage != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   _selectedImage!,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _pickImage,
//                   icon: const Icon(Icons.photo_library, color: Colors.white),
//                   label: const Text("Pick Image", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _takePhoto,
//                   icon: const Icon(Icons.camera_alt, color: Colors.white),
//                   label: const Text("Take Photo", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             //Blind ID Field
//             TextField(
//            controller: _blindIdController,
//           keyboardType: TextInputType.number,
//          decoration: InputDecoration(
//          labelText: "Enter Blind ID",
//          labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
//         border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//           ),
//         focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//        borderRadius: BorderRadius.circular(12),
//        ),
//        ),
//          ),
//             const SizedBox(height: 20),
//             // 📝 Question Field (Mic removed, handled by wake-word)
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: "Enter your question",
//                 labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _askQuestion,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFC83264),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "❓ Ask Question",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_loading)
//               const CircularProgressIndicator(color: Color(0xFF0D47A1)),
//             if (_answer != null && !_loading)
//               Card(
//                 color: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Text(
//                     "Answer: $_answer",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Color(0xFF0D47A1),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';
// import 'package:vad/vad.dart';

// import '../services/api.dart';
// import 'debugblind_screen.dart';
// import 'temporal_screen.dart';
// import 'home_screen.dart';

// class QAScreen extends StatefulWidget {
//   const QAScreen({super.key});

//   @override
//   State<QAScreen> createState() => _QAScreenState();
// }

// class _QAScreenState extends State<QAScreen> {
//   // ---------------- State ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;

//   // ---------------- Utils ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   PorcupineManager? _porcupineManager;
//   late VadHandler _vad;

//   Timer? silenceTimer;
//   bool isListening = false;
//   String? _audioPath;

//   final int blindId = 1; // ✅ HARD-CODED BLIND ID

//   // ---------------- INIT ----------------
//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//     _initTTS();
//     _initVAD();
//     _initWakeWord();

//     Future.delayed(const Duration(milliseconds: 500), _speakWelcome);
//   }

//   Future<void> _initRecorder() async {
//     await _recorder.openRecorder();
//   }

//   Future<void> _initTTS() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setSpeechRate(0.45);
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     await _tts.speak(
//       "Welcome to blind home screen. Say hey siri to start.",
//     );
//   }

//   // ---------------- VAD ----------------
//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);

//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       silenceTimer = Timer(const Duration(seconds: 3), () async {
//         await _stopListening();
//         await _stopRecordingAndTranscribe();
//       });
//     });
//   }

//   // ---------------- WAKE WORD ----------------
//   Future<void> _initWakeWord() async {
//     await Permission.microphone.request();

//     _porcupineManager = await PorcupineManager.fromKeywordPaths(
//       "J5xSDc8Kz/7MpSK/DnZHphTWHu6zTFv7XEXjVial/0g4ird7dUGxIA==",
//       ["assets/wake_words/Hey-Siri_en_android_v3_0_0.ppn"],
//       _onWakeWordDetected,
//     );

//     await _porcupineManager?.start();
//   }

//   void _onWakeWordDetected(int index) async {
//     await _porcupineManager?.stop();
//     await _captureImage();
//     await _startListening();
//     await _startRecording();
//   }

//   // ---------------- CAMERA ----------------
//   Future<void> _captureImage() async {
//     final img = await _picker.pickImage(source: ImageSource.camera);
//     if (img != null) {
//       setState(() => _image = File(img.path));
//     }
//   }

//   // ---------------- STT ----------------
//   Future<void> _startRecording() async {
//     final dir = await getTemporaryDirectory();
//     _audioPath = "${dir.path}/qa.m4a";

//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
//   }

//   Future<void> _stopRecordingAndTranscribe() async {
//     await _recorder.stopRecorder();
//     if (_audioPath == null) return;

//     final req = http.MultipartRequest(
//       "POST",
//       Uri.parse(Api.sttTranscribe),
//     );

//     req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//     final res = await req.send();

//     if (res.statusCode == 200) {
//       final body = await res.stream.bytesToString();
//       final text = json.decode(body)["text"];
//       setState(() => _question = text);
//       await _askQuestion(text);
//     }
//   }

//   // ---------------- LISTEN CONTROL ----------------
//   Future<void> _startListening() async {
//     if (!isListening) {
//       await _vad.startListening();
//       isListening = true;
//     }
//   }

//   Future<void> _stopListening() async {
//     if (isListening) {
//       await _vad.stopListening();
//       isListening = false;
//     }
//     await _porcupineManager?.start();
//   }

//   // ---------------- QUESTION ----------------
//   Future<void> _askQuestion(String question) async {
//     if (_image == null || question.isEmpty) return;

//     setState(() {
//       _loading = true;
//       _answer = null;
//     });

//     final req = http.MultipartRequest(
//       "POST",
//       Uri.parse(Api.getAnswerWithId(blindId)),
//     );

//     req.fields["question"] = question;
//     req.files.add(await http.MultipartFile.fromPath("image", _image!.path));

//     final res = await req.send();
//     final body = await res.stream.bytesToString();

//     if (res.statusCode == 200) {
//       _answer = json.decode(body)["answer"];
//       await _tts.speak(_answer!);
//     }

//     setState(() => _loading = false);
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
//     _porcupineManager?.stop();
//     super.dispose();
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFA8D5C5),
//       appBar: AppBar(
//         title: const Text(
//           "Blind Assistant Screen",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (_) => false,
//             );
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // ---------------- Top Buttons ----------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const DebugScreen()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   child: const Text(
//                     "Help",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const TemporalScreen()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1565C0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   child: const Text(
//                     "Temporal",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // ---------------- Image ----------------
//             if (_image != null) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.file(_image!, height: 200),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // ---------------- Question ----------------
//             if (_question != null) ...[
//               Text(
//                 "Question: $_question",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 10),
//             ],

//             // ---------------- Answer ----------------
//             if (_answer != null) ...[
//               Card(
//                 color: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Text(
//                     _answer!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],

//             // ---------------- Loading ----------------
//             if (_loading)
//               const CircularProgressIndicator(color: Colors.black),

//             const SizedBox(height: 30),

//             // ---------------- Mic Button ----------------
//             IconButton(
//               icon: Icon(Icons.mic, size: 70, color: Colors.blue),
//               onPressed: () async {
//                 await _startListening();
//                 await _startRecording();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// //QnA with Continue
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:vad/vad.dart';
// import 'package:http_parser/http_parser.dart';

// import '../services/api.dart';
// import 'debugblind_screen.dart';
// import 'temporal_screen.dart';
// import 'home_screen.dart';

// class QAScreen extends StatefulWidget {
//   const QAScreen({super.key});

//   @override
//   State<QAScreen> createState() => _QAScreenState();
// }

// class _QAScreenState extends State<QAScreen> {
//   // ---------------- State ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;

//   // ---------------- Utils ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? silenceTimer;
//   Timer? _commandTimer; // Added to track and cancel command timer

//   bool isListening = false;
//   bool isAskingQuestion = false; 
//   String? _audioPath;

//   final int blindId = 1;

//   static const Duration RECORD_TIME = Duration(seconds: 3);
//   static const String API_COMMAND_URL = Api.sttCommand;

//   // ---------------- INIT ----------------
//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//     _initTTS();
//     _initVAD();

//     Future.delayed(const Duration(milliseconds: 500), _speakWelcome);
//   }

//   Future<void> _initRecorder() async {
//     await Permission.microphone.request();
//     await _recorder.openRecorder();
//   }

//   Future<void> _initTTS() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setSpeechRate(0.45);
//     await _tts.awaitSpeakCompletion(true); // Ensure await speak() waits for completion
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure we don't have lingering handlers
//     _tts.setCompletionHandler(() {});
    
//     await _tts.speak(
//       "Welcome to blind assistant. Say 'ask' to start.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- VAD ----------------
//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);

//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();

//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         if (isAskingQuestion && mounted) {
//           await _stopRecordingAndTranscribe();
//         }
//       });
//     });
//   }

//   // ---------------- COMMAND LISTEN ----------------
//   Future<void> _listenForCommand() async {
//     // Only start command listening if no other activity is running
//     if (isListening || isAskingQuestion || !mounted) return;

//     isListening = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command.wav";

//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Start fixed recording timer
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted) return;
//       if (!isListening) return;

//       String? path = await _recorder.stopRecorder();
//       isListening = false;

//       if (path != null && mounted) {
//         await _sendCommand(path);
//       }
//     });
//   }

//   // ---------------- SEND COMMAND ----------------
//   Future<void> _sendCommand(String path) async {
//     try {
//       // Ignore commands during QnA
//       if (isAskingQuestion) return;

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(API_COMMAND_URL),
//       );

//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return; // Check after await

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         // ---------------- COMMANDS ----------------
//         if (text.contains("ask")) {
//           isAskingQuestion = true;
//           isListening = false;

//           await _vad.stopListening();
//           await _tts.speak("Please ask your question");
//           await _captureImage();
//           if (mounted) await _startRecording();
//         } 
//         else if (text.contains("temporal")) {
//           await _tts.speak("Opening temporal screen");
//           if (!mounted) return;
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const TemporalScreen()),
//           );
//         } 
//         else if (text.contains("back")) {
//           await _tts.speak("Going back to home");
//           if (!mounted) return;

//            await _pauseAudioForNavigation();
          
//           // Use pop if possible, or plain push replacement to avoid stuck stacks
//           if (Navigator.canPop(context)) {
//              Navigator.pop(context);
//           } else {
//              Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//             );
//           }
//         } 
//         else if (text.contains("continue")) {
//           // Only trigger continue if not already in QnA
//           if (!isAskingQuestion) {
//             isAskingQuestion = true;
//             isListening = false;

//             await _tts.speak("Starting recording for next question");
//             if (mounted) await _startRecording();
//           }
//         } 
//         else if (text.contains("stop")) {
//         // Stop recording and VAD
//         if (isListening || isAskingQuestion) {
//         await _recorder.stopRecorder();
//         await _vad.stopListening();
//         isListening = false;
//         isAskingQuestion = false;
//        }
//          await _tts.speak("Microphone stopped");
//        }
//         else {
//           await _tts.speak("Sorry, I did not understand. Please say again.");
//           if (mounted) await _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//     }
//   }
  
//   // ---------------- QA RECORDING ----------------
//   Future<void> _startRecording() async {
//     isListening = false;
//     await _vad.stopListening();

//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/qa.m4a";

//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );

//     await _vad.startListening();
//   }

//   //..............Transcribe........................
//   Future<void> _stopRecordingAndTranscribe() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();

//     if (_audioPath == null) return;

//     final req = http.MultipartRequest(
//       "POST",
//       Uri.parse(Api.sttTranscribe),
//     );

//     req.files.add(
//       await http.MultipartFile.fromPath("audio", _audioPath!),
//     );

//     final res = await req.send();

//     if (!mounted) return;

//     if (res.statusCode == 200) {
//       final body = await res.stream.bytesToString();
//       final text = json.decode(body)["text"];
//       setState(() => _question = text);
//       await _askQuestion(text);
//     }
//   }

//   // ---------------- ASK QUESTION ----------------
//   Future<void> _askQuestion(String question) async {
//     if (_image == null || question.isEmpty) return;

//     setState(() {
//       _loading = true;
//       _answer = null;
//     });

//     final req = http.MultipartRequest(
//       "POST",
//       Uri.parse(Api.getAnswerWithId(blindId)),
//     );

//     req.fields["question"] = question;
//     req.files.add(
//       await http.MultipartFile.fromPath("image", _image!.path),
//     );

//     final res = await req.send();
//     final body = await res.stream.bytesToString();

//     if (!mounted) return;

//     if (res.statusCode == 200) {
//       _answer = json.decode(body)["answer"];

//       await _tts.speak(_answer!);
      
//       // Wait for speak to complete 
//       await _tts.speak("Session ended. Listening for commands.");
//       isAskingQuestion = false;
//       if (mounted) await _listenForCommand();
//     }

//     if (mounted) setState(() => _loading = false);
//   }

//   // ---------------- CAMERA ----------------
//   Future<void> _captureImage() async {
//     final img = await _picker.pickImage(source: ImageSource.camera);
//     if (img != null && mounted) {
//       setState(() => _image = File(img.path));
//     }
//   }
//   //................Pause Audio...............
//   Future<void> _pauseAudioForNavigation() async {
//   try {
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();

//     if (_recorder.isRecording) {
//       await _recorder.stopRecorder();
//     }

//     await _vad.stopListening();
//     await _tts.stop();
//   } catch (_) {}
// }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     _commandTimer?.cancel(); // Cancel command timer
//     silenceTimer?.cancel();
//     //_recorder.closeRecorder();

//     // STOP — do not dispose
//    _vad.stopListening();
//     _tts.stop();
//     //_vad.dispose();
//     super.dispose();
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFA8D5C5),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
//           onPressed: () async {
//             await _pauseAudioForNavigation();

//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Blind Screen", 
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // --- Header Buttons & Logo ---
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildTopButton("Help", Colors.redAccent, () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const DebugScreen()),
//                     );
//                   }),
                  
//                   // Eye Logo
//                   const Icon(
//                      Icons.remove_red_eye, 
//                      size: 60, 
//                      color: Color(0xFF0D47A1), // Navy Blue
//                   ),

//                   _buildTopButton("Temporal", Colors.blueAccent, () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const TemporalScreen()),
//                     );
//                   }),
//                 ],
//               ),
              
//               const SizedBox(height: 10),
//               const Text(
//                 "Blind Assistant",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w900,
//                   color: Color(0xFF002147), // Dark Navy
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // --- Main Content Area (Image or Placeholder) ---
//               Container(
//                 height: 300,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: _image != null
//                     ? Image.file(_image!, fit: BoxFit.cover)
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                            Icon(
//                             Icons.mic_none_outlined, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Listening...",
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//               ),

//               const SizedBox(height: 20),

//               // --- Question Card ---
//               if (_question != null)
//                 _buildInfoCard(
//                   title: "YOU ASKED",
//                   content: _question!,
//                   icon: Icons.face,
//                   accentColor: Colors.blueAccent,
//                 ),

//               const SizedBox(height: 15),

//               // --- Answer Card ---
//               if (_answer != null)
//                 _buildInfoCard(
//                   title: "ASSISTANT ANSWER",
//                   content: _answer!,
//                   icon: Icons.smart_toy,
//                   accentColor: Colors.green,
//                 )
//               else if (_loading)
//                  const Padding(
//                    padding: EdgeInsets.all(20.0),
//                    child: CircularProgressIndicator(),
//                  ),

//               const SizedBox(height: 30),

//               // --- Mic Button ---
//               GestureDetector(
//                 onTap: _listenForCommand,
//                 child: Container(
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                       )
//                     ],
//                   ),
//                   child: const Icon(Icons.mic, size: 40, color: Colors.blueAccent),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopButton(String text, Color color, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: color, 
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color, 
//           fontWeight: FontWeight.bold,
//           fontSize: 16
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required String content,
//     required IconData icon,
//     required Color accentColor,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//              color: Colors.black.withOpacity(0.05),
//              blurRadius: 5,
//              offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: accentColor),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                   letterSpacing: 1.0,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             content,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   }


//QnA with Continue
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vad/vad.dart';
import 'package:http_parser/http_parser.dart';

import '../services/api.dart';
import 'debugblind_screen.dart';
import 'temporal_screen.dart';
import 'home_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  // ---------------- State ----------------
  File? _image;
  String? _question;
  String? _answer;
  bool _loading = false;

  // ---------------- Utils ----------------
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  late VadHandler _vad;
  Timer? silenceTimer;
  Timer? _commandTimer; // Added to track and cancel command timer

  bool isListening = false;
  bool isAskingQuestion = false; 
  String? _audioPath;

  final int blindId = 1;

  static const Duration RECORD_TIME = Duration(seconds: 3);
  static const String API_COMMAND_URL = Api.sttCommand;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initTTS();
    _initVAD();

    Future.delayed(const Duration(milliseconds: 500), _speakWelcome);
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true); // Ensure await speak() waits for completion
  }

  // ---------------- WELCOME ----------------
  Future<void> _speakWelcome() async {
    // Ensure we don't have lingering handlers
    _tts.setCompletionHandler(() {});
    
    await _tts.speak(
      "Welcome to blind assistant. Say 'ask' to start.",
    );
    
    if (mounted) _listenForCommand();
  }

  // ---------------- VAD ----------------
  void _initVAD() {
    _vad = VadHandler.create(isDebug: false);

    _vad.onSpeechStart.listen((_) {
      silenceTimer?.cancel();
    });

    _vad.onSpeechEnd.listen((_) {
      silenceTimer?.cancel();

      silenceTimer = Timer(const Duration(seconds: 1), () async {
        if (isAskingQuestion && mounted) {
          await _stopRecordingAndTranscribe();
        }
      });
    });
  }

  // ---------------- COMMAND LISTEN ----------------
  Future<void> _listenForCommand() async {
    // Only start command listening if no other activity is running
    if (isListening || isAskingQuestion || !mounted) return;

    isListening = true;

    Directory tempDir = await getTemporaryDirectory();
    String filePath = "${tempDir.path}/command.wav";

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    // Start fixed recording timer
    _commandTimer?.cancel();
    _commandTimer = Timer(RECORD_TIME, () async {
      if (!mounted) return;
      if (!isListening) return;

      String? path = await _recorder.stopRecorder();
      isListening = false;

      if (path != null && mounted) {
        await _sendCommand(path);
      }
    });
  }

  // ---------------- SEND COMMAND ----------------
  Future<void> _sendCommand(String path) async {
    try {
      // Ignore commands during QnA
      if (isAskingQuestion) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API_COMMAND_URL),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var response = await http.Response.fromStream(await request.send());

      if (!mounted) return; // Check after await

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String text = (data['text'] ?? '').toLowerCase().trim();

        // ---------------- COMMANDS ----------------
        if (text.contains("ask")) {
          isAskingQuestion = true;
          isListening = false;

          await _vad.stopListening();
          await _tts.speak("Please ask your question");
          await _captureImage();
          if (mounted) await _startRecording();
        } 
        else if (text.contains("temporal")) {
          await _tts.speak("Opening temporal screen");
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TemporalScreen()),
          );
        } 
        else if (text.contains("back")) {
          await _tts.speak("Going back to home");
          if (!mounted) return;

           await _pauseAudioForNavigation();
          
          // Use pop if possible, or plain push replacement to avoid stuck stacks
          if (Navigator.canPop(context)) {
             Navigator.pop(context);
          } else {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } 
        else if (text.contains("continue")) {
          // Only trigger continue if not already in QnA
          if (!isAskingQuestion) {
            isAskingQuestion = true;
            isListening = false;

            await _tts.speak("Starting recording for next question");
            if (mounted) await _startRecording();
          }
        } 
        else if (text.contains("stop")) {
        // Stop recording and VAD
        if (isListening || isAskingQuestion) {
        await _recorder.stopRecorder();
        await _vad.stopListening();
        isListening = false;
        isAskingQuestion = false;
       }
         await _tts.speak("Microphone stopped");
       }
        else {
          await _tts.speak("Sorry, I did not understand. Please say again.");
          if (mounted) await _listenForCommand();
        }
      }
    } catch (e) {
      debugPrint("Command error: $e");
    }
  }
  
  // ---------------- QA RECORDING ----------------
  Future<void> _startRecording() async {
    isListening = false;
    await _vad.stopListening();

    Directory tempDir = await getTemporaryDirectory();
    _audioPath = "${tempDir.path}/qa.m4a";

    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: Codec.aacMP4,
    );

    await _vad.startListening();
  }

  //..............Transcribe........................
  Future<void> _stopRecordingAndTranscribe() async {
    await _recorder.stopRecorder();
    await _vad.stopListening();

    if (_audioPath == null) return;

    final req = http.MultipartRequest(
      "POST",
      Uri.parse(Api.sttTranscribe),
    );

    req.files.add(
      await http.MultipartFile.fromPath("audio", _audioPath!),
    );

    final res = await req.send();

    if (!mounted) return;

    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final text = json.decode(body)["text"];
      setState(() => _question = text);
      await _askQuestion(text);
    }
  }

  // ---------------- ASK QUESTION ----------------
  Future<void> _askQuestion(String question) async {
    if (_image == null || question.isEmpty) return;

    setState(() {
      _loading = true;
      _answer = null;
    });

    final req = http.MultipartRequest(
      "POST",
      Uri.parse(Api.getAnswerWithId(blindId)),
    );

    req.fields["question"] = question;
    req.files.add(
      await http.MultipartFile.fromPath("image", _image!.path),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (!mounted) return;

    if (res.statusCode == 200) {
      _answer = json.decode(body)["answer"];

      await _tts.speak(_answer!);
      
      // Wait for speak to complete 
      await _tts.speak("Session ended. Listening for commands.");
      isAskingQuestion = false;
      if (mounted) await _listenForCommand();
    }

    if (mounted) setState(() => _loading = false);
  }

  // ---------------- CAMERA ----------------
  Future<void> _captureImage() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null && mounted) {
      setState(() => _image = File(img.path));
    }
  }
  //................Pause Audio...............
  Future<void> _pauseAudioForNavigation() async {
  try {
    _commandTimer?.cancel();
    silenceTimer?.cancel();

    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }

    await _vad.stopListening();
    await _tts.stop();
  } catch (_) {}
}

  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
    _commandTimer?.cancel(); // Cancel command timer
    silenceTimer?.cancel();
    //_recorder.closeRecorder();

    // STOP — do not dispose
   _vad.stopListening();
    _tts.stop();
    //_vad.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8D5C5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () async {
            await _pauseAudioForNavigation();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
            );
          },
        ),
        title: const Text(
          "Blind Screen", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Header Buttons & Logo ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton("Help", Colors.redAccent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DebugScreen()),
                    );
                  }),
                  
                  // Eye Logo
                  const Icon(
                     Icons.remove_red_eye, 
                     size: 60, 
                     color: Color(0xFF0D47A1), // Navy Blue
                  ),

                  _buildTopButton("Temporal", Colors.blueAccent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TemporalScreen()),
                    );
                  }),
                ],
              ),
              
              const SizedBox(height: 10),
              const Text(
                "Blind Assistant",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF002147), // Dark Navy
                ),
              ),
              const SizedBox(height: 20),

              // --- Main Content Area (Image or Placeholder) ---
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(
                            Icons.mic_none_outlined, 
                            size: 80, 
                            color: Colors.blueAccent.withOpacity(0.5)
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Listening...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // --- Question Card ---
              if (_question != null)
                _buildInfoCard(
                  title: "YOU ASKED",
                  content: _question!,
                  icon: Icons.face,
                  accentColor: Colors.blueAccent,
                ),

              const SizedBox(height: 15),

              // --- Answer Card ---
              if (_answer != null)
                _buildInfoCard(
                  title: "ASSISTANT ANSWER",
                  content: _answer!,
                  icon: Icons.smart_toy,
                  accentColor: Colors.green,
                )
              else if (_loading)
                 const Padding(
                   padding: EdgeInsets.all(20.0),
                   child: CircularProgressIndicator(),
                 ),

              const SizedBox(height: 30),

              // --- Mic Button ---
              GestureDetector(
                onTap: _listenForCommand,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.mic, size: 40, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color, 
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 5,
             offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  }
