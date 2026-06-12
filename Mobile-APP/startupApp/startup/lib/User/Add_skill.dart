import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'view_skills.dart';

class AddSkill extends StatefulWidget {
  const AddSkill({super.key});

  @override
  State<AddSkill> createState() => _AddSkillState();
}

class _AddSkillState extends State<AddSkill> {
  final TextEditingController skillC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 BEAUTIFUL GRADIENT APPBAR
      appBar: AppBar(
        title: const Text(
          "Add Skill",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 🟣 CARD CONTAINER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  // 🔤 TITLE TEXT
                  const Text(
                    "Enter Your Skill",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📝 STYLISH TEXT FIELD
                  TextField(
                    controller: skillC,
                    decoration: InputDecoration(
                      labelText: "Skill",
                      labelStyle: const TextStyle(
                          color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.star, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.4), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Colors.deepPurple, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🌟 ADD BUTTON
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.deepPurple,
                        elevation: 5,
                      ),
                      child: const Text(
                        "Add Skill",
                        style: TextStyle(
                            fontSize: 18, color: Colors.white, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 BACKEND API FUNCTION WITH VALIDATION
  Future<void> _addSkill() async {
    String skill = skillC.text.trim();

    // ✅ Validation Rules
    if (skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Skill cannot be empty")),
      );
      return;
    }

    if (skill.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Skill must be at least 2 characters")),
      );
      return;
    }

    // Optional: Only allow letters, numbers, spaces
    final validSkill = RegExp(r'^[a-zA-Z0-9 ]+$');
    if (!validSkill.hasMatch(skill)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Skill cannot contain special characters")),
      );
      return;
    }

    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url").toString();
    String lid = sh.getString('lid') ?? "";

    try {
      var uri = Uri.parse('$url/add_skill/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['skill'] = skill;
      request.fields['lid'] = lid;

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill added successfully'),
            backgroundColor: Colors.deepPurple,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const ViewSkillsPage(title: "My Skills")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}



