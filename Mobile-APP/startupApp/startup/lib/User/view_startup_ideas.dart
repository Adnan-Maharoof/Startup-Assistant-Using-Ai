import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_startup.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ViewStartup extends StatelessWidget {
  const ViewStartup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View Startup Ideas',
      home: const ViewStartupPage(title: 'Startup Ideas'),
    );
  }
}

class ViewStartupPage extends StatefulWidget {
  final String title;
  const ViewStartupPage({super.key, required this.title});

  @override
  State<ViewStartupPage> createState() => _ViewStartupPageState();
}

class _ViewStartupPageState extends State<ViewStartupPage> {
  List<Map<String, String>> startupList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStartupData();
  }

  Future<void> fetchStartupData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString("url") ?? "";
      String lid = prefs.getString("lid") ?? "";

      if (baseUrl.isEmpty || lid.isEmpty) return;

      final response =
      await http.post(Uri.parse("$baseUrl/view_startup_user/"), body: {'lid': lid});

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData["status"] == "ok") {
          List data = jsonData["data"];
          List<Map<String, String>> temp = [];

          for (var item in data) {
            temp.add({
              "id": item["id"].toString(),
              "title": item["title"].toString(),
              "description": item["description"].toString(),
              "industry": item["industry"].toString(),
            });
          }

          setState(() => startupList = temp);
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _deleteStartup(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString("url") ?? "";
      if (baseUrl.isEmpty) return;

      final response =
      await http.post(Uri.parse("$baseUrl/delete_startup_Post/"), body: {'id': id});

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          Fluttertoast.showToast(msg: "Startup deleted successfully");
          fetchStartupData();
        } else {
          Fluttertoast.showToast(msg: "Failed to delete startup");
        }
      } else {
        Fluttertoast.showToast(msg: "Network error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : startupList.isEmpty
          ? const Center(
        child: Text(
          "No startup ideas found.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : RefreshIndicator(
            onRefresh: fetchStartupData,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: startupList.length,
              itemBuilder: (context, index) {
                final startup = startupList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup["title"] ?? "",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          startup["description"] ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.business,
                                size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 6),
                            Text(
                              startup["industry"] ?? "",
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete this startup?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _deleteStartup(startup["id"] ?? "");
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStartupPage()),
          );
          fetchStartupData();
        },
      ),
    );
  }
}
