import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminTrendingStartupPage extends StatefulWidget {
  const AdminTrendingStartupPage({super.key});

  @override
  State<AdminTrendingStartupPage> createState() =>
      _AdminTrendingStartupPageState();
}

class _AdminTrendingStartupPageState extends State<AdminTrendingStartupPage> {
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchAdminTrending();
  }

  Future<void> fetchAdminTrending() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString("url");

      if (url == null) {
        setState(() {
          errorMessage = "Server URL not found";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse("$url/NLP_trending_Admin_Startup/"), // Admin-only endpoint
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            recommendations =
            List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No admin startups available";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isLoading = false;
      });
    }
  }

  Widget buildRecommendationCard(Map<String, dynamic> item) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item['title'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              item['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            // Industry
            Row(
              children: [
                Chip(
                  label: Text(item['industry'] ?? ''),
                  backgroundColor: Colors.blue.shade50,
                ),
                const Spacer(),
                const Icon(Icons.trending_up, color: Colors.green),
              ],
            ),
            const Divider(),
            // User Info (admin)
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 6),
                Text(item['uname'] ?? ''),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 6),
                Text(item['uemail'] ?? ''),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 6),
                Text(item['uphone'] ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trending Admin Startups"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : recommendations.isEmpty
          ? const Center(child: Text("No admin startups available"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return buildRecommendationCard(recommendations[index]);
        },
      ),
    );
  }
}
