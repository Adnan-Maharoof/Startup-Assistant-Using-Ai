import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_profile.dart';

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
  String bio_ = "";
  String company_ = "";
  String photo_ = "";
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
      String imgBaseUrl = sh.getString("imgurl") ?? "";

      final urls = Uri.parse('$baseUrl/viewprofile/');
      final response = await http.post(urls, body: {'lid': lid});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          setState(() {
            name_ = data['name'] ?? '';
            email_ = data['email'] ?? '';
            phone_ = data['phone'] ?? '';
            bio_ = data['bio'] ?? '';
            company_ = data['company_name'] ?? '';

            // ---------- FIX: Force image refresh ----------
            String imagePath = data['photo'] ?? data['image'] ?? '';

            if (imagePath.isNotEmpty) {
              String fullUrl;

              if (imagePath.startsWith('http')) {
                fullUrl = imagePath;
              } else {
                fullUrl = imgBaseUrl.isNotEmpty
                    ? '$imgBaseUrl$imagePath'
                    : '$baseUrl$imagePath';
              }

              // Add timestamp to bypass cache 🔥
              photo_ = "$fullUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}";
            } else {
              photo_ = '';
            }
            // ------------------------------------------------

            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: 'Profile Not Found');
          setState(() => isLoading = false);
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
        setState(() => isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading ? _buildLoadingState() : _buildProfileContent(),
          ),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 35),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF2563EB),
            Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "My Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdateProfilePage(title: "Edit Profile"),
                ),
              ).then((_) => _fetchProfileData());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.deepPurple),
    );
  }

  // Main profile content
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildAvatarCard(),
          const SizedBox(height: 20),
          _buildGlassInfoCard(),
        ],
      ),
    );
  }

  // Profile image card
  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white,
            backgroundImage: photo_.isNotEmpty
                ? NetworkImage(photo_)
                : const AssetImage('assets/default_avatar.png')
            as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            name_.isNotEmpty ? name_ : "Loading...",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            company_.isNotEmpty ? company_ : "Company not set",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Info card
  Widget _buildGlassInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle("Personal Information"),
          _infoRow(Icons.email, "Email", email_),
          _infoRow(Icons.phone, "Phone", phone_),
          _infoRow(Icons.info, "Bio", bio_),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.person_pin_circle,
              color: Color(0xFF4F46E5), size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Not available",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
