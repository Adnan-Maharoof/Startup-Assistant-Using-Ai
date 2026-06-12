import 'dart:ui'; // For ImageFilter.blur()
import 'package:flutter/material.dart';
import 'package:startup/Investor/view_request_status.dart';

import '../login.dart';
import 'change_password.dart';
import 'send_system_feedback.dart';
import 'view_notification.dart';
import 'view_profile.dart';
import 'view_startup idea recommendation.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InvestorHome(),
  ));
}

class InvestorHome extends StatefulWidget {
  const InvestorHome({Key? key}) : super(key: key);

  @override
  State<InvestorHome> createState() => _InvestorHomeState();
}

class _InvestorHomeState extends State<InvestorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Company Dashboard",
            style: TextStyle(
              fontSize: 23,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f3460),
                  Color(0xFF16213e),
                  Color(0xFF1a1a2e),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroCard(),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _featureCard(Icons.person_outline, "Profile"),
                    _featureCard(Icons.lightbulb_outline, "Startup Ideas"),
                    _featureCard(Icons.assignment_outlined, "Request Status"),
                    _featureCard(Icons.feedback_outlined, "Feedback"),
                    // _featureCard(Icons.recommend_sharp , "recommendation"),
                    _featureCard(Icons.lock_outline, "Change Password"),
                    _featureCard(Icons.notifications_none, "Notifications"),
                    _featureCard(Icons.logout, "Logout"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🌟 Premium Investor Hero Section
  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFe94560), Color(0xFFf39c12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFe94560).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.account_circle,
                      size: 70, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                "Welcome Back, Company!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Discover potential startups and help shape the future.",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.explore),
                label: const Text("Explore Opportunities"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFe94560),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🌟 Modern Rounded Tiles
  Widget _featureCard(IconData icon, String title) {
    return InkWell(
      onTap: () {
        switch (title) {
          case "Profile":
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ViewProfilePage(title: '')));
            break;

          case "Startup Ideas":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StartupRecommendationPage()));
            break;


        // case "recommendation":
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (_) => recommendationpagePage(title: '')));
        //   break;

          case "Request Status":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => ViewRequestPage()));
            break;

          case "Feedback":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => NewfeedbackPage()));
            break;

          case "Change Password":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MyChangePasswordPage(title: '')));
            break;

          case "Notifications":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        View_notificationpagePage(title: '')));
            break;

          case "Logout":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Loginpage()));
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFF0f3460),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFe94560).withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: const Color(0xFFe94560)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}