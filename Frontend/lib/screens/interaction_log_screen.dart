import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api.dart';

class InteractionLogScreen extends StatefulWidget {
  final int assistantId;

  const InteractionLogScreen({Key? key, required this.assistantId})
      : super(key: key);

  @override
  _InteractionLogScreenState createState() => _InteractionLogScreenState();
}

class _InteractionLogScreenState extends State<InteractionLogScreen> {
  bool loading = true;
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final res = await http.post(
        Uri.parse(Api.getInteractionLogs(widget.assistantId)),
      );

      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(res.body));
        setState(() {
          logs = data;
        });
      } else {
        print("❌ Error: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      print("❌ Exception fetching logs: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /// Handles showing either server image or logo
  Widget buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset(
        "assets/ignore.jpeg", // logo here
        width: 55,
        height: 55,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      "${Api.baseUrl}/$path",
      width: 55,
      height: 55,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/Image.jpg", // fallback logo
          width: 55,
          height: 55,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget logCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: buildImage(item['image_path']),
        ),
        title: Text(
          "Q: ${item['question']}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A: ${item['answer']}"),
            const SizedBox(height: 4),
            Text(
              "⏱ ${item['created_at']}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
         iconTheme: const IconThemeData(
        color: Colors.white, // back arrow color
        ),
        title: const Text("Interaction Log",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        backgroundColor: Colors.blue[800],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Image.asset("assets/Image.jpg", width: 60, height: 60),
                const SizedBox(height: 8),
                const Text(
                  "Interaction Log",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212121),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: logs.isEmpty
                        ? const Center(
                            child: Text(
                              "No interaction logs found",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView(
                            children: logs.map((l) => logCard(l)).toList(),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
