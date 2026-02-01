// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   PorcupineManager? _porcupineManager;
//   final FlutterTts _flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _initTTS();
//     _initWakeWord();
//   }

//   // 🔊 TTS Welcome Message
//   Future<void> _initTTS() async {
//     await _flutterTts.setSpeechRate(0.45);
//     await _flutterTts.setVolume(1.0);
//     await _flutterTts.setPitch(1.0);

//     await _flutterTts.speak(
//       "Welcome to NSVQA app. Say open app to go to blind person screen",
//     );
//   }

//   // 🎤 Wake-word initialization
//   Future<void> _initWakeWord() async {
//     await Permission.microphone.request();

//     try {
//       _porcupineManager = await PorcupineManager.fromKeywordPaths(
//         "J5xSDc8Kz/7MpSK/DnZHphTWHu6zTFv7XEXjVial/0g4ird7dUGxIA==",
//         ["assets/wake_words/Hey-Siri_en_android_v3_0_0.ppn"],
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
//     Navigator.pushReplacementNamed(context, '/qa');
//   }

//   @override
//   void dispose() {
//     _porcupineManager?.stop();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: const Color(0xFFA8D5C5),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.remove_red_eye, size: 100, color: Colors.blue.shade900),
//             const SizedBox(height: 20),

//             const Text(
//               "NS-VQA App",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             const Text(
//               "AI that sees, reasons\nand explains",
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),

//             // 🔲 Login Button (Assistant/Admin only)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/login');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
//               ),
//               child: const Text("Login",
//                   style: TextStyle(fontSize: 18, color: Colors.white)),
//             ),

//             const SizedBox(height: 50),

//             // 🎤 Manual fallback for blind users
//             IconButton(
//               icon: Icon(Icons.mic, size: 70, color: Colors.green.shade900),
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/qa');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: const Color(0xFFA8D5C5), // light teal
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 👁 Logo
//             Icon(Icons.remove_red_eye, size: 100, color: Colors.blue.shade900),
//             const SizedBox(height: 20),

//             // Title
//             const Text(
//               "NS-VQA App",
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Subtitle
//             const Text(
//               "AI that sees, reasons\nand explains",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//             const SizedBox(height: 30),

//             // 🔲 Black Login Button
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/login');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
//               ),
//               child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
//             ),
//             const SizedBox(height: 50),

//             // 🎤 Mic button
//             IconButton(
//               icon: Icon(Icons.mic, size: 70, color: Colors.green.shade900),
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/qa');
//               },
//             ),
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
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../services/api.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final FlutterTts _flutterTts = FlutterTts();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   bool _isListening = false;
//   bool _recorderOpened = false;

//   static const Duration RECORD_TIME = Duration(seconds: 3);
//   static const String API_URL = Api.sttCommand;

//   @override
// void initState() {
//   super.initState();

//   // Reset any old TTS handlers
//   _flutterTts.setCompletionHandler(() {});

//   _initTTS();
// }

// // 🔊 Welcome message
// Future<void> _initTTS() async {
//   await _flutterTts.setSpeechRate(0.45);
//   await _flutterTts.setVolume(1.0);
//   await _flutterTts.setPitch(1.0);

//   // After TTS completes, start listening
//   _flutterTts.setCompletionHandler(() {
//     debugPrint("TTS completed, starting microphone");
//     _initRecorder();
//   });

//   await _flutterTts.speak(
//     "Welcome to NSVQA app. Say start to open the application",
//   );
// }

// // 🎤 Recorder init
// Future<void> _initRecorder() async {
//     if (!_recorderOpened) {  // use manual flag
//       await Permission.microphone.request();
//       await _recorder.openRecorder();
//       _recorderOpened = true;
//     }

//     _listenForStart();
//   }

// // 🎙 Listen & detect "start"
// Future<void> _listenForStart() async {
//   if (_isListening) return;
//   _isListening = true;

//   Directory tempDir = await getTemporaryDirectory();
//   String filePath = "${tempDir.path}/start.wav";

//   await _recorder.startRecorder(
//     toFile: filePath,
//     codec: Codec.pcm16WAV,
//     sampleRate: 16000,
//     numChannels: 1,
//   );

//   Timer(RECORD_TIME, () async {
//     String? path = await _recorder.stopRecorder();
//     _isListening = false;

//     if (path != null) {
//       await _sendAudio(path);
//     }

//     // Continue listening for start
//     _listenForStart();
//   });
// }

// // 📡 Send audio to backend
// Future<void> _sendAudio(String path) async {
//   try {
//     var request = http.MultipartRequest('POST', Uri.parse(API_URL));

//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     var response = await http.Response.fromStream(await request.send());

//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       String text = (data['text'] ?? '').toLowerCase().trim();

//       if (text.contains("start")) {
//         await _flutterTts.speak("Opening application");

//         if (!mounted) return;
//         Navigator.pushReplacementNamed(context, '/qa');
//       } else {
//         // ❌ Wrong command TTS
//         await _flutterTts.speak(
//           "Wrong command, please say start to open the application",
//         );

//         _flutterTts.setCompletionHandler(() async {
//           await _listenForStart();
//         });
//       }
//     } else {
//       await _flutterTts.speak(
//         "Unable to recognize. Please say start to open the application",
//       );
//     }
//   } catch (e) {
//     debugPrint("Voice error: $e");
//   }
// }

// // Dispose
// @override
// void dispose() {
//   if (_recorder.isRecording) {
//     _recorder.closeRecorder();
//   }
//     _flutterTts.stop();
//     super.dispose();
// }

//   // 🔲 UI 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: const Color(0xFFA8D5C5),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.remove_red_eye,
//                 size: 100, color: Colors.blue.shade900),
//             const SizedBox(height: 20),

//             const Text(
//               "NS-VQA App",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             const Text(
//               "AI that sees, reasons\nand explains",
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),

//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/login');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 60, vertical: 15),
//               ),
//               child: const Text(
//                 "Login",
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),

//             const SizedBox(height: 50),

//             // 🎤 Manual fallback
//             IconButton(
//               icon: Icon(Icons.mic,
//                   size: 70, color: Colors.green.shade900),
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/qa');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isListening = false;
  bool _isRecorderInitialized = false;
  bool _shouldListen = true; // New flag to control the listening loop
  bool _isFirstLaunch = true;

  static const Duration RECORD_TIME = Duration(seconds: 3);
  static const String API_URL = Api.sttCommand;

  @override
  void initState() {
    super.initState();

    // Reset any old TTS handlers
    _flutterTts.setCompletionHandler(() {});

    _initTTS();
  }
  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  // When route becomes visible again (user came back), resume listening
  final ModalRoute? route = ModalRoute.of(context);
  if (route is PageRoute && route.isCurrent) {
    // We are now the active screen
    if (!_isFirstLaunch && _shouldListen && mounted) {
      debugPrint("HomeScreen resumed, starting listening");
      _initRecorder();
    }
  }
}

  // 🔊 Welcome message
  Future<void> _initTTS() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Persistent handler: after any TTS completion, resume listening (only if still on this screen)
    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS completed, starting microphone");
      if (_shouldListen) {
        _initRecorder();
      }
    });

    // Only speak welcome message on FIRST launch
  if (_isFirstLaunch) {
    _isFirstLaunch = false;
    await _flutterTts.speak(
      "Welcome to NSVQA app. Say start to open the application",
    );
  } else {
    // Just resume listening silently when coming back
    if (_shouldListen && mounted) {
      _initRecorder();
    }
  }
  }

  // 🎤 Recorder init
  Future<void> _initRecorder() async {
    if (!_isRecorderInitialized) {
      await Permission.microphone.request();
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    }

    if (_shouldListen) {
      _listenForStart();
    }
  }

  // 🎙 Listen & detect "start"
  Future<void> _listenForStart() async {
    if (!_shouldListen || _isListening) return;

    _isListening = true;

    Directory tempDir = await getTemporaryDirectory();
    String filePath = "${tempDir.path}/start.wav";

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    Timer(RECORD_TIME, () async {
      String? path = await _recorder.stopRecorder();
      _isListening = false;

      if (path != null && _shouldListen) {
        await _sendAudio(path);
      }

      // Continue listening only if still needed
      if (_shouldListen) {
        _listenForStart();
      }
    });
  }

  // 📡 Send audio to backend
  Future<void> _sendAudio(String path) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(API_URL));

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String text = (data['text'] ?? '').toLowerCase().trim();

        if (text.contains("start")) {
          await _stopListening(); // Stop the listening loop

          await _flutterTts.speak("Opening application");

          if (!mounted) return;
          // Changed to push (not pushReplacement) so user can return with pop()
          Navigator.pushNamed(context, '/qa');
        } else {
          // Wrong command
          await _flutterTts.speak(
            "Wrong command, please say start to open the application",
          );
          // Listening will resume automatically via the persistent completion handler
        }
      } else {
        await _flutterTts.speak(
          "Unable to recognize. Please say start to open the application",
        );
      }
    } catch (e) {
      debugPrint("Voice error: $e");
    }
  }

  //Stop Recording
  Future<void> _stopListening() async {
  _shouldListen = false; // Prevent any new recording from starting

  if (_isListening) {
    await _recorder.stopRecorder();
    _isListening = false;
  }
}

  // Dispose
  @override
  void dispose() {
    _shouldListen = false;

    _flutterTts.stop();
    _flutterTts.setCompletionHandler(() {});

    if (_isRecorderInitialized) {
      _recorder.stopRecorder();
      _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }

    super.dispose();
  }

  // 🔲 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFA8D5C5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_red_eye,
                size: 100, color: Colors.blue.shade900),
            const SizedBox(height: 20),

            const Text(
              "NS-VQA App",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              "AI that sees, reasons\nand explains",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
              await _stopListening(); // ← Add this
               if (!mounted) return;
                 Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 15),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 50),

            // 🎤 Manual fallback
            IconButton(
              icon: Icon(Icons.mic, size: 70, color: Colors.green.shade900),
              onPressed: () async {
                await _stopListening(); // ← Add this too
                if (!mounted) return;
                  Navigator.pushNamed(context, '/qa');
              },
            ),
          ],
        ),
      ),
    );
  }
}