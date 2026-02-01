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
// import 'home_screen.dart';
// import 'qna_screen.dart';

// class TemporalScreen extends StatefulWidget {
//   const TemporalScreen({super.key});

//   @override
//   State<TemporalScreen> createState() => _TemporalScreenState();
// }

// class _TemporalScreenState extends State<TemporalScreen> {
//   // ---------------- STATE ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;
  
//   // Controls the continuous loop
//   bool isLooping = false;
//   // Controls the initial command listening
//   bool isListeningForCommand = false;

//   // ---------------- UTILS ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? _commandTimer;
//   Timer? silenceTimer;
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
//     await _tts.awaitSpeakCompletion(true);
//   }

//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);
    
//     // VAD logic for the Question recording
//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       // Wait 1s of silence before stopping recording
//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         // Only stop if we are currently recording a question
//          if (_recorder.isRecording && !isListeningForCommand && mounted) {
//            await _stopRecordingQuestion();
//          }
//       });
//     });
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure no lingering handlers
//     _tts.setCompletionHandler(() {});

//     await _tts.speak(
//       "Temporal mode. Say 'ask' to start the continuous loop.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- COMMAND LISTENER ----------------
//   Future<void> _listenForCommand() async {
//     if (isLooping || isListeningForCommand || !mounted) return;

//     isListeningForCommand = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command_temporal.wav";

//     // Start recording for command
//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Fixed timer for command listening
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted || !isListeningForCommand) return;

//       String? path = await _recorder.stopRecorder();
//       isListeningForCommand = false;

//       if (path != null && mounted) {
//         await _processCommand(path);
//       }
//     });
//   }

//   Future<void> _processCommand(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         if (text.contains("ask")) {
//           // START THE LOOP
//           isLooping = true;
//           await _tts.speak("Starting continuous loop.");
//           if (mounted) _runContinuousLoop();
//         } 
//        else if (text.contains("stop")) {
//           // Stop recording and VAD
//           isLooping = false;
//           await _recorder.stopRecorder();
//           await _vad.stopListening();
//           await _tts.speak("Microphone stopped");
//         }
//         else {
//           // WRONG COMMAND FEEDBACK
//           await _tts.speak("Wrong command, say correct command.");
//           if (mounted) _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//       if (mounted) _listenForCommand();
//     }
//   }

//   // ---------------- CONTINUOUS LOOP ----------------
//   Future<void> _runContinuousLoop() async {
//     int iteration = 0;
    
//     while (isLooping && iteration < 3 && mounted) {
//       if (!mounted) break;
//       iteration++;

//       // 1. Capture Image
//       await _captureImage();
//       if (!mounted) break;

//       // 2. Speak Prompt
//       await _tts.speak("Ask question.");
//       if (!mounted) break;

//       // 3. Record Question (VAD controlled)
//       // Reset state for new question
//       setState(() {
//          _question = null;
//          _answer = null; 
//       });
      
//       String? questionText = await _recordQuestion();
//       if (!mounted) break;
//       if (questionText == null || questionText.isEmpty) {
//         // If recording failed or no speech, maybe retry or just continue loop?
//         continue;
//       }
      
//       setState(() => _question = questionText);

//       // 4. Get Answer
//       String? answerText = await _fetchAnswer(questionText);
//       if (!mounted) break;
      
//       if (answerText != null) {
//         setState(() => _answer = answerText);
//         // 5. Speak Answer
//         await _tts.speak(answerText);
//       } else {
//         await _tts.speak("Could not get answer.");
//       }

//       // 6. Pause briefly before next iteration
//       await Future.delayed(const Duration(seconds: 1));
//     }

//     // Loop finished (3 times or cancelled)
//     isLooping = false;
//     if (mounted) {
//       await _tts.speak("Temporal session finished. Say ask to start again.");
//       _listenForCommand();
//     }
//   }

//   // ---------------- STEPS ----------------
//   Future<void> _captureImage() async {
//     try {
//       final img = await _picker.pickImage(source: ImageSource.camera);
//       if (img != null && mounted) {
//         setState(() => _image = File(img.path));
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }

//   // Returns question text or null
//   Completer<String?>? _recordingCompleter;
  
//   Future<String?> _recordQuestion() async {
//     if (!mounted) return null;
    
//     // Stop VAD listening just in case
//     await _vad.stopListening();
    
//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/temporal_qa.m4a";

//     _recordingCompleter = Completer<String?>();

//     // Start Recorder
//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
    
//     // Start VAD
//     await _vad.startListening();

//     // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
//     // which completes the completer.
    
//     return _recordingCompleter!.future;
//   }

//   Future<void> _stopRecordingQuestion() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();
    
//     if (_audioPath == null) {
//       _recordingCompleter?.complete(null);
//       return;
//     }

//     // Transcribe
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
//       req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//       final res = await req.send();
      
//       if (res.statusCode == 200) {
//         final body = await res.stream.bytesToString();
//         final text = json.decode(body)["text"];
//         _recordingCompleter?.complete(text);
//       } else {
//         _recordingCompleter?.complete(null);
//       }
//     } catch (e) {
//       _recordingCompleter?.complete(null);
//     }
//   }

//   Future<String?> _fetchAnswer(String question) async {
//     if (_image == null) return null;
    
//     setState(() => _loading = true);
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
//       req.fields["question"] = question;
//       req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
//       final res = await req.send();
//       final body = await res.stream.bytesToString();
      
//       setState(() => _loading = false);
//       if (res.statusCode == 200) {
//         return json.decode(body)["answer"];
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//     return null;
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     isLooping = false; // Stop loop
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
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
//           onPressed: () {
//             isLooping = false;
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const QAScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Temporal Mode", 
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

//                   _buildTopButton("Home", Colors.blueAccent, () {
//                     isLooping = false;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
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
//                             Icons.camera_alt, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Waiting for loop...",
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
            
//             if (isLooping)
//                Padding(
//                  padding: const EdgeInsets.only(top: 20),
//                  child: Text(
//                    "Loop Active...",
//                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                  ),
//                ),
               
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
// }



//Continuous loop

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
// import 'home_screen.dart';
// import 'qna_screen.dart';

// class TemporalScreen extends StatefulWidget {
//   const TemporalScreen({super.key});

//   @override
//   State<TemporalScreen> createState() => _TemporalScreenState();
// }

// class _TemporalScreenState extends State<TemporalScreen> {
//   // ---------------- STATE ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;
  
//   // Controls the continuous loop
//   bool isLooping = false;
//   // Controls the initial command listening
//   bool isListeningForCommand = false;
//     //For Fixed Question
//     bool hasFixedQuestion = false;

//   // ---------------- UTILS ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? _commandTimer;
//   Timer? silenceTimer;
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
//     await _tts.awaitSpeakCompletion(true);
//   }

//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);
    
//     // VAD logic for the Question recording
//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       // Wait 1s of silence before stopping recording
//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         // Only stop if we are currently recording a question
//          if (_recorder.isRecording && !isListeningForCommand && mounted) {
//            await _stopRecordingQuestion();
//          }
//       });
//     });
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure no lingering handlers
//     _tts.setCompletionHandler(() {});

//     await _tts.speak(
//       "Temporal mode. Say 'ask' to start the continuous loop.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- COMMAND LISTENER ----------------
//   Future<void> _listenForCommand() async {
//     if (isLooping || isListeningForCommand || !mounted) return;

//     isListeningForCommand = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command_temporal.wav";

//     // Start recording for command
//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Fixed timer for command listening
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted || !isListeningForCommand) return;

//       String? path = await _recorder.stopRecorder();
//       isListeningForCommand = false;

//       if (path != null && mounted) {
//         await _processCommand(path);
//       }
//     });
//   }

//   Future<void> _processCommand(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         if (text.contains("ask")) {
//           // START THE LOOP
//           isLooping = true;
//           await _tts.speak("Starting continuous loop.");
//           if (mounted) _runContinuousLoop();
//         } else if (text.contains("stop")) {
//           // Stop recording and VAD
//           isLooping = false;
//           await _recorder.stopRecorder();
//           await _vad.stopListening();
//           await _tts.speak("Microphone stopped");
          
//           // Listen for 'ask' again
//           if (mounted) _listenForCommand();
//         } else {
//           // WRONG COMMAND FEEDBACK
//           await _tts.speak("Wrong command, say correct command.");
//           if (mounted) _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//       if (mounted) _listenForCommand();
//     }
//   }

//   // ---------------- CONTINUOUS LOOP ----------------
//   Future<void> _runContinuousLoop() async {
//   int iteration = 0;

//   while (isLooping && iteration < 3 && mounted) {
//     iteration++;

//     // 1. Capture Image (EVERY iteration)
//     await _captureImage();
//     if (!mounted) break;

//     // 2. Ask question ONLY ONCE
//     if (!hasFixedQuestion) {
//       await _tts.speak("Ask question.");
//       if (!mounted) break;

//       String? questionText = await _recordQuestion();
//       if (!mounted || questionText == null || questionText.isEmpty) {
//         continue;
//       }

//       setState(() {
//         _question = questionText;
//         hasFixedQuestion = true;
//       });
//     }

//     // 3. Fetch answer using SAME question
//     String? answerText = await _fetchAnswer(_question!);
//     if (!mounted) break;

//     if (answerText != null) {
//       setState(() => _answer = answerText);
//       await _tts.speak(answerText);
//     } else {
//       await _tts.speak("Could not get answer.");
//     }

//     await Future.delayed(const Duration(seconds: 1));
//   }

//   // Loop finished
//   isLooping = false;
//   hasFixedQuestion = false;

//   if (mounted) {
//     await _tts.speak("Temporal session finished. Say ask to start again.");
//     _listenForCommand();
//   }
// }


//   // ---------------- STEPS ----------------
//   Future<void> _captureImage() async {
//     try {
//       final img = await _picker.pickImage(source: ImageSource.camera);
//       if (img != null && mounted) {
//         setState(() => _image = File(img.path));
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }

//   // Returns question text or null
//   Completer<String?>? _recordingCompleter;
  
//   Future<String?> _recordQuestion() async {
//     if (!mounted) return null;
    
//     // Stop VAD listening just in case
//     await _vad.stopListening();
    
//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/temporal_qa.m4a";

//     _recordingCompleter = Completer<String?>();

//     // Start Recorder
//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
    
//     // Start VAD
//     await _vad.startListening();

//     // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
//     // which completes the completer.
    
//     return _recordingCompleter!.future;
//   }

//   Future<void> _stopRecordingQuestion() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();
    
//     if (_audioPath == null) {
//       _recordingCompleter?.complete(null);
//       return;
//     }

//     // Transcribe
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
//       req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//       final res = await req.send();
      
//       if (res.statusCode == 200) {
//         final body = await res.stream.bytesToString();
//         final text = json.decode(body)["text"];
//         _recordingCompleter?.complete(text);
//       } else {
//         _recordingCompleter?.complete(null);
//       }
//     } catch (e) {
//       _recordingCompleter?.complete(null);
//     }
//   }

//   Future<String?> _fetchAnswer(String question) async {
//     if (_image == null) return null;
    
//     setState(() => _loading = true);
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
//       req.fields["question"] = question;
//       req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
//       final res = await req.send();
//       final body = await res.stream.bytesToString();
      
//       setState(() => _loading = false);
//       if (res.statusCode == 200) {
//         return json.decode(body)["answer"];
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//     return null;
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     isLooping = false; // Stop loop
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
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
//           onPressed: () {
//             isLooping = false;
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Temporal Mode", 
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

//                   _buildTopButton("QnA", Colors.blueAccent, () {
//                     isLooping = false;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const QAScreen()),
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
//                             Icons.camera_alt, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Waiting for loop...",
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
            
//             if (isLooping)
//                Padding(
//                  padding: const EdgeInsets.only(top: 20),
//                  child: Text(
//                    "Loop Active...",
//                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                  ),
//                ),
               
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
// }




// //3 Times with img change
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
// import 'home_screen.dart';
// import 'qna_screen.dart';

// class TemporalScreen extends StatefulWidget {
//   const TemporalScreen({super.key});

//   @override
//   State<TemporalScreen> createState() => _TemporalScreenState();
// }

// class _TemporalScreenState extends State<TemporalScreen> {
//   // ---------------- STATE ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;
  
//   // Controls the continuous loop
//   bool isLooping = false;
//   // Controls the initial command listening
//   bool isListeningForCommand = false;

//   bool hasFixedQuestion = false;

//   // ---------------- UTILS ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? _commandTimer;
//   Timer? silenceTimer;
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
//     await _tts.awaitSpeakCompletion(true);
//   }

//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);
    
//     // VAD logic for the Question recording
//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       // Wait 1s of silence before stopping recording
//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         // Only stop if we are currently recording a question
//          if (_recorder.isRecording && !isListeningForCommand && mounted) {
//            await _stopRecordingQuestion();
//          }
//       });
//     });
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure no lingering handlers
//     _tts.setCompletionHandler(() {});

//     await _tts.speak(
//       "Temporal mode. Say 'ask' to start the continuous loop.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- COMMAND LISTENER ----------------
//   Future<void> _listenForCommand() async {
//     if (isLooping || isListeningForCommand || !mounted) return;

//     isListeningForCommand = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command_temporal.wav";

//     // Start recording for command
//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Fixed timer for command listening
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted || !isListeningForCommand) return;

//       String? path = await _recorder.stopRecorder();
//       isListeningForCommand = false;

//       if (path != null && mounted) {
//         await _processCommand(path);
//       }
//     });
//   }

//   Future<void> _processCommand(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         if (text.contains("ask")) {
//           // START THE LOOP
//           isLooping = true;
//           await _tts.speak("Starting continuous loop.");
//           if (mounted) _runContinuousLoop();
//         } 
//        else if (text.contains("stop")) {
//           // Stop recording and VAD
//           isLooping = false;
//           hasFixedQuestion = false;
//           await _recorder.stopRecorder();
//           await _vad.stopListening();
//           await _tts.speak("Microphone stopped");
//         }
//         else {
//           // WRONG COMMAND FEEDBACK
//           await _tts.speak("Wrong command, say correct command.");
//           if (mounted) _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//       if (mounted) _listenForCommand();
//     }
//   }

//   // ---------------- CONTINUOUS LOOP ----------------
//   Future<void> _runContinuousLoop() async {
//   int iteration = 0;

//   while (isLooping && iteration < 3 && mounted) {
//     iteration++;

//     // 1. Capture Image (EVERY TIME)
//     await _captureImage();
//     if (!mounted) break;

//     // 2. Ask question ONLY ONCE
//     if (!hasFixedQuestion) {
//       await _tts.speak("Ask question.");
//       if (!mounted) break;

//       setState(() {
//         _question = null;
//         _answer = null;
//       });

//       String? questionText = await _recordQuestion();
//       if (!mounted || questionText == null || questionText.isEmpty) {
//         continue;
//       }

//       setState(() {
//         _question = questionText;
//         hasFixedQuestion = true;
//       });
//     }

//     // 3. Get Answer using SAME question
//     String? answerText = await _fetchAnswer(_question!);
//     if (!mounted) break;

//     if (answerText != null) {
//       setState(() => _answer = answerText);
//       await _tts.speak(answerText);
//     } else {
//       await _tts.speak("Could not get answer.");
//     }

//     await Future.delayed(const Duration(seconds: 1));
//   }

//   // Loop finished
//   isLooping = false;
//   hasFixedQuestion = false;

//   if (mounted) {
//     await _tts.speak("Temporal session finished. Say ask to start again.");
//     _listenForCommand();
//   }
// }


//   // ---------------- STEPS ----------------
//   Future<void> _captureImage() async {
//     try {
//       final img = await _picker.pickImage(source: ImageSource.camera);
//       if (img != null && mounted) {
//         setState(() => _image = File(img.path));
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }

//   // Returns question text or null
//   Completer<String?>? _recordingCompleter;
  
//   Future<String?> _recordQuestion() async {
//     if (!mounted) return null;
    
//     // Stop VAD listening just in case
//     await _vad.stopListening();
    
//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/temporal_qa.m4a";

//     _recordingCompleter = Completer<String?>();

//     // Start Recorder
//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
    
//     // Start VAD
//     await _vad.startListening();

//     // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
//     // which completes the completer.
    
//     return _recordingCompleter!.future;
//   }

//   Future<void> _stopRecordingQuestion() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();
    
//     if (_audioPath == null) {
//       _recordingCompleter?.complete(null);
//       return;
//     }

//     // Transcribe
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
//       req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//       final res = await req.send();
      
//       if (res.statusCode == 200) {
//         final body = await res.stream.bytesToString();
//         final text = json.decode(body)["text"];
//         _recordingCompleter?.complete(text);
//       } else {
//         _recordingCompleter?.complete(null);
//       }
//     } catch (e) {
//       _recordingCompleter?.complete(null);
//     }
//   }

//   Future<String?> _fetchAnswer(String question) async {
//     if (_image == null) return null;
    
//     setState(() => _loading = true);
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
//       req.fields["question"] = question;
//       req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
//       final res = await req.send();
//       final body = await res.stream.bytesToString();
      
//       setState(() => _loading = false);
//       if (res.statusCode == 200) {
//         return json.decode(body)["answer"];
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//     return null;
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     isLooping = false; // Stop loop
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
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
//           onPressed: () {
//             isLooping = false;
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const QAScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Temporal Mode", 
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

//                   _buildTopButton("Home", Colors.blueAccent, () {
//                     isLooping = false;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
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
//                             Icons.camera_alt, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Waiting for loop...",
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
            
//             if (isLooping)
//                Padding(
//                  padding: const EdgeInsets.only(top: 20),
//                  child: Text(
//                    "Loop Active...",
//                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                  ),
//                ),
               
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
// }




//10 Times with img change & Continue
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
// import 'home_screen.dart';
// import 'qna_screen.dart';

// class TemporalScreen extends StatefulWidget {
//   const TemporalScreen({super.key});

//   @override
//   State<TemporalScreen> createState() => _TemporalScreenState();
// }

// class _TemporalScreenState extends State<TemporalScreen> {
//   // ---------------- STATE ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;
  
//   // Controls the continuous loop
//   bool isLooping = false;
//   // Controls the initial command listening
//   bool isListeningForCommand = false;

//   bool hasFixedQuestion = false;

//   bool waitingForPostLoopCommand = false;

//   // ---------------- UTILS ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? _commandTimer;
//   Timer? silenceTimer;
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
//     await _tts.awaitSpeakCompletion(true);
//   }

//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);
    
//     // VAD logic for the Question recording
//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       // Wait 1s of silence before stopping recording
//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         // Only stop if we are currently recording a question
//          if (_recorder.isRecording && !isListeningForCommand && mounted) {
//            await _stopRecordingQuestion();
//          }
//       });
//     });
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure no lingering handlers
//     _tts.setCompletionHandler(() {});

//     await _tts.speak(
//       "Temporal mode. Say 'ask' to start the continuous loop.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- COMMAND LISTENER ----------------
//   Future<void> _listenForCommand() async {
//     if (isLooping || isListeningForCommand || !mounted) return;

//     isListeningForCommand = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command_temporal.wav";

//     // Start recording for command
//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Fixed timer for command listening
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted || !isListeningForCommand) return;

//       String? path = await _recorder.stopRecorder();
//       isListeningForCommand = false;

//       if (path != null && mounted) {
//         await _processCommand(path);
//       }
//     });
//   }

//   Future<void> _processCommand(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         if (text.contains("ask")) {
//           // START THE LOOP
//           isLooping = true;
//           hasFixedQuestion = false; // 🔑 allow new question
//           waitingForPostLoopCommand = false;
//           await _tts.speak("Starting continuous loop.");
//           if (mounted) _runContinuousLoop();
//         }
//         else if (text.contains("continue") && waitingForPostLoopCommand) {
//            isLooping = true;
//           waitingForPostLoopCommand = false;

//             await _tts.speak("Continuing loop.");
//            if (mounted) _runContinuousLoop();
//        } 
//        else if (text.contains("stop")) {
//           // Stop recording and VAD
//           isLooping = false;
//           hasFixedQuestion = false;
//           waitingForPostLoopCommand = false;
//          _question = null;

//           await _recorder.stopRecorder();
//           await _vad.stopListening();
//           await _tts.speak("Microphone stopped");
//         }
//         else {
//           // WRONG COMMAND FEEDBACK
//           await _tts.speak("Wrong command, say correct command.");
//           if (mounted) _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//       if (mounted) _listenForCommand();
//     }
//   }

//   // ---------------- CONTINUOUS LOOP ----------------
//   Future<void> _runContinuousLoop() async {
//   int iteration = 0;

//   while (isLooping && iteration < 10 && mounted) {
//     iteration++;

//     // 1. Capture Image (EVERY TIME)
//     await _captureImage();
//     if (!mounted) break;

//     // 2. Ask question ONLY ONCE
//     if (!hasFixedQuestion) {
//       await _tts.speak("Ask question.");
//       if (!mounted) break;

//       setState(() {
//         _question = null;
//         _answer = null;
//       });

//       String? questionText = await _recordQuestion();
//       if (!mounted || questionText == null || questionText.isEmpty) {
//         continue;
//       }

//       setState(() {
//         _question = questionText;
//         hasFixedQuestion = true;
//       });
//     }

//     // 3. Get Answer using SAME question
//     String? answerText = await _fetchAnswer(_question!);
//     if (!mounted) break;

//     if (answerText != null) {
//       setState(() => _answer = answerText);
//       await _tts.speak(answerText);
//     } else {
//       await _tts.speak("Could not get answer.");
//     }

//     await Future.delayed(const Duration(seconds: 1));
//   }

//   // Loop finished
//   isLooping = false;
// waitingForPostLoopCommand = true;

// if (mounted) {
//   await _tts.speak(
//     "Loop finished. Say continue to continue the loop or say stop to exit."
//   );
//   _listenForCommand();
// }
// }

//   // ---------------- STEPS ----------------
//   Future<void> _captureImage() async {
//     try {
//       final img = await _picker.pickImage(source: ImageSource.camera);
//       if (img != null && mounted) {
//         setState(() => _image = File(img.path));
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }

//   // Returns question text or null
//   Completer<String?>? _recordingCompleter;
  
//   Future<String?> _recordQuestion() async {
//     if (!mounted) return null;
    
//     // Stop VAD listening just in case
//     await _vad.stopListening();
    
//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/temporal_qa.m4a";

//     _recordingCompleter = Completer<String?>();

//     // Start Recorder
//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
    
//     // Start VAD
//     await _vad.startListening();

//     // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
//     // which completes the completer.
    
//     return _recordingCompleter!.future;
//   }

//   Future<void> _stopRecordingQuestion() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();
    
//     if (_audioPath == null) {
//       _recordingCompleter?.complete(null);
//       return;
//     }

//     // Transcribe
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
//       req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//       final res = await req.send();
      
//       if (res.statusCode == 200) {
//         final body = await res.stream.bytesToString();
//         final text = json.decode(body)["text"];
//         _recordingCompleter?.complete(text);
//       } else {
//         _recordingCompleter?.complete(null);
//       }
//     } catch (e) {
//       _recordingCompleter?.complete(null);
//     }
//   }

//   Future<String?> _fetchAnswer(String question) async {
//     if (_image == null) return null;
    
//     setState(() => _loading = true);
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
//       req.fields["question"] = question;
//       req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
//       final res = await req.send();
//       final body = await res.stream.bytesToString();
      
//       setState(() => _loading = false);
//       if (res.statusCode == 200) {
//         return json.decode(body)["answer"];
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//     return null;
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     isLooping = false; // Stop loop
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
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
//           onPressed: () {
//             isLooping = false;
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const QAScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Temporal Mode", 
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

//                   _buildTopButton("Home", Colors.blueAccent, () {
//                     isLooping = false;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
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
//                             Icons.camera_alt, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Waiting for loop...",
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
            
//             if (isLooping)
//                Padding(
//                  padding: const EdgeInsets.only(top: 20),
//                  child: Text(
//                    "Loop Active...",
//                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                  ),
//                ),
               
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
// }




// //3 Times with img change & Continue
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
// import 'home_screen.dart';
// import 'qna_screen.dart';

// class TemporalScreen extends StatefulWidget {
//   const TemporalScreen({super.key});

//   @override
//   State<TemporalScreen> createState() => _TemporalScreenState();
// }

// class _TemporalScreenState extends State<TemporalScreen> {
//   // ---------------- STATE ----------------
//   File? _image;
//   String? _question;
//   String? _answer;
//   bool _loading = false;
  
//   // Controls the continuous loop
//   bool isLooping = false;
//   // Controls the initial command listening
//   bool isListeningForCommand = false;

//   bool hasFixedQuestion = false;

//   bool waitingForPostLoopCommand = false;


//   // ---------------- UTILS ----------------
//   final ImagePicker _picker = ImagePicker();
//   final FlutterTts _tts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   late VadHandler _vad;
//   Timer? _commandTimer;
//   Timer? silenceTimer;
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
//     await _tts.awaitSpeakCompletion(true);
//   }

//   void _initVAD() {
//     _vad = VadHandler.create(isDebug: false);
    
//     // VAD logic for the Question recording
//     _vad.onSpeechStart.listen((_) {
//       silenceTimer?.cancel();
//     });

//     _vad.onSpeechEnd.listen((_) {
//       silenceTimer?.cancel();
//       // Wait 1s of silence before stopping recording
//       silenceTimer = Timer(const Duration(seconds: 1), () async {
//         // Only stop if we are currently recording a question
//          if (_recorder.isRecording && !isListeningForCommand && mounted) {
//            await _stopRecordingQuestion();
//          }
//       });
//     });
//   }

//   // ---------------- WELCOME ----------------
//   Future<void> _speakWelcome() async {
//     // Ensure no lingering handlers
//     _tts.setCompletionHandler(() {});

//     await _tts.speak(
//       "Temporal mode. Say 'ask' to start the continuous loop.",
//     );
    
//     if (mounted) _listenForCommand();
//   }

//   // ---------------- COMMAND LISTENER ----------------
//   Future<void> _listenForCommand() async {
//     if (isLooping || isListeningForCommand || !mounted) return;

//     isListeningForCommand = true;

//     Directory tempDir = await getTemporaryDirectory();
//     String filePath = "${tempDir.path}/command_temporal.wav";

//     // Start recording for command
//     await _recorder.startRecorder(
//       toFile: filePath,
//       codec: Codec.pcm16WAV,
//       sampleRate: 16000,
//       numChannels: 1,
//     );

//     // Fixed timer for command listening
//     _commandTimer?.cancel();
//     _commandTimer = Timer(RECORD_TIME, () async {
//       if (!mounted || !isListeningForCommand) return;

//       String? path = await _recorder.stopRecorder();
//       isListeningForCommand = false;

//       if (path != null && mounted) {
//         await _processCommand(path);
//       }
//     });
//   }

//   Future<void> _processCommand(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           path,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       var response = await http.Response.fromStream(await request.send());

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String text = (data['text'] ?? '').toLowerCase().trim();

//         if (text.contains("ask")) {
//           // START THE LOOP
//           isLooping = true;
//             hasFixedQuestion = false;
//             waitingForPostLoopCommand = false;
//           await _tts.speak("Starting continuous loop.");
//           if (mounted) _runContinuousLoop();
//         } 
//         else if (text.contains("continue") && waitingForPostLoopCommand) {
//         // CONTINUE LOOP (same question)
//         isLooping = true;
//         waitingForPostLoopCommand = false;

//         await _tts.speak("Continuing loop.");
//         if (mounted) _runContinuousLoop();
//         }
//        else if (text.contains("stop")) {
//           // Stop recording and VAD
//           isLooping = false;
//           hasFixedQuestion = false;
//           waitingForPostLoopCommand = false;
//           await _recorder.stopRecorder();
//           await _vad.stopListening();
//           await _tts.speak("Microphone stopped");
//         }
//         else {
//           // WRONG COMMAND FEEDBACK
//           await _tts.speak("Wrong command, say correct command.");
//           if (mounted) _listenForCommand();
//         }
//       }
//     } catch (e) {
//       debugPrint("Command error: $e");
//       if (mounted) _listenForCommand();
//     }
//   }

//   // ---------------- CONTINUOUS LOOP ----------------
//   Future<void> _runContinuousLoop() async {
//   int iteration = 0;

//   while (isLooping && iteration < 3 && mounted) {
//     iteration++;

//     // 1. Capture Image (EVERY TIME)
//     await _captureImage();
//     if (!mounted) break;

//     // 2. Ask question ONLY ONCE
//     if (!hasFixedQuestion) {
//       await _tts.speak("Ask question.");
//       if (!mounted) break;

//       setState(() {
//         _question = null;
//         _answer = null;
//       });

//       String? questionText = await _recordQuestion();
//       if (!mounted || questionText == null || questionText.isEmpty) {
//         continue;
//       }

//       setState(() {
//         _question = questionText;
//         hasFixedQuestion = true;
//       });
//     }

//     // 3. Get Answer using SAME question
//     String? answerText = await _fetchAnswer(_question!);
//     if (!mounted) break;

//     if (answerText != null) {
//       setState(() => _answer = answerText);
//       await _tts.speak(answerText);
//     } else {
//       await _tts.speak("Could not get answer.");
//     }

//     await Future.delayed(const Duration(seconds: 1));
//   }

//   // Loop finished
//   isLooping = false;
//   waitingForPostLoopCommand = true;

//   if (mounted) {
//     await _tts.speak("Temporal session finished. Say ask to start again.");
//     _listenForCommand();
//   }
// }


//   // ---------------- STEPS ----------------
//   Future<void> _captureImage() async {
//     try {
//       final img = await _picker.pickImage(source: ImageSource.camera);
//       if (img != null && mounted) {
//         setState(() => _image = File(img.path));
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }

//   // Returns question text or null
//   Completer<String?>? _recordingCompleter;
  
//   Future<String?> _recordQuestion() async {
//     if (!mounted) return null;
    
//     // Stop VAD listening just in case
//     await _vad.stopListening();
    
//     Directory tempDir = await getTemporaryDirectory();
//     _audioPath = "${tempDir.path}/temporal_qa.m4a";

//     _recordingCompleter = Completer<String?>();

//     // Start Recorder
//     await _recorder.startRecorder(
//       toFile: _audioPath,
//       codec: Codec.aacMP4,
//     );
    
//     // Start VAD
//     await _vad.startListening();

//     // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
//     // which completes the completer.
    
//     return _recordingCompleter!.future;
//   }

//   Future<void> _stopRecordingQuestion() async {
//     await _recorder.stopRecorder();
//     await _vad.stopListening();
    
//     if (_audioPath == null) {
//       _recordingCompleter?.complete(null);
//       return;
//     }

//     // Transcribe
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
//       req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
//       final res = await req.send();
      
//       if (res.statusCode == 200) {
//         final body = await res.stream.bytesToString();
//         final text = json.decode(body)["text"];
//         _recordingCompleter?.complete(text);
//       } else {
//         _recordingCompleter?.complete(null);
//       }
//     } catch (e) {
//       _recordingCompleter?.complete(null);
//     }
//   }

//   Future<String?> _fetchAnswer(String question) async {
//     if (_image == null) return null;
    
//     setState(() => _loading = true);
//     try {
//       final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
//       req.fields["question"] = question;
//       req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
//       final res = await req.send();
//       final body = await res.stream.bytesToString();
      
//       setState(() => _loading = false);
//       if (res.statusCode == 200) {
//         return json.decode(body)["answer"];
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//     return null;
//   }

//   // ---------------- DISPOSE ----------------
//   @override
//   void dispose() {
//     isLooping = false; // Stop loop
//     _commandTimer?.cancel();
//     silenceTimer?.cancel();
//     _recorder.closeRecorder();
//     _tts.stop();
//     _vad.dispose();
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
//           onPressed: () {
//             isLooping = false;
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const QAScreen()),
//               (_) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Temporal Mode", 
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

//                   _buildTopButton("Home", Colors.blueAccent, () {
//                     isLooping = false;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
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
//                             Icons.camera_alt, 
//                             size: 80, 
//                             color: Colors.blueAccent.withOpacity(0.5)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Waiting for loop...",
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
            
//             if (isLooping)
//                Padding(
//                  padding: const EdgeInsets.only(top: 20),
//                  child: Text(
//                    "Loop Active...",
//                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                  ),
//                ),
               
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
// }



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
// import 'debugblind_screen.dart';
// import 'home_screen.dart';
import 'qna_screen.dart';

class TemporalScreen extends StatefulWidget {
  const TemporalScreen({super.key});

  @override
  State<TemporalScreen> createState() => _TemporalScreenState();
}

class _TemporalScreenState extends State<TemporalScreen> {
  // ---------------- STATE ----------------
  File? _image;
  String? _question;
  String? _answer;
  bool _loading = false;
  
  // Controls the continuous loop
  bool isLooping = false;
  // Controls the initial command listening
  bool isListeningForCommand = false;

  bool hasFixedQuestion = false;

  bool waitingForPostLoopCommand = false;

 bool temopralLoop= false;
 
 bool monitorLoop= false;
  // ---------------- UTILS ----------------
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  late VadHandler _vad;
  Timer? _commandTimer;
  Timer? silenceTimer;
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
    await _tts.awaitSpeakCompletion(true);
  }

  void _initVAD() {
    _vad = VadHandler.create(isDebug: false);
    
    // VAD logic for the Question recording
    _vad.onSpeechStart.listen((_) {
      silenceTimer?.cancel();
    });

    _vad.onSpeechEnd.listen((_) {
      silenceTimer?.cancel();
      // Wait 1s of silence before stopping recording
      silenceTimer = Timer(const Duration(seconds: 1), () async {
        // Only stop if we are currently recording a question
         if (_recorder.isRecording && !isListeningForCommand && mounted) {
           await _stopRecordingQuestion();
         }
      });
    });
  }

  // ---------------- WELCOME ----------------
  Future<void> _speakWelcome() async {
    // Ensure no lingering handlers
    _tts.setCompletionHandler(() {});

    await _tts.speak(
      "Temporal mode. Say 'commands' to start the continuous loop.",
    );
    
    if (mounted) _listenForCommand();
  }

  // ---------------- COMMAND LISTENER ----------------
  Future<void> _listenForCommand() async {
    if (isLooping || isListeningForCommand || !mounted) return;

    isListeningForCommand = true;

    Directory tempDir = await getTemporaryDirectory();
    String filePath = "${tempDir.path}/command_temporal.wav";

    // Start recording for command
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    // Fixed timer for command listening
    _commandTimer?.cancel();
    _commandTimer = Timer(RECORD_TIME, () async {
      if (!mounted || !isListeningForCommand) return;

      String? path = await _recorder.stopRecorder();
      isListeningForCommand = false;

      if (path != null && mounted) {
        await _processCommand(path);
      }
    });
  }

  Future<void> _processCommand(String path) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(API_COMMAND_URL));
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var response = await http.Response.fromStream(await request.send());

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String text = (data['text'] ?? '').toLowerCase().trim();

        if (text.contains("temporal on") && !temopralLoop) {
          // START THE LOOP
          isLooping = true;
            hasFixedQuestion = false;
            waitingForPostLoopCommand = false;
            temopralLoop=true;
          await _tts.speak("Starting Temporal Questions.");
          if (mounted) _runContinuousLoop();
        } 
          else if (text.contains("monitor on") && !monitorLoop) {
          // START THE LOOP
          isLooping = true;
            hasFixedQuestion = false;
            waitingForPostLoopCommand = false;
            monitorLoop=true;
          await _tts.speak("Starting Monitor Questions.");
          if (mounted) _runContinuousLoop();
        } 
        else if (text.contains("continue") && waitingForPostLoopCommand) {
        // CONTINUE LOOP (same question)
        isLooping = true;
        waitingForPostLoopCommand = false;

        await _tts.speak("Continuing loop.");
        if (mounted) _runContinuousLoop();
        }
       else if (text.contains("stop")) {
          // Stop recording and VAD
          isLooping = false;
          hasFixedQuestion = false;
          waitingForPostLoopCommand = false;
          await _recorder.stopRecorder();
          await _vad.stopListening();
          await _tts.speak("Microphone stopped");
        }
        else {
          // WRONG COMMAND FEEDBACK
          await _tts.speak("Wrong command, say correct command.");
          if (mounted) _listenForCommand();
        }
      }
    } catch (e) {
      debugPrint("Command error: $e");
      if (mounted) _listenForCommand();
    }
  }

  // ---------------- CONTINUOUS LOOP ----------------
  Future<void> _runContinuousLoop() async {
  int iteration = 0;

  while (isLooping && iteration < 3 && mounted) {
    iteration++;

    // 1. Capture Image (EVERY TIME)
    await _captureImage();
    if (!mounted) break;

    // 2. Ask question ONLY ONCE
    if (!hasFixedQuestion) {
      await _tts.speak("Ask question.");
      if (!mounted) break;

      setState(() {
        _question = null;
        _answer = null;
      });

      String? questionText = await _recordQuestion();
      if (!mounted || questionText == null || questionText.isEmpty) {
        continue;
      }

      setState(() {
        _question = questionText;
        hasFixedQuestion = true;
      });
    }

    // 3. Get Answer using SAME question
    String? answerText = await _fetchAnswer(_question!);
    if (!mounted) break;

    if (answerText != null) {
  setState(() => _answer = answerText);
  // Speak ONLY if answer is true
  final normalized = answerText.toLowerCase().trim();
  if (normalized == "left" || normalized == "leave") {
    temopralLoop=true;
    await _tts.speak("The person has left the room");
    
  }
  else if(normalized == "angry" || normalized == "sad" ||  normalized == "fear" ||  normalized == "happy"){
    monitorLoop=true;
     await _tts.speak("The emotion of the person is$answerText");
  }
}
 else{
    print("Error! Not Matche");
 }
    await Future.delayed(const Duration(seconds: 1));
  }
 
  // Loop finished
  isLooping = false;
  waitingForPostLoopCommand = true;

  if (mounted) {
    await _tts.speak("Temporal session finished. Say ask to start again.");
    _listenForCommand();
  }
}


  // ---------------- STEPS ----------------
  Future<void> _captureImage() async {
    try {
      final img = await _picker.pickImage(source: ImageSource.camera);
      if (img != null && mounted) {
        setState(() => _image = File(img.path));
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // Returns question text or null
  Completer<String?>? _recordingCompleter;
  
  Future<String?> _recordQuestion() async {
    if (!mounted) return null;
    
    // Stop VAD listening just in case
    await _vad.stopListening();
    
    Directory tempDir = await getTemporaryDirectory();
    _audioPath = "${tempDir.path}/temporal_qa.m4a";

    _recordingCompleter = Completer<String?>();

    // Start Recorder
    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: Codec.aacMP4,
    );
    
    // Start VAD
    await _vad.startListening();

    // The VAD onSpeechEnd listener (defined in init) will call _stopRecordingQuestion
    // which completes the completer.
    
    return _recordingCompleter!.future;
  }

  Future<void> _stopRecordingQuestion() async {
    await _recorder.stopRecorder();
    await _vad.stopListening();
    
    if (_audioPath == null) {
      _recordingCompleter?.complete(null);
      return;
    }

    // Transcribe
    try {
      final req = http.MultipartRequest("POST", Uri.parse(Api.sttTranscribe));
      req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
      final res = await req.send();
      
      if (res.statusCode == 200) {
        final body = await res.stream.bytesToString();
        final text = json.decode(body)["text"];
        _recordingCompleter?.complete(text);
      } else {
        _recordingCompleter?.complete(null);
      }
    } catch (e) {
      _recordingCompleter?.complete(null);
    }
  }

  Future<String?> _fetchAnswer(String question) async {
    if (_image == null) return null;
    
    setState(() => _loading = true);
    try {
      final req = http.MultipartRequest("POST", Uri.parse(Api.getAnswerWithId(blindId)));
      req.fields["question"] = question;
      req.files.add(await http.MultipartFile.fromPath("image", _image!.path));
      
      final res = await req.send();
      final body = await res.stream.bytesToString();
      
      setState(() => _loading = false);
      if (res.statusCode == 200) {
        return json.decode(body)["answer"];
      }
    } catch (e) {
      setState(() => _loading = false);
    }
    return null;
  }

  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
    isLooping = false; // Stop loop
    _commandTimer?.cancel();
    silenceTimer?.cancel();
    _recorder.closeRecorder();
    _tts.stop();
    _vad.dispose();
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
          onPressed: () {
            isLooping = false;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const QAScreen()),
              (_) => false,
            );
          },
        ),
        title: const Text(
          "Temporal Mode", 
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
                  _buildTopButton("Temporal", Colors.redAccent, () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const DebugScreen()),
                    // );
                  }),
                  
                  // Eye Logo
                  const Icon(
                     Icons.remove_red_eye, 
                     size: 60, 
                     color: Color(0xFF0D47A1), // Navy Blue
                  ),

                  _buildTopButton("Monitor", Colors.blueAccent, () {
                    // isLooping = false;
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const HomeScreen()),
                    // );
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
                            Icons.camera_alt, 
                            size: 80, 
                            color: Colors.blueAccent.withOpacity(0.5)
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Waiting for loop...",
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
            
            if (isLooping)
               Padding(
                 padding: const EdgeInsets.only(top: 20),
                 child: Text(
                   "Loop Active...",
                   style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
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
