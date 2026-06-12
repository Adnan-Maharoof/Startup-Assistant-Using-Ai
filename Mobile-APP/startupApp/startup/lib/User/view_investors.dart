import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Investor/chat_with_user.dart';

class ViewInvestors extends StatelessWidget {
  const ViewInvestors({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Investors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const ViewInvestorsPage(title: 'All Investors'),
    );
  }
}

class ViewInvestorsPage extends StatefulWidget {
  const ViewInvestorsPage({super.key, required this.title});
  final String title;

  @override
  State<ViewInvestorsPage> createState() => _ViewInvestorsPageState();
}

class _ViewInvestorsPageState extends State<ViewInvestorsPage> {
  List<Map<String, dynamic>> investors = [];

  @override
  void initState() {
    super.initState();
    viewInvestors();
  }

  Future<void> viewInvestors() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String url = "$ip/view_company/";

      print("Requesting: $url");
      var response = await http.post(Uri.parse(url));
      var jsondata = json.decode(response.body);

      if (jsondata['status'] == "ok") {
        List data = jsondata["data"];

        setState(() {
          investors = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Error fetching investors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View All Investors"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: investors.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: investors.length,
        itemBuilder: (BuildContext context, int index) {
          var investor = investors[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------------------- IMAGE -----------------------------
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    child: Image.network(
                      investor['image'] ?? '',
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 240,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------------- INFORMATION ---------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoRow("Name", investor['name']),
                        infoRow("Email", investor['email']),
                        infoRow("Phone", investor['contact']),
                        infoRow("Bio", investor['bio']),
                        infoRow("Company", investor['company_name']),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // -------------------------------- CHAT BUTTON ---------------------
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                          prefs.setString("investor_id",
                              investor['id'].toString());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                startupId:
                                investor['LOGIN'].toString(),
                                startupName: investor['name'],
                                startupPhotoUrl: investor['image'],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text("Chat Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "",
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
