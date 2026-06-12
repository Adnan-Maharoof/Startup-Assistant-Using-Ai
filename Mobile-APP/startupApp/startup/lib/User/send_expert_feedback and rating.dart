import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class expertfeedback extends StatefulWidget {
  @override
  _expertfeedbackState createState() => _expertfeedbackState();
}

class _expertfeedbackState extends State<expertfeedback> {
  final TextEditingController _feedbackController = TextEditingController();
  double rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() => rating = index.toDouble());
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(4),
        child: Icon(
          index <= rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: index <= rating ? 40 : 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),

      appBar: AppBar(
        title: const Text(
          "Submit Feedback",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.indigo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // ⭐ FEEDBACK CARD
            Card(
              elevation: 8,
              shadowColor: Colors.indigo.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Rate the Expert",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 14),

                    // ⭐⭐⭐⭐⭐ Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildStar(1),
                        buildStar(2),
                        buildStar(3),
                        buildStar(4),
                        buildStar(5),
                      ],
                    ),

                    SizedBox(height: 20),

                    // FEEDBACK TEXTFIELD
                    TextField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: "Write your feedback...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      maxLines: 4,
                    ),

                    SizedBox(height: 20),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final sh = await SharedPreferences.getInstance();
                          String feedback = _feedbackController.text.trim();
                          String url = sh.getString("url").toString();
                          String lid = sh.getString("lid").toString();
                          String Eid = sh.getString("Eid").toString();

                          if (feedback.isEmpty || rating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please enter feedback + rating")),
                            );
                            return;
                          }

                          var data = await http.post(
                            Uri.parse('$url/send_expert_feedback/'),
                            body: {
                              'feedback': feedback,
                              'lid': lid,
                              'Eid': Eid,
                              'rating': rating.toString(),
                            },
                          );

                          var jsondata = json.decode(data.body);
                          if (jsondata['status'] == "ok") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserHomepage()),
                            );
                          }
                        },

                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            "Submit Feedback",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
