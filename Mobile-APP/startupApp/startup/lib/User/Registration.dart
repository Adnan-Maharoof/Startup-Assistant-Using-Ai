import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatefulWidget {
  const myApp({super.key});

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: registration_user(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class registration_user extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

   registration_user({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<registration_user> createState() => _registration_userState();
}

class _registration_userState extends State<registration_user> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController placeC = TextEditingController();
  TextEditingController postC = TextEditingController();
  TextEditingController pinC = TextEditingController();
  TextEditingController qualificationC = TextEditingController();
  TextEditingController skillsC = TextEditingController();
  TextEditingController interested_areaC = TextEditingController();
  TextEditingController UsernameC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  bool _isLoading = false;

  // Theme-aware colors
  Color get backgroundColor1 => widget.isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFFFF4E6);
  Color get backgroundColor2 => widget.isDarkMode ? const Color(0xFF16213E) : const Color(0xFFE3F2FD);
  Color get circleColor => widget.isDarkMode ? const Color(0xFF0F3460).withOpacity(0.3) : const Color(0xFFFFE0B2).withOpacity(0.3);
  Color get cardColor => widget.isDarkMode ? const Color(0xFF2D3748) : Colors.white;
  Color get textColor => widget.isDarkMode ? Colors.white : const Color(0xFF424242);
  Color get labelColor => widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF757575);
  Color get inputFillColor => widget.isDarkMode ? const Color(0xFF374151) : const Color(0xFFF5F5F5);
  Color get iconColor => widget.isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF90A4AE);
  Color get primaryColor => widget.isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF42A5F5);

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor1, backgroundColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar with Theme Toggle
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "User Registration",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      // Theme Toggle Button
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: textColor,
                          ),
                          onPressed: widget.onThemeToggle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Personal Information Section
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: nameC,
                            label: "Full Name",
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Name is required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: emailC,
                            label: "Email Address",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Email is required";
                              String pattern = r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$";
                              if (!RegExp(pattern).hasMatch(value))
                                return "Enter a valid email";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: phoneC,
                            label: "Phone Number",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Phone number required";
                              if (!RegExp(r'^\d{10}$').hasMatch(value))
                                return "Enter 10-digit valid phone number";
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Address Section
                          Text(
                            "Address Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: placeC,
                            label: "Place",
                            icon: Icons.location_city_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Place is required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: postC,
                            label: "Post Office",
                            icon: Icons.markunread_mailbox_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Post office is required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: pinC,
                            label: "PIN Code",
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "PIN code is required";
                              if (!RegExp(r'^\d{6}$').hasMatch(value))
                                return "Enter valid 6-digit PIN code";
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Professional Information Section
                          Text(
                            "Professional Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: qualificationC,
                            label: "Qualification",
                            icon: Icons.school_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Qualification is required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: skillsC,
                            label: "Skills",
                            icon: Icons.stars_outlined,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Skills are required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: interested_areaC,
                            label: "Area of Interest",
                            icon: Icons.interests_outlined,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Area of interest is required";
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Account Information Section
                          Text(
                            "Account Credentials",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: UsernameC,
                            label: "Username",
                            icon: Icons.account_circle_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Username is required";
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: passwordC,
                            label: "Password",
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Password is required";
                              if (value.length < 6)
                                return "Password must be at least 6 characters";
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 3,
                                shadowColor: primaryColor.withOpacity(0.4),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                String name = nameC.text;
                                String email = emailC.text;
                                String phone = phoneC.text;
                                String place = placeC.text;
                                String post = postC.text;
                                String pin = pinC.text;
                                String qualification = qualificationC.text;
                                String skills = skillsC.text;
                                String interested_area = interested_areaC.text;
                                String username = UsernameC.text;
                                String password = passwordC.text;

                                final sh = await SharedPreferences.getInstance();
                                String url = sh.getString("url").toString();

                                try {
                                  var uri = Uri.parse('$url/user_register/');
                                  var request = http.MultipartRequest('POST', uri);

                                  request.fields['name'] = name;
                                  request.fields['email'] = email;
                                  request.fields['phone'] = phone;
                                  request.fields['place'] = place;
                                  request.fields['post'] = post;
                                  request.fields['pin'] = pin;
                                  request.fields['qualification'] = qualification;
                                  request.fields['skills'] = skills;
                                  request.fields['interested_area'] = interested_area;
                                  request.fields['username'] = username;
                                  request.fields['password'] = password;

                                  var response = await request.send();

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Registration Successful!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Loginpage()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Registration failed: ${response.reasonPhrase}'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Register as User",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: labelColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Loginpage()),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}