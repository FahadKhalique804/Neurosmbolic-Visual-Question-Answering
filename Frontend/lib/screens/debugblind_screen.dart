import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vad/vad.dart';

import '../services/api.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _blindIdController = TextEditingController();

  File? _selectedImage;
  String? _answer;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  // 🎤 STT
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _audioPath;
  bool isListening = false;

  // 🔊 TTS
  final FlutterTts _tts = FlutterTts();

  // 🧠 VAD
  late VadHandler _vad;
  Timer? silenceTimer;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initTTS();
    _initVAD();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
  }

  void _initVAD() {
    _vad = VadHandler.create(isDebug: true);

    _vad.onSpeechStart.listen((_) {
      silenceTimer?.cancel();
    });

    _vad.onSpeechEnd.listen((_) {
      silenceTimer?.cancel();
      silenceTimer = Timer(const Duration(seconds: 3), () async {
        await _stopListening();
        await _stopRecordingAndTranscribe();
      });
    });
  }

  // ---------------- IMAGE ----------------
  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
    }
  }

  Future<void> _takePhoto() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
    }
  }

  // ---------------- RECORD BUTTON FLOW ----------------
  Future<void> _startRecordingFlow() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    final dir = await getTemporaryDirectory();
    _audioPath = "${dir.path}/debug_audio.m4a";

    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: Codec.aacMP4,
    );

    await _vad.startListening();
    setState(() => isListening = true);
  }

  Future<void> _stopListening() async {
    if (isListening) {
      await _vad.stopListening();
      setState(() => isListening = false);
    }
  }

  Future<void> _stopRecordingAndTranscribe() async {
    await _recorder.stopRecorder();
    if (_audioPath == null) return;

    final req = http.MultipartRequest(
      "POST",
      Uri.parse(Api.sttTranscribe),
    );

    req.files.add(await http.MultipartFile.fromPath("audio", _audioPath!));
    final res = await req.send();

    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final text = json.decode(body)["text"];
      _questionController.text = text;
      await _askQuestion();
    }
  }

  // ---------------- Q/A ----------------
  Future<void> _askQuestion() async {
    if (_selectedImage == null || _questionController.text.isEmpty) return;

    final id = int.tryParse(_blindIdController.text);
    if (id == null) return;

    setState(() {
      _loading = true;
      _answer = null;
    });

    final req = http.MultipartRequest(
      "POST",
      Uri.parse(Api.getAnswerWithId(id)),
    );

    req.fields["question"] = _questionController.text;
    req.files.add(
      await http.MultipartFile.fromPath("image", _selectedImage!.path),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      _answer = json.decode(body)["answer"];
      await _tts.speak(_answer!);
    }

    setState(() => _loading = false);
  }

  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
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
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          "Debug Screen",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Image Display (Card Style) ---
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // --- Image Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text("Pick Image", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Take Photo", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Blind ID Field ---
            TextField(
              controller: _blindIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Blind ID",
                labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 15),

            // --- Question Field --
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: "Enter your question",
                labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                // Mic removed from here as requested
              ),
            ),
            const SizedBox(height: 20),

            // --- Ask Button ---
            ElevatedButton(
              onPressed: _askQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC83264),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "❓ Ask Question",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // 🎤 NEW RECORD BUTTON
            ElevatedButton.icon(
              onPressed: isListening ? null : _startRecordingFlow,
              icon: const Icon(Icons.mic),
              label: Text(isListening ? "Listening..." : "Record Question"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC83264),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.red.withOpacity(0.5),
                disabledForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const CircularProgressIndicator(color: Color(0xFF0D47A1)),
            
            // --- Answer Card ---
            if (_answer != null && !_loading)
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Answer: $_answer",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.w500,
                      ),
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
