import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'Homepage.dart';

class complaint extends StatefulWidget {
  @override
  _complaintState createState() => _complaintState();
}

class _complaintState extends State<complaint> {
  List<String> ccid_ = <String>[];
  List<String> date_ = <String>[];
  List<String> reply_ = <String>[];
  List<String> complaint_ = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    List<String> ccid = <String>[];
    List<String> date = <String>[];
    List<String> reply = <String>[];
    List<String> complaint = <String>[];

    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid").toString();
      String ip = pref.getString("url").toString();

      String url = ip + "/complaintViewflutter/";
      var data = await http.post(Uri.parse(url), body: {'lid': lid});

      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];

      for (int i = 0; i < arr.length; i++) {
        ccid.add(arr[i]['id'].toString());
        date.add(arr[i]['date'].toString());
        reply.add(arr[i]['reply'].toString());
        complaint.add(arr[i]['complaint'].toString());
      }

      setState(() {
        ccid_ = ccid;
        date_ = date;
        reply_ = reply;
        complaint_ = complaint;
      });
    } catch (e) {
      print("Error " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: WillPopScope(
        onWillPop: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserHomepage()));
          return Future.value(false);
        },

        child: Container(
          padding: EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: ccid_.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: Colors.purpleAccent.withOpacity(0.4),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("📅 Date", date_[index]),
                      SizedBox(height: 10),
                      _buildRow("📝 Complaint", complaint_[index]),
                      SizedBox(height: 10),
                      _buildRow("✅ Reply", reply_[index] == "pending"
                          ? "Not Yet Replied"
                          : reply_[index]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "New Complaint"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomepage()));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NewComplaintPage()));
          }
        },
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title : ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        )
      ],
    );
  }
}

// ------------------------------------------------------
//           NEW COMPLAINT PAGE (STYLED)
// ------------------------------------------------------

class NewComplaintPage extends StatefulWidget {
  @override
  _NewComplaintPageState createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Complaint"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _styledTextField(),

              SizedBox(height: 18),

              _styledButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledTextField() {
    return TextFormField(
      controller: _complaintController,
      maxLines: 3,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Enter your complaint...",
        labelText: "Complaint",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        prefixIcon: Icon(Icons.report_problem, color: Colors.purple),
      ),
      validator: (value) =>
      value!.isEmpty ? "Please enter your complaint" : null,
    );
  }

  Widget _styledButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.purple,
        ),
        child: Text(
          "Submit Complaint",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final sh = await SharedPreferences.getInstance();
          String complaint = _complaintController.text.trim();
          String url = sh.getString("url").toString();
          String lid = sh.getString("lid").toString();

          var data = await http.post(
            Uri.parse(url + "/send_complaint_user/"),
            body: {'complaint': complaint, 'lid': lid},
          );

          var jsondata = json.decode(data.body);
          if (jsondata['status'] == "ok") {
            Fluttertoast.showToast(
              msg: "Complaint Sent!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomepage()));
          }
        },
      ),
    );
  }
}
