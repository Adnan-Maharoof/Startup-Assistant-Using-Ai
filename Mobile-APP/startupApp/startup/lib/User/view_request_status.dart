import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:startup/User/view_fundoffer.dart';

class ViewRequestPage extends StatefulWidget {
  const ViewRequestPage({super.key});

  @override
  State<ViewRequestPage> createState() => _ViewRequestPageState();
}

class _ViewRequestPageState extends State<ViewRequestPage> {
  List<Map<String, String>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String lid = sh.getString('lid') ?? "";
      String url = '${sh.getString('url')}/view_request_status/';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, String>> tempList = [];

        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'date': item['date'].toString(),
            'status': item['status'].toString(),
            'startup': item['STARTUP'].toString(),
          });
        }

        setState(() {
          requests = tempList;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateStatus(String reqId, String newStatus) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = '${sh.getString('url')}/approve_request/';

      var response = await http.post(Uri.parse(url), body: {'req_id': reqId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status Updated: $newStatus"),
            backgroundColor: Colors.green,
          ),
        );
        fetchRequests();
      }
    } catch (e) {}
  }

  Future<void> rejectStatus(String reqId, String newStatus) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = '${sh.getString('url')}/reject_request/';

      var response = await http.post(Uri.parse(url), body: {'req_id': reqId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status Updated: $newStatus"),
            backgroundColor: Colors.red,
          ),
        );
        fetchRequests();
      }
    } catch (e) {}
  }

  Widget statusBadge(String status) {
    Color bg =
    status.toLowerCase() == "accepted" ? Colors.green.shade100 :
    status.toLowerCase() == "rejected" ? Colors.red.shade100 :
    Colors.blue.shade100;

    Color textColor =
    status.toLowerCase() == "accepted" ? Colors.green.shade800 :
    status.toLowerCase() == "rejected" ? Colors.red.shade800 :
    Colors.blue.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text(
          "View Requests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff6a11cb), Color(0xff2575fc)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: requests.isEmpty
          ? const Center(
        child: Text(
          "No Requests Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        itemCount: requests.length,
        padding: const EdgeInsets.all(14),
        itemBuilder: (context, index) {
          String status = requests[index]['status']!.toLowerCase();
          bool isAccepted = status == "accepted";
          bool isPending = status == "pending";

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  width: 1.2,
                  color: const Color(0xffd7d9e0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requests[index]['startup'] ?? '',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3d246c),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Date: ${requests[index]['date']}",
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black87),
                    ),

                    const SizedBox(height: 6),

                    Row(children: [
                      statusBadge(requests[index]['status'] ?? ""),
                    ]),

                    const SizedBox(height: 20),

                    // -------------------------
                    // BUTTON LOGIC FIXED
                    // -------------------------
                    Row(
                      children: [
                        if (isPending) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                updateStatus(
                                    requests[index]['id']!, "Accepted");
                              },
                              child: const Text("Accept",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                rejectStatus(
                                    requests[index]['id']!, "Rejected");
                              },
                              child: const Text("Reject",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],

                        if (isAccepted) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2575fc),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                SharedPreferences sh =
                                await SharedPreferences.getInstance();
                                sh.setString("Rid",
                                    requests[index]['id'] ?? "");

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewFundOffer()),
                                );
                              },
                              child: const Text("Fund Offer",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
