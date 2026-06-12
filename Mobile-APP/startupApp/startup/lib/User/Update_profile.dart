import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class update_profile extends StatelessWidget {
  const update_profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const update_profilePage(title: 'Update Profile'),
    );
  }
}

class update_profilePage extends StatefulWidget {
  const update_profilePage({super.key, required this.title});
  final String title;

  @override
  State<update_profilePage> createState() => _update_profilePageState();
}

class _update_profilePageState extends State<update_profilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController interested_areaController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? "";
      String lid = sh.getString('lid') ?? "";

      final response = await http.post(
        Uri.parse('$baseUrl/viewprofile_user/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phone'] ?? '';
            placeController.text = data['place'] ?? '';
            postController.text = data['post'] ?? '';
            pinController.text = data['pin'] ?? '';
            qualificationController.text = data['qualification'] ?? '';
            skillsController.text = data['skills'] ?? '';
            interested_areaController.text = data['interested_area'] ?? '';
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: 'Profile not found');
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

  Future<void> _sendData() async {
    String uname = nameController.text.trim();
    String email = emailController.text.trim();

    if (uname.isEmpty || email.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all required fields');
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? "";
    String lid = sh.getString('lid') ?? "";

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updateprofile_user/'),
        body: {
          'lid': lid,
          'name': uname,
          'email': email,
          'phone': phoneController.text.trim(),
          'place': placeController.text.trim(),
          'post': postController.text.trim(),
          'pin': pinController.text.trim(),
          'qualification': qualificationController.text.trim(),
          'skills': skillsController.text.trim(),
          'interested_area': interested_areaController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Profile updated successfully');

          Navigator.pop(context, true);
          return;
        } else {
          Fluttertoast.showToast(msg: 'Update failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Form card container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildInput(nameController, "Name", Icons.person),
                  _buildInput(emailController, "Email", Icons.email),
                  _buildInput(phoneController, "Phone", Icons.phone),
                  _buildInput(placeController, "Place", Icons.location_on),
                  _buildInput(postController, "Post", Icons.home),
                  _buildInput(pinController, "Pin Code", Icons.pin),
                  _buildInput(qualificationController, "Qualification",
                      Icons.school),
                  _buildInput(
                      skillsController, "Skills", Icons.star_outline),
                  _buildInput(interested_areaController,
                      "Interested Area", Icons.work_outline),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Gradient Save Button
            InkWell(
              onTap: _sendData,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
