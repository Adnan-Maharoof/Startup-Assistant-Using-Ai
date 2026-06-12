import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class View_notification extends StatelessWidget {
  const View_notification({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const View_notificationpagePage(title: 'Notifications'),
    );
  }
}

class View_notificationpagePage extends StatefulWidget {
  const View_notificationpagePage({super.key, required this.title});

  final String title;

  @override
  State<View_notificationpagePage> createState() =>
      _View_notificationpagePage();
}

class _View_notificationpagePage extends State<View_notificationpagePage> {
  List<String> cid_ = [];
  List<String> cnotification_ = [];
  List<String> cdetails_ = [];
  List<String> cdate_ = [];

  @override
  void initState() {
    super.initState();
    View_notification();
  }

  Future<void> View_notification() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String url = "$ip/view_notification_user/";

      var data = await http.post(Uri.parse(url));
      var jsondata = json.decode(data.body);

      var arr = jsondata["data"];

      List<String> cid = [];
      List<String> cnotification = [];
      List<String> cdetails = [];
      List<String> cdate = [];

      for (var item in arr) {
        cid.add(item['id'].toString());
        cnotification.add(item['notification'].toString());
        cdetails.add(item['details'].toString());
        cdate.add(item['date'].toString());
      }

      setState(() {
        cid_ = cid;
        cnotification_ = cnotification;
        cdetails_ = cdetails;
        cdate_ = cdate;
      });
    } catch (e) {
      print("Error ---- ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // ---------------- HEADER ----------------
        Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                "Notifications",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),

        // ---------------- LIST ----------------
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: cid_.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.notifications_active,
                                color: Colors.deepPurple, size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cnotification_[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(height: 10),
                          Text(
                            cdetails_[index],
                            style: TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(cdate_[index],
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
