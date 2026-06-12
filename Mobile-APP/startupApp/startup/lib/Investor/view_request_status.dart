import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'fund offer with user.dart';

class ViewRequestPage extends StatefulWidget {
  const ViewRequestPage({super.key});

  @override
  State<ViewRequestPage> createState() => _ViewRequestPageState();
}

class _ViewRequestPageState extends State<ViewRequestPage> {
  List<Map<String, String>> requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // ================================
  // FETCH REQUEST DATA
  // ================================
  Future<void> fetchRequests() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================================
  // STATUS COLOR & ICON
  // ================================
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return const Color(0xFF66BB6A);
      case 'pending':
        return const Color(0xFFFFCA28);
      case 'rejected':
      case 'declined':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.access_time;
      case 'rejected':
      case 'declined':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ================================
  // PAGE UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌸 Light Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF4E6), Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF424242),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Requests",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          Text(
                            "Track your investment requests",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF42A5F5),
                    ),
                  )
                      : requests.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Color(0xFF90A4AE),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Requests Found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your investment requests will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: fetchRequests,
                    color: Color(0xFF42A5F5),
                    child: ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final status =
                        (requests[index]['status'] ?? '')
                            .toLowerCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Header with Startup Name
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF42A5F5)
                                            .withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.business,
                                        color: Color(0xFF42A5F5),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            requests[index]
                                            ['startup'] ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold,
                                              color:
                                              Color(0xFF424242),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color:
                                                Color(0xFF90A4AE),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                requests[index]
                                                ['date'] ??
                                                    '',
                                                style:
                                                const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(
                                                      0xFF757575),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                        requests[index]
                                        ['status'] ??
                                            '')
                                        .withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(requests[index]
                                        ['status'] ??
                                            ''),
                                        size: 18,
                                        color: _getStatusColor(
                                            requests[index]
                                            ['status'] ??
                                                ''),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Status: ${requests[index]['status']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(
                                              requests[index]
                                              ['status'] ??
                                                  ''),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Fund Offer Button: ONLY show if accepted
                                if (status == 'accepted')
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        SharedPreferences sh =
                                        await SharedPreferences
                                            .getInstance();
                                        sh.setString("Rid",
                                            requests[index]['id'] ??
                                                "");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  fundoffer()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF42A5F5),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                        ),
                                        padding: const EdgeInsets
                                            .symmetric(
                                            vertical: 14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.attach_money,
                                              size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "Make Fund Offer",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
