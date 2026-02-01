// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// // import 'package:porcupine_flutter/porcupine.dart';
// import 'package:porcupine_flutter/porcupine_manager.dart';
// import 'package:vad/vad.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text("Wake-word + VAD Debug Example")),
//         body: const MyHomePage(),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   PorcupineManager? _porcupineManager;
//   late VadHandler _vadHandler;
//   bool isListening = false;
//   final List<String> events = [];

//   @override
//   void initState() {
//     super.initState();
//     _initVAD();
//     _initPorcupine();
//   }

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
//     });

//     _vadHandler.onError.listen((e) {
//       debugPrint("[VAD] Error: $e");
//       setState(() => events.add("[VAD] Error: $e"));
//     });
//   }

//   void _initPorcupine() async {
//   // Request microphone permission
//   final status = await Permission.microphone.request();
//   debugPrint("[Permission] Microphone status: $status");
//   setState(() => events.add("[Permission] Microphone status: $status"));

//   try {
//     debugPrint("[Porcupine] Initializing custom model...");
//      //J5xSDc8Kz/7MpSK/DnZHphTWHu6zTFv7XEXjVial/0g4ird7dUGxIA==
//     // Use PorcupineManager.fromKeywordPaths for .ppn files
//     _porcupineManager = await PorcupineManager.fromKeywordPaths(
//       "J5xSDc8Kz/7MpSK/DnZHphTWHu6zTFv7XEXjVial/0g4ird7dUGxIA==", // your Picovoice access key
//       ["assets/wake_words/Hey-Siri_en_android_v3_0_0.ppn"],
//       _wakeWordCallback,
//     );

//     debugPrint("[Porcupine] Starting...");
//     await _porcupineManager?.start();
//     debugPrint("[Porcupine] Started successfully");
//     setState(() => events.add("[Porcupine] Started successfully"));
//   } catch (err) {
//     debugPrint("[Porcupine] Init error: $err");
//     setState(() => events.add("[Porcupine] Init error: $err"));
//   }
// }

//   void _wakeWordCallback(int keywordIndex) async {
//     debugPrint("[Porcupine] Wake-word detected! index: $keywordIndex");
//     setState(() => events.add("[Porcupine] Wake-word detected! index: $keywordIndex"));

//     // Stop Porcupine temporarily to avoid multiple triggers
//     debugPrint("[Porcupine] Stopping to start VAD...");
//     await _porcupineManager?.stop();

//     // Start VAD listening automatically
//     await _startListening();
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

//     // Restart Porcupine for the next wake-word
//     debugPrint("[Porcupine] Restarting...");
//     await _porcupineManager?.start();
//   }

//   @override
//   void dispose() {
//     _vadHandler.dispose();
//     _porcupineManager?.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: ListView.builder(
//         itemCount: events.length,
//         itemBuilder: (context, index) {
//           return ListTile(title: Text(events[index]));
//         },
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceListener(),
    ),
  );
}

class VoiceListener extends StatefulWidget {
  @override
  _VoiceListenerState createState() => _VoiceListenerState();
}

class _VoiceListenerState extends State<VoiceListener> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts _tts = FlutterTts();

  bool _isRecording = false;
  String _status = "Initializing...";
  List<Map<String, String>> _results = [];

  /// ⏱ Record for 3 seconds
  static const Duration RECORD_TIME = Duration(seconds: 3);

  static const String API_URL =
      "http://127.0.0.1:5000/transcribe/voice/command";

  @override
  void initState() {
    super.initState();
    initRecorder();
    startLoop();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> initRecorder() async {
    await _recorder.openRecorder();

    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);

    setState(() => _status = "🎙 Ready");
  }

  Future<void> startLoop() async {
    if (_isRecording) return;

    _isRecording = true;
    setState(() => _status = "🎙 Listening...");

    Directory tempDir = await getTemporaryDirectory();
    String filePath = "${tempDir.path}/command.wav";

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    Timer(RECORD_TIME, () async {
      String? recordedPath = await _recorder.stopRecorder();
      _isRecording = false;

      setState(() => _status = "⏳ Processing...");

      if (recordedPath != null) {
        await sendAudio(recordedPath);
      }

      startLoop(); // 🔁 loop again
    });
  }

  Future<void> sendAudio(String path) async {
    try {
      var uri = Uri.parse(API_URL);
      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        String text = (data['text'] ?? '').toLowerCase().trim();
        String command;

        /// ✅ ONLY ACCEPT "start"
        if (text.startsWith("start")) {
          command = "START (correct)";
          _tts.speak("Correct command. Start detected");
          setState(() => _status = "✅ Correct Command: START");
        } else {
          command = "WRONG";
          _tts.speak("Wrong command");
          setState(() => _status = "❌ Wrong Command");
        }

        setState(() {
          _results.insert(0, {
            "text": text,
            "command": command,
          });
        });
      } else {
        setState(() => _status = "⚠️ Backend error");
      }
    } catch (e) {
      setState(() => _status = "⚠️ Processing error");
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  var r = _results[index];
                  bool isCorrect = r['command']!.contains("START");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🎤 Text: ${r['text']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          isCorrect
                              ? "✅ Correct Command: START"
                              : "❌ Wrong Command",
                          style: TextStyle(
                            color:
                                isCorrect ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


