import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Homepage.dart';
import 'send_doubt.dart';

class view_doubt extends StatefulWidget {
  @override
  _view_doubtState createState() => _view_doubtState();
}

class _view_doubtState extends State<view_doubt> {
  List<String> id_ = [];
  List<String> date_ = [];
  List<String> reply_ = [];
  List<String> feedback_ = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid").toString();
      String ip = pref.getString("url").toString();

      String url = "$ip/doubt_View_user/";
      var response = await http.post(Uri.parse(url), body: {'lid': lid});

      print("SERVER RESPONSE: ${response.body}");

      var jsondata = json.decode(response.body);

      if (jsondata['status'] == "ok") {
        var arr = jsondata["data"];

        setState(() {
          id_ = arr.map<String>((e) => e['id'].toString()).toList();
          date_ = arr.map<String>((e) => e['date'].toString()).toList();
          reply_ = arr.map<String>((e) => e['reply'].toString()).toList();
          feedback_ = arr.map<String>((e) => e['feedback'].toString()).toList();
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Doubts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),

      body: Container(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: feedback_.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF3F4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          date_[index],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Your Doubt:",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    Text(
                      feedback_[index],
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Expert Reply:",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                    Text(
                      reply_[index],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            label: 'New Doubt',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => UserHomepage()));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => send_doubt()),
            );
          }
        },
      ),
    );
  }
}


class send_doubt extends StatefulWidget {
  @override
  _send_doubtState createState() => _send_doubtState();
}

class _send_doubtState extends State<send_doubt> {
  final TextEditingController _doubtController = TextEditingController();

  @override
  void dispose() {
    _doubtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask a Doubt",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),

        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your doubt",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _doubtController,
                  decoration: InputDecoration(
                    hintText: "Type your doubt here...",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: () async {
                    final sh = await SharedPreferences.getInstance();
                    String doubt = _doubtController.text.trim();
                    String url = sh.getString("url").toString();
                    String lid = sh.getString("lid").toString();
                    String Eid = sh.getString("Eid").toString();

                    if (doubt.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter your doubt")),
                      );
                      return;
                    }

                    var data = await http.post(
                      Uri.parse('$url/send_doubt_user/'),
                      body: {
                        'doubt': doubt,
                        'lid': lid,
                        'Eid': Eid,
                      },
                    );

                    var jsondata = json.decode(data.body);

                    if (jsondata['status'] == "ok") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => view_doubt()));
                    }
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
