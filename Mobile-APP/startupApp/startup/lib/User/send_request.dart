import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';

class send_request extends StatefulWidget {
  const send_request({super.key});

  @override
  State<send_request> createState() => _send_requestState();
}

class _send_requestState extends State<send_request> {
  // TextEditingController expertC = TextEditingController();
  // TextEditingController dateC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Request"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              // controller: expertC,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Expert ID"),
            ),
            const SizedBox(height: 20),

            TextFormField(
              // controller: dateC,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Date (YYYY-MM-DD)"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                // String expert = expertC.text.trim();
                // String date = dateC.text.trim();

                final sh = await SharedPreferences.getInstance();
                String url = sh.getString("url").toString();
                String lid = sh.getString("lid").toString(); // logged in user ID

                try {
                  var uri = Uri.parse('$url/send_request_user/'); // FIXED ENDPOINT

                  var request = http.MultipartRequest('POST', uri);

                  // request.fields['expert'] = expert;
                  // request.fields['date'] = date;
                  request.fields['lid'] = lid; // send USER id to Django

                  var response = await request.send();

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Request Sent")),
                    );

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => Loginpage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Failed: ${response.statusCode} – ${response.reasonPhrase}")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Send", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
