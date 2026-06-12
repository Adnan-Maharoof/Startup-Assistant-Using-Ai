// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class GeminiChatPage extends StatefulWidget {
//   @override
//   State<GeminiChatPage> createState() => _GeminiChatPageState();
// }
//
// class _GeminiChatPageState extends State<GeminiChatPage> {
//   final TextEditingController questionController = TextEditingController();
//   String responseText = "";
//   bool loading = false;
//   String serverIp = "";
//
//   @override
//   void initState() {
//     super.initState();
//     loadServerIp();
//   }
//
//   Future<void> loadServerIp() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       serverIp = prefs.getString("url").toString() ?? "";
//     });
//   }
//
//   Future<void> sendQuestion() async {
//     if (serverIp.isEmpty) {
//       showSnack("Server IP not set");
//       return;
//     }
//
//     setState(() {
//       loading = true;
//       responseText = "";
//     });
//
//     final url = Uri.parse("$serverIp/gemini/");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"question": questionController.text}),
//       );
//
//       final data = jsonDecode(response.body);
//
//       setState(() {
//         responseText = data["answer"] ?? "No response";
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         responseText = "Error: $e";
//         loading = false;
//       });
//     }
//   }
//
//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: Text("Gemini Assistant"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           /// 💬 Chat Area
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 10,
//                       color: Colors.black12,
//                     )
//                   ],
//                 ),
//                 child: loading
//                     ? Center(child: CircularProgressIndicator())
//                     : responseText.isEmpty
//                     ? Center(
//                   child: Text(
//                     "Ask something to Gemini 🤖",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//                     : SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     responseText,
//                     style: TextStyle(
//                       fontSize: 16,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           /// ✏️ Input Area
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: questionController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: "Type your question...",
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.deepPurple,
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: loading ? null : sendQuestion,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "message": message});
    });
    _controller.clear();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString('url'); // Ensure 'url' is set in SharedPreferences

      if (url == null) {
        Fluttertoast.showToast(msg: "API URL not configured.");
        return;
      }

      final response = await http.post(
        Uri.parse('$url/gemini/'),  // 🔥 Ensure this matches Django's endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('response')) {
          setState(() {
            _messages.add({"role": "bot", "message": data['response']});
          });
        } else {
          setState(() {
            _messages.add({
              "role": "bot",
              "message": "Unexpected response format."
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "Error: ${response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "message": "Failed to connect to server. Check your internet."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

