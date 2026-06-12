import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startup/User/send_doubt.dart';
import 'send_expert_feedback and rating.dart';

class view_expert extends StatelessWidget {
  const view_expert({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const view_expertpagePage(title: 'Experts'),
    );
  }
}

class view_expertpagePage extends StatefulWidget {
  final String title;

  const view_expertpagePage({super.key, required this.title});

  @override
  State<view_expertpagePage> createState() => _view_expertpagePage();
}

class _view_expertpagePage extends State<view_expertpagePage> {
  List<String> cid_ = [];
  List<String> cname_ = [];
  List<String> cemail_ = [];
  List<String> ccontact_ = [];
  List<String> cqualification_ = [];
  List<String> cexperience_ = [];

  @override
  void initState() {
    super.initState();
    view_expert();
  }

  Future<void> view_expert() async {
    List<String> cid = [];
    List<String> cname = [];
    List<String> cemail = [];
    List<String> ccontact = [];
    List<String> cqualification = [];
    List<String> cexperience = [];

    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();

      String url = ip + "/view_expert/";
      var data = await http.post(Uri.parse(url), body: {});
      var jsondata = json.decode(data.body);

      var arr = jsondata["data"];

      for (int i = 0; i < arr.length; i++) {
        cid.add(arr[i]['id'].toString());
        cname.add(arr[i]['name'].toString());
        cemail.add(arr[i]['email'].toString());
        ccontact.add(arr[i]['contact'].toString());
        cqualification.add(arr[i]['qualification'].toString());
        cexperience.add(arr[i]['experience'].toString());
      }

      setState(() {
        cid_ = cid;
        cname_ = cname;
        cemail_ = cemail;
        ccontact_ = ccontact;
        cqualification_ = cqualification;
        cexperience_ = cexperience;
      });
    } catch (e) {
      print("Error: " + e.toString());
    }
  }

  // ✨ Beautiful Info Row Widget
  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),

      appBar: AppBar(
        title: const Text(
          "Experts",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),

      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: cid_.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            elevation: 7,
            shadowColor: Colors.indigo.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.only(bottom: 20),

            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ⭐ Name Header
                  Center(
                    child: Text(
                      cname_[index],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  infoRow("Email", cemail_[index]),
                  infoRow("Contact", ccontact_[index]),
                  infoRow("Qualification", cqualification_[index]),
                  infoRow("Experience", cexperience_[index]),

                  const SizedBox(height: 18),

                  // ⭐ Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // FEEDBACK BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            SharedPreferences pref =
                            await SharedPreferences.getInstance();
                            pref.setString("Eid", cid_[index]);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => expertfeedback(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.star_rate),
                          label: const Text("Feedback"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // DOUBT BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            SharedPreferences pref =
                            await SharedPreferences.getInstance();
                            pref.setString("Eid", cid_[index]);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => view_doubt(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.help_outline),
                          label: const Text("Ask Doubt"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
