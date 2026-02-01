import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_person_screen.dart';
import 'interaction_log_screen.dart';
import '../services/api.dart';

class AssistantHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AssistantHomeScreen({super.key, required this.user});

  @override
  State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends State<AssistantHomeScreen> {
  List<dynamic> contacts = [];
  List<dynamic> blinds = [];
  bool _loading = true;
  bool _loadingBlinds = true;

  Future<void> _fetchContacts() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
          Uri.parse(Api.getContactsWithPics(widget.user['id'])));
      if (response.statusCode == 200) {
        setState(() {
          contacts = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load contacts")),
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

  Future<void> _fetchBlinds() async {
    setState(() => _loadingBlinds = true);
    try {
      final response = await http.get(
          Uri.parse(Api.getBlindsByAssistant(widget.user['id'])),);
      if (response.statusCode == 200) {
        setState(() {
          blinds = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load blinds")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loadingBlinds = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _fetchBlinds();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Assistant Dashboard",
        style: TextStyle(
        color: Colors.white,       
        fontWeight: FontWeight.bold 
        ),),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assistant & Blind Info Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Assistant",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 6),
                        Text(user["name"] ?? "N/A"),
                        Text("Age: ${user["age"] ?? "N/A"}"),
                        Text("Gender: ${user["gender"] ?? "N/A"}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _loadingBlinds
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : blinds.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Blind",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                  const SizedBox(height: 6),
                                  Text(blinds[0]["name"] ?? "N/A"),
                                  Text("ID: ${blinds[0]["id"]}"),
                                  Text("Age: ${blinds[0]["age"] ?? "N/A"}"),
                                  Text(
                                      "Gender: ${blinds[0]["gender"] ?? "N/A"}"),
                                ],
                              )
                            : const Text("No Blind Assigned"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : contacts.isEmpty
                      ? const Center(child: Text("No contacts found"))
                      : ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            final picList = contact["pics"] ?? [];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  picList.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            "${Api.baseUrl}/static/ContactPics/${picList[0]['pic_path'].split('\\').last.split('/').last}",
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.contacts,
                                          size: 60, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact["name"] ?? "Unknown",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Relation: ${contact["relation"] ?? "N/A"}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Age: ${contact["age"] ?? "N/A"} | Gender: ${contact["gender"] ?? "N/A"}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPersonScreen(blindId: user["id"]),
                  ),
                ).then((_) => _fetchContacts());
              },
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                "Add Person",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InteractionLogScreen(assistantId: user["id"]),
                  ),
                );
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                "Interaction Log",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'add_person_screen.dart';
// import 'interaction_log_screen.dart';
// import '../services/api.dart';

// class AssistantHomeScreen extends StatefulWidget {
//   final Map<String, dynamic> user;

//   const AssistantHomeScreen({super.key, required this.user});

//   @override
//   State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
// }

// class _AssistantHomeScreenState extends State<AssistantHomeScreen> {
//   List<dynamic> contacts = [];
//   bool _loading = true;

//   Future<void> _fetchContacts() async {
//     setState(() => _loading = true);
//     try {
//       final response = await http.get(
//         Uri.parse(Api.getContactsWithPics(widget.user['id'])));
//       ;
//       if (response.statusCode == 200) {
//         setState(() {
//           contacts = json.decode(response.body);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to load contacts")),
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
//   void initState() {
//     super.initState();
//     _fetchContacts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = widget.user;

//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         title: const Text("Assistant Dashboard"),
//         backgroundColor: Colors.blue.shade700,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.red),
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, "/login");
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Welcome, ${user["name"]}",
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text("ID: ${user["id"]}"),
//             Text("Age: ${user["age"]}"),
//             Text("Gender: ${user["gender"]}"),
//             const SizedBox(height: 30),

//             Expanded(
//               child: _loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : contacts.isEmpty
//                       ? const Center(child: Text("No contacts found"))
//                       : ListView.builder(
//                           itemCount: contacts.length,
//                           itemBuilder: (context, index) {
//                             final contact = contacts[index];
//                             final picList = contact["pics"] ?? [];

//                             return Container(
//                               margin: const EdgeInsets.symmetric(vertical: 6),
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   picList.isNotEmpty
//                                       ? ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           child: Image.network(
//                                             "${Api.baseUrl}/${picList[0]['pic_path']}",
//                                             width: 60,
//                                             height: 60,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         )
//                                       : const Icon(Icons.contacts,
//                                           size: 60, color: Colors.blue),
//                                   const SizedBox(width: 12),

//                                   // Expanded text section to prevent overflow
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           contact["name"] ?? "Unknown",
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "Relation: ${contact["relation"] ?? "N/A"}",
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black87,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         Text(
//                                           "Age: ${contact["age"] ?? "N/A"} | Gender: ${contact["gender"] ?? "N/A"}",
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black54,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//             ),

//             const SizedBox(height: 20),

//             // Action Buttons styled 
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         AddPersonScreen(blindId: user["id"]),
//                   ),
//                 ).then((_) => _fetchContacts());
//               },
//               icon: const Icon(Icons.person_add, color: Colors.white),
//               label: const Text("Add Person",
//               style: TextStyle(color: Colors.white),),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         InteractionLogScreen(assistantId: user["id"]),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.history, color: Colors.white),
//               label: const Text("Interaction Log",
//               style: TextStyle(color: Colors.white),),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


