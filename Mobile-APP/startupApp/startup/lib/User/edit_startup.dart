//
// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'homepage.dart';
// import 'view_startup_ideas.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'startup',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const edit_startup(title: 'startup'),
//     );
//   }
// }
//
// class edit_startup extends StatefulWidget {
//   const edit_startup({super.key, required this.title});
//
//
//
//   final String title;
//
//   @override
//   State<edit_startup> createState() => _edit_startupState();
// }
//
// class _edit_startupState extends State<edit_startup> {
//   TextEditingController titlecontroller=new TextEditingController();
//   TextEditingController descriptioncontroller=new TextEditingController();
//   TextEditingController industrycontroller=new TextEditingController();
//   final _formKey=GlobalKey<FormState>();
//
//   _edit_startupState() {
//     _get_data();
//   }
//   void _get_data() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//
//     final urls = Uri.parse('$url/edit_service_post/');
//     try {
//       final response = await http.post(urls, body: {
//         'lid': lid,
//
//
//       });
//       // print(jsonDecode(response.body)['city']);
//
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           String title = jsonDecode(response.body)['title'];
//           String description = jsonDecode(response.body)['description'];
//           String industry = jsonDecode(response.body)['industry'];
//
//
//           setState(() {
//             titlecontroller.text = title;
//             descriptioncontroller.text = description;
//             industrycontroller.text = industry;
//
//
//           });
//         } else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: () async{
//         Navigator.push(context, MaterialPageRoute(builder: (context) => view_startuppagePage(title: "",),));
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Color.fromARGB(240, 110, 132, 147),
//
//         // appBar: AppBar(
//         //
//         //   backgroundColor: Colors.brown,
//         //   foregroundColor: Colors.orange[700],
//         //
//         //   title: Text(widget.title),
//         // ),
//         body: Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//                 image: NetworkImage('https://img.freepik.com/premium-vector/electric-car-with-green-glowing-dark-background-ev-charge-station_32996-1098.jpg'), fit: BoxFit.cover),
//           ),
//           child: Center(
//
//             child: Form(
//               key: _formKey,
//               child: Column(
//
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.all(10),
//                     child: TextFormField(
//                       validator: (value) => Validatecomplaints(value!),
//
//                       controller: titlecontroller,
//
//                       decoration: InputDecoration(border: OutlineInputBorder(),
//                         labelText: 'title',
//                         fillColor: Colors.grey.shade300,
//                         filled: true,
//                       ),
//                     ),
//                   ),Padding(
//                     padding: EdgeInsets.all(10),
//                     child: TextFormField(
//                       validator: (value) => Validatecomplaints(value!),
//
//                       controller: descriptioncontroller,
//                       decoration: InputDecoration(border: OutlineInputBorder(),
//                         labelText: 'description',
//                         fillColor: Colors.grey.shade300,
//                         filled: true,
//                       ),
//                     ),
//                   ),Padding(
//                     padding: EdgeInsets.all(10),
//                     child: TextFormField(
//                       validator: (value) => Validatecomplaints(value!),
//
//                       controller: industrycontroller,
//                       decoration: InputDecoration(border: OutlineInputBorder(),
//                         labelText: 'industry',
//                         fillColor: Colors.grey.shade300,
//                         filled: true,
//                       ),
//                     ),
//                   ),
//
//                   ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//
//                         foregroundColor: Colors.white,
//                       ),
//                       onPressed: (){
//                         if(_formKey.currentState!.validate()){
//                           sendata();}}, child: Text('send'))
//
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // floatingActionButton: FloatingActionButton(onPressed: () {
//         //
//         //   Navigator.push(
//         //       context,
//         //       MaterialPageRoute(builder: (context) => MyViewReplyPage(title: 'home')));
//         //
//         // },
//         //   backgroundColor: Color.fromARGB(234, 100, 68, 28),
//         //   child: Icon(Icons.home_filled),
//         // ),
//
//       ),
//     );
//   }
//   void sendata()async{
//     String title=titlecontroller.text;
//     String description=descriptioncontroller.text;
//     String industry=industrycontroller.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//
//     final urls = Uri.parse('$url/updaate_service_post/');
//     try {
//       final response = await http.post(urls, body: {
//         'title':title,
//         'description':description,
//         'industry':industry,
//         'lid':sh.getString("lid").toString(),
//
//       });
//       print(jsonDecode(response.body));
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         print(status);
//         if (status=='ok') {
//
//           Fluttertoast.showToast(msg: ' Updated Service Successfully ');
//
//           Navigator.push(context, MaterialPageRoute(
//             builder: (context) => UserHomepage(),));
//         }else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       }
//       else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     }
//     catch (e){
//       Fluttertoast.showToast(msg: e.toString());
//     }
//
//   }
//   String? Validatecomplaints(String value){
//     if(value.isEmpty){
//       return 'please enter your complaints';
//     }
//     return null;
//     }
// }