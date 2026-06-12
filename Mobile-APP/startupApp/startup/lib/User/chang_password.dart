import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class MyChangePassword extends StatelessWidget {
  const MyChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Change Password',
      theme: ThemeData(useMaterial3: true),
      home: const MyChangePasswordPage(title: 'Change Password'),
    );
  }
}

class MyChangePasswordPage extends StatefulWidget {
  const MyChangePasswordPage({super.key, required this.title});

  final String title;

  @override
  State<MyChangePasswordPage> createState() => _MyChangePasswordPageState();
}

class _MyChangePasswordPageState extends State<MyChangePasswordPage> {
  final TextEditingController oldpasswordController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ---------------- CARD CONTAINER ----------------
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    customTextField(
                      controller: oldpasswordController,
                      label: "Old Password",
                    ),
                    const SizedBox(height: 15),
                    customTextField(
                      controller: newpasswordController,
                      label: "New Password",
                    ),
                    const SizedBox(height: 15),
                    customTextField(
                      controller: confirmPasswordController,
                      label: "Confirm Password",
                    ),
                    const SizedBox(height: 30),

                    // ---------------- BUTTON ----------------
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: changePassword,
                        child: const Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- MODERN TEXTFIELD ----------------
  Widget customTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }

  // ---------------- CHANGE PASSWORD FUNCTION ----------------
  Future<void> changePassword() async {
    String oldp = oldpasswordController.text.trim();
    String newp = newpasswordController.text.trim();
    String confirmp = confirmPasswordController.text.trim();

    if (oldp.isEmpty || newp.isEmpty || confirmp.isEmpty) {
      Fluttertoast.showToast(msg: "All fields are required");
      return;
    }

    if (newp != confirmp) {
      Fluttertoast.showToast(msg: "New password & confirm password don't match");
      return;
    }

    if (oldp == newp) {
      Fluttertoast.showToast(msg: "New password must be different from old one");
      return;
    }

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();

      final urls = Uri.parse('$url/change_passwordpost_user/');
      final response = await http.post(urls, body: {
        'oldpassword': oldp,
        'newpassword': newp,
        'confirmpassword': confirmp,
        'lid': lid,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Password Changed Successfully');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Loginpage()),
          );
        } else {
          Fluttertoast.showToast(msg: 'Incorrect Password');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
