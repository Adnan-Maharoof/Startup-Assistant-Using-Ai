import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Add_skill.dart';

class ViewSkills extends StatelessWidget {
  const ViewSkills({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Skills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const ViewSkillsPage(title: 'My Skills'),
    );
  }
}

class ViewSkillsPage extends StatefulWidget {
  const ViewSkillsPage({super.key, required this.title});
  final String title;

  @override
  State<ViewSkillsPage> createState() => _ViewSkillsPageState();
}

class _ViewSkillsPageState extends State<ViewSkillsPage> {
  List<String> skillId = [];
  List<String> skillName = [];
  List<String> skillDate = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString("url") ?? "";
      String lid = prefs.getString("lid") ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/view_skill_user/"),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          var arr = jsonData["data"];
          skillId = [];
          skillName = [];
          skillDate = [];

          for (var item in arr) {
            skillId.add(item['id'].toString());
            skillName.add(item['skill'].toString());
            skillDate.add(item['date'].toString());
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching skills: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteSkill(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString("url") ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/deleteskill/"),
        body: {'id': id},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          Fluttertoast.showToast(msg: "Skill deleted successfully");
          _fetchSkills();
        } else {
          Fluttertoast.showToast(msg: "Failed to delete skill");
        }
      } else {
        Fluttertoast.showToast(msg: "Network error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Widget skillCard(String skill, String date, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.deepPurple, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this skill?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _deleteSkill(skillId[index]);
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
          : skillId.isEmpty
          ? const Center(
        child: Text(
          "No skills added yet",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : RefreshIndicator(
            onRefresh: _fetchSkills,
            child: ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 80),
          itemCount: skillId.length,
          itemBuilder: (context, index) {
            return skillCard(skillName[index], skillDate[index], index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 65,
          height: 65,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
          ),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSkill()),
          );
          _fetchSkills();
        },
      ),
    );
  }
}

List<String> eventId = [];
List<String> eventName = [];
List<String> eventDate = [];
List<String> eventTime = [];
List<String> eventLocation = [];
List<String> eventdetails = [];
List<String> eventlink = [];
List<String> eventtype = [];