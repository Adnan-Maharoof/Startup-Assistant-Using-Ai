import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_profile.dart';

void main() {
  runApp(const ViewProfile());
}

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewProfilePage(title: 'My Profile'),
    );
  }
}

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key, required this.title});
  final String title;

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  String name_ = "";
  String email_ = "";
  String phone_ = "";
  String place_ = "";
  String post_ = "";
  String pin_ = "";
  String qualification_ = "";
  String skills_ = "";
  String interested_area_ = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? "";
      String lid = sh.getString('lid') ?? "";

      if (baseUrl.isEmpty || lid.isEmpty) {
        Fluttertoast.showToast(msg: "Missing configuration or login info");
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('$baseUrl/viewprofile_user/');
      final response = await http.post(url, body: {'lid': lid});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            name_ = data['name'] ?? '';
            email_ = data['email'] ?? '';
            phone_ = data['phone'] ?? '';
            place_ = data['place'] ?? '';
            post_ = data['post'] ?? '';
            pin_ = data['pin'] ?? '';
            qualification_ = data['qualification'] ?? '';
            skills_ = data['skills'] ?? '';
            interested_area_ = data['interested_area'] ?? '';
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: "Profile not found");
          setState(() => isLoading = false);
        }
      } else {
        Fluttertoast.showToast(msg: "Network error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ********** PROFILE HEADER **********
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white38,
                      child: const Icon(Icons.person, size: 65, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name_.isNotEmpty ? name_ : "User",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      email_,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ********** GLASS CARD **********
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _row("Phone", phone_, Icons.phone),
                          _divider(),
                          _row("Place", place_, Icons.place),
                          _divider(),
                          _row("Post", post_, Icons.location_city),
                          _divider(),
                          _row("Pin", pin_, Icons.push_pin),
                          _divider(),
                          _row("Qualification", qualification_, Icons.school),
                          _divider(),
                          _row("Skills", skills_, Icons.star),
                          _divider(),
                          _row("Interested Area", interested_area_, Icons.interests),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ********** EDIT BUTTON **********
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          update_profilePage(title: "Edit Profile"),
                    ),
                  ).then((_) => _fetchProfileData());
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 18, color: Colors.black26);

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label\n${value.isNotEmpty ? value : "Not available"}",
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
