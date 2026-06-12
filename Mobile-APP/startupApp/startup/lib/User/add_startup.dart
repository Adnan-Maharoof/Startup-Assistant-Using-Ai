import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'view_startup_ideas.dart';

class AddStartupPage extends StatefulWidget {
  const AddStartupPage({super.key});

  @override
  State<AddStartupPage> createState() => _AddStartupPageState();
}

class _AddStartupPageState extends State<AddStartupPage> {
  TextEditingController titleC = TextEditingController();
  TextEditingController descriptionC = TextEditingController();
  TextEditingController industryC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text("Add Startup"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shadowColor: Colors.indigo.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Create New Startup",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildInputField(controller: titleC, label: "Startup Title", icon: Icons.title),
                  const SizedBox(height: 20),
                  _buildInputField(controller: descriptionC, label: "Description", icon: Icons.description, maxLines: 3),
                  const SizedBox(height: 20),
                  _buildInputField(controller: industryC, label: "Industry", icon: Icons.business_center),
                  const SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Add Startup",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Future<void> submitForm(BuildContext context) async {
    String title = titleC.text.trim();
    String description = descriptionC.text.trim();
    String industry = industryC.text.trim();

    // =========================
    // VALIDATION
    // =========================
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title is required")));
      return;
    }
    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title must be at least 3 characters")));
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description is required")));
      return;
    }
    if (description.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description must be at least 10 characters")));
      return;
    }
    if (industry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Industry is required")));
      return;
    }
    if (industry.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Industry must be at least 3 characters")));
      return;
    }

    // =========================
    // SUBMIT FORM
    // =========================
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url").toString();
    String lid = sh.getString('lid') ?? "";

    try {
      var uri = Uri.parse('$url/add_startup_user/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['industry'] = industry;
      request.fields['lid'] = lid;

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Startup Added Successfully!'), duration: Duration(seconds: 4)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewStartupPage(title: '')),
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
