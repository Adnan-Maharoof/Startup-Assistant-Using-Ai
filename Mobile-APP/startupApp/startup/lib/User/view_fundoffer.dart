import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewFundOffer extends StatelessWidget {
  const ViewFundOffer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ViewFundOfferPage(),
    );
  }
}

class ViewFundOfferPage extends StatefulWidget {
  const ViewFundOfferPage({super.key});

  @override
  State<ViewFundOfferPage> createState() => _ViewFundOfferPageState();
}

class _ViewFundOfferPageState extends State<ViewFundOfferPage> {
  List<String> ids = [];
  List<String> amounts = [];
  List<String> investors = [];

  @override
  void initState() {
    super.initState();
    fetchFundData();
  }

  Future<void> fetchFundData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String lid = pref.getString("lid").toString();

      String url = "$ip/view_fundoffer_user/";
      print("API URL: $url");

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsondata = json.decode(response.body);

      print("Response: $jsondata");

      if (jsondata["status"] != "ok") {
        print("Backend returned error status");
        return;
      }

      var arr = jsondata["data"];
      print("Received rows: ${arr.length}");

      List<String> tempId = [];
      List<String> tempAmount = [];
      List<String> tempInvestor = [];

      for (var row in arr) {
        tempId.add(row["id"].toString());
        tempAmount.add(row["amount"].toString());
        tempInvestor.add(row["investor"].toString());
        // FIXED
      }

      setState(() {
        ids = tempId;
        amounts = tempAmount;
        investors = tempInvestor;
      });
    } catch (e) {
      print("ERROR FETCHING FUND DATA: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fund Offers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ids.isEmpty
          ? const Center(child: Text("No fund offers available"))
          : ListView.builder(
        itemCount: ids.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount: ₹${amounts[index]}",
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Investor: ${investors[index]}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
