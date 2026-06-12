import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

void main() {
  runApp(const MyChangePassword());
}

class MyChangePassword extends StatelessWidget {
  const MyChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChangePassword',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
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
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    oldpasswordController.dispose();
    newpasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),

                  // Header Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 50,
                      color: Color(0xFF6366F1),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Secure Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create a strong password to keep your account safe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Old Password Field
                  _buildPasswordField(
                    controller: oldpasswordController,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    obscureText: _obscureOld,
                    onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                    prefixIcon: Icons.lock_outline_rounded,
                  ),

                  const SizedBox(height: 20),

                  // New Password Field
                  _buildPasswordField(
                    controller: newpasswordController,
                    label: 'New Password',
                    hint: 'Enter your new password',
                    obscureText: _obscureNew,
                    onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                    prefixIcon: Icons.vpn_key_rounded,
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter your new password',
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    prefixIcon: Icons.check_circle_outline_rounded,
                  ),

                  const SizedBox(height: 32),

                  // Change Password Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use a mix of letters, numbers, and symbols for a stronger password',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              height: 1.4,
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
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleChangePassword() async {
    String oldp = oldpasswordController.text.trim();
    String newp = newpasswordController.text.trim();
    String confirmp = confirmPasswordController.text.trim();

    if (oldp.isEmpty || newp.isEmpty || confirmp.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required",
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    if (newp != confirmp) {
      Fluttertoast.showToast(
        msg: "New password & confirm password don't match",
        backgroundColor: Colors.orange.shade400,
      );
      return;
    }

    if (oldp == newp) {
      Fluttertoast.showToast(
        msg: "New password must be different from old one",
        backgroundColor: Colors.orange.shade400,
      );
      return;
    }

    if (newp.length < 6) {
      Fluttertoast.showToast(
        msg: "Password must be at least 6 characters",
        backgroundColor: Colors.orange.shade400,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();

      final urls = Uri.parse('$url/change_passwordpost_company/');
      final response = await http.post(urls, body: {
        'oldpassword': oldp,
        'newpassword': newp,
        'confirmpassword': confirmp,
        'lid': lid,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(
            msg: 'Password Changed Successfully',
            backgroundColor: Colors.green.shade400,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Loginpage()),
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Incorrect Password',
            backgroundColor: Colors.red.shade400,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Network Error',
          backgroundColor: Colors.red.shade400,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red.shade400,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}