import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'homepage.dart';

class fundoffer extends StatefulWidget {
  @override
  _fundofferState createState() => _fundofferState();
}

class _fundofferState extends State<fundoffer> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write a New Amount")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter your amount",
                    border: OutlineInputBorder(),
                  ),

                  // ✅ FULL VALIDATION
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }

                    // Check if numeric
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }

                    double amount = double.parse(value.trim());

                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }

                    if (amount < 100) {
                      return 'Minimum amount should be ₹100';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    SharedPreferences sh =
                    await SharedPreferences.getInstance();

                    String amount = _amountController.text.trim();
                    String url = sh.getString("url") ?? "";
                    String lid = sh.getString("lid") ?? "";
                    String requestId = sh.getString("Rid") ?? "";

                    var response = await http.post(
                      Uri.parse(url + "/send_fund/"),
                      body: {
                        'amount': amount,
                        'lid': lid,
                        'request_id': requestId,
                      },
                    );

                    var jsonData = json.decode(response.body);

                    if (jsonData["status"] == "ok") {
                      Fluttertoast.showToast(
                        msg: "Fund sent successfully!",
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InvestorHome()),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Error: ${jsonData['message']}",
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                  child: Text("Submit Fund"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
