// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:startup/Investor/homepage.dart';
// import '../User/chat.dart';
//
// class View_startup extends StatelessWidget {
//   const View_startup({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'startup',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const View_startuppagePage(title: 'View Startups'),
//     );
//   }
// }
//
// class View_startuppagePage extends StatefulWidget {
//   const View_startuppagePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<View_startuppagePage> createState() => _View_startuppagePage();
// }
//
// class _View_startuppagePage extends State<View_startuppagePage> {
//   List<String> cid_ = [];
//   List<String> ctitle_ = [];
//   List<String> cdescription_ = [];
//   List<String> cindustry_ = [];
//   List<String> LOGIN_ = [];
//   List<String> user_ = [];
//   List<String> cname_ = [];
//   List<String> cemail_ = [];
//   List<String> cphone_ = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     View_startup();
//   }
//
//   Future<void> View_startup() async {
//     try {
//       final pref = await SharedPreferences.getInstance();
//       String ip = pref.getString("url").toString();
//
//       String url = ip + "/view_startup/";
//       print(url);
//
//       var data = await http.post(Uri.parse(url));
//       var jsondata = json.decode(data.body);
//
//       var arr = jsondata["data"];
//
//       List<String> cid = [];
//       List<String> ctitle = [];
//       List<String> cdescription = [];
//       List<String> cindustry = [];
//       List<String> LOGIN = [];
//       List<String> user = [];
//       List<String> cname = [];
//       List<String> cemail = [];
//       List<String> cphone = [];
//
//       for (int i = 0; i < arr.length; i++) {
//         cid.add(arr[i]['id'].toString());
//         ctitle.add(arr[i]['title'].toString());
//         cdescription.add(arr[i]['description'].toString());
//         cindustry.add(arr[i]['industry'].toString());
//         LOGIN.add(arr[i]['LOGIN'].toString());
//         user.add(arr[i]['user'].toString());
//         cname.add(arr[i]['uname'].toString());
//         cemail.add(arr[i]['uemail'].toString());
//         cphone.add(arr[i]['uphone'].toString());
//       }
//
//       setState(() {
//         cid_ = cid;
//         ctitle_ = ctitle;
//         cdescription_ = cdescription;
//         cindustry_ = cindustry;
//         LOGIN_ = LOGIN;
//         user_ = user;
//         cname_ = cname;
//         cemail_ = cemail;
//         cphone_ = cphone;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print("Error: " + e.toString());
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Color _getIndustryColor(String industry) {
//     switch (industry.toLowerCase()) {
//       case 'technology':
//       case 'tech':
//         return const Color(0xFF42A5F5);
//       case 'healthcare':
//       case 'health':
//         return const Color(0xFF66BB6A);
//       case 'finance':
//       case 'fintech':
//         return const Color(0xFFFF7043);
//       case 'education':
//       case 'edtech':
//         return const Color(0xFFAB47BC);
//       case 'retail':
//       case 'ecommerce':
//         return const Color(0xFFFFCA28);
//       default:
//         return const Color(0xFF42A5F5);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 🌸 Light Gradient Background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFFFF4E6), Color(0xFFE3F2FD)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: Column(
//               children: [
//                 // Custom AppBar
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.arrow_back, color: Color(0xFF424242)),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Explore Startups",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF424242),
//                             ),
//                           ),
//                           Text(
//                             "Find your next investment",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF757575),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Content
//                 Expanded(
//                   child: _isLoading
//                       ? Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF42A5F5),
//                     ),
//                   )
//                       : cid_.isEmpty
//                       ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.business_outlined,
//                           size: 80,
//                           color: Color(0xFF90A4AE),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "No Startups Available",
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Color(0xFF757575),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                       : RefreshIndicator(
//                     onRefresh: View_startup,
//                     color: Color(0xFF42A5F5),
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: cid_.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 15,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Header with Industry Badge
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         user_[index],
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF424242),
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _getIndustryColor(cindustry_[index])
//                                             .withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(
//                                             Icons.business_center,
//                                             size: 14,
//                                             color: _getIndustryColor(cindustry_[index]),
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             cindustry_[index],
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w600,
//                                               color: _getIndustryColor(cindustry_[index]),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 12),
//
//                                 // Description
//                                 Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF5F5F5),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     cdescription_[index],
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Color(0xFF616161),
//                                       height: 1.5,
//                                     ),
//                                   ),
//                                 ),
//
//                                 const SizedBox(height: 16),
//
//                                 // Contact Information
//                                 Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFE3F2FD).withOpacity(0.5),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       _buildInfoRow(
//                                         Icons.person_outline,
//                                         "Founder",
//                                         cname_[index],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       _buildInfoRow(
//                                         Icons.email_outlined,
//                                         "Email",
//                                         cemail_[index],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       _buildInfoRow(
//                                         Icons.phone_outlined,
//                                         "Phone",
//                                         cphone_[index],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 const SizedBox(height: 16),
//
//                                 // Action Buttons
//                                 Row(
//                                   children: [
//                                     // CHAT BUTTON
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => ChatPage(
//                                                 startupId: LOGIN_[index],
//                                                 startupName: user_[index],
//                                                 startupPhotoUrl: ctitle_[index],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.white,
//                                           foregroundColor: const Color(0xFF42A5F5),
//                                           elevation: 0,
//                                           side: const BorderSide(
//                                             color: Color(0xFF42A5F5),
//                                             width: 2,
//                                           ),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           padding: const EdgeInsets.symmetric(vertical: 14),
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: const [
//                                             Icon(Icons.chat_bubble_outline, size: 18),
//                                             SizedBox(width: 8),
//                                             Text(
//                                               "Chat",
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//
//                                     const SizedBox(width: 12),
//
//                                     // REQUEST BUTTON
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         onPressed: () async {
//                                           final sh = await SharedPreferences.getInstance();
//                                           String url = sh.getString("url").toString();
//                                           String lid = sh.getString("lid").toString();
//
//                                           var res = await http.post(
//                                             Uri.parse(url + "/sendrequest_investor/"),
//                                             body: {
//                                               'lid': lid,
//                                               'sid': cid_[index],
//                                             },
//                                           );
//                                           var jsonResp = json.decode(res.body);
//
//                                           if (jsonResp['status'] == "ok") {
//                                             Fluttertoast.showToast(
//                                               msg: "Request Sent Successfully!",
//                                               backgroundColor: Colors.green,
//                                               textColor: Colors.white,
//                                             );
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => InvestorHome()),
//                                             );
//                                           } else if (jsonResp['status'] == "No") {
//                                             Fluttertoast.showToast(
//                                               msg: "Already Requested!",
//                                               backgroundColor: Colors.orange,
//                                               textColor: Colors.white,
//                                             );
//                                           }
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: const Color(0xFF42A5F5),
//                                           foregroundColor: Colors.white,
//                                           elevation: 0,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           padding: const EdgeInsets.symmetric(vertical: 14),
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: const [
//                                             Icon(Icons.send_outlined, size: 18),
//                                             SizedBox(width: 8),
//                                             Text(
//                                               "Request",
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: const Color(0xFF42A5F5),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           "$label: ",
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF616161),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF757575),
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StartupRecommendationPage extends StatefulWidget {
  const StartupRecommendationPage({super.key});

  @override
  State<StartupRecommendationPage> createState() =>
      _StartupRecommendationPageState();
}

class _StartupRecommendationPageState
    extends State<StartupRecommendationPage> {
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString("url");

      if (url == null) {
        setState(() {
          errorMessage = "Server URL not found";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse("$url/NLP_Startup_Recommendation/"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'ok') {
          setState(() {
            recommendations =
            List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No recommendations available";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isLoading = false;
      });
    }
  }

  Widget buildRecommendationCard(Map<String, dynamic> item) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Title
            Text(
              item['title'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // 📝 Description
            Text(
              item['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),

            // 🏷 Industry
            Row(
              children: [
                Chip(
                  label: Text(item['industry'] ?? ''),
                  backgroundColor: Colors.blue.shade50,
                ),
                const Spacer(),
                const Icon(Icons.trending_up, color: Colors.green),
              ],
            ),

            const Divider(),

            // 👤 User Info
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 6),
                Text(item['uname'] ?? ''),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 6),
                Text(item['uemail'] ?? ''),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 6),
                Text(item['uphone'] ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Startup Recommendations"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : recommendations.isEmpty
          ? const Center(child: Text("No recommendations available"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return buildRecommendationCard(recommendations[index]);
        },
      ),
    );
  }
}


