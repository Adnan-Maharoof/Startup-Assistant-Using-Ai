import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'view_profile.dart';

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const UpdateProfilePage(title: 'Edit Profile'),
    );
  }
}

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key, required this.title});
  final String title;

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  String imageUrl = '';
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? "";
      String imgBaseUrl = sh.getString('imgurl') ?? "";
      String lid = sh.getString('lid') ?? "";

      final response = await http.post(
        Uri.parse('$baseUrl/viewprofile/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phone'] ?? '';
            bioController.text = data['bio'] ?? '';
            companyController.text = data['company_name'] ?? '';

            String photoPath = data['photo'] ?? data['image'] ?? '';

            if (photoPath.isNotEmpty) {
              if (photoPath.startsWith('http')) {
                imageUrl = photoPath;
              } else {
                imageUrl = imgBaseUrl.isNotEmpty
                    ? '$imgBaseUrl$photoPath'
                    : '$baseUrl$photoPath';
              }
            }

            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: 'Profile not found');
          setState(() => isLoading = false);
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
        setState(() => isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      setState(() => isLoading = false);
    }
  }

  // -------------------------------------------------------------
  //  FIXED PERMISSIONS FOR ANDROID 13+, ANDROID 12-, AND iOS
  // -------------------------------------------------------------
  Future<void> _checkPermissionAndChooseImage() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Android 13+ (Tiramisu)
      if (await Permission.photos.isGranted || await Permission.photos.isLimited) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.photos.request();

        // If photos fails, try storage for older devices
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    } else {
      // iOS always uses PHOTOS permission
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      _chooseImage();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Needed"),
          content: const Text(
              "Please grant permission to select an image from your device."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }

  // PICK IMAGE
  Future<void> _chooseImage() async {
    final picker = ImagePicker();
    final pickedImage =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // -------------------------------------------------------------

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? "";
    String lid = sh.getString('lid') ?? "";

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/updateprofile/'),
    );

    request.fields['lid'] = lid;
    request.fields['name'] = nameController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['bio'] = bioController.text.trim();
    request.fields['company'] = companyController.text.trim();

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);

        if (data['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: 'Profile updated successfully',
            backgroundColor: Colors.green,
          );

          Navigator.pop(context, true);
        } else {
          Fluttertoast.showToast(msg: 'Update failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage(
                        'assets/default_avatar.png')
                    as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _checkPermissionAndChooseImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                nameController,
                "Full Name",
                Icons.person_outline,
                    (value) {
                  if (value!.isEmpty) return "Name is required";
                  return null;
                },
              ),

              _buildTextField(
                emailController,
                "Email Address",
                Icons.email_outlined,
                    (value) {
                  if (value!.isEmpty) return "Email is required";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),

              _buildTextField(
                phoneController,
                "Phone Number",
                Icons.phone_outlined,
                    (value) {
                  if (value!.isEmpty) return "Phone is required";
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Phone must be 10 digits";
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                bioController,
                "Bio",
                Icons.notes_outlined,
                    (value) {
                  if (value!.length < 3) return "Bio too short";
                  return null;
                },
                maxLines: 3,
              ),

              _buildTextField(
                companyController,
                "Company Name",
                Icons.business_outlined,
                    (value) => null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _sendData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      FormFieldValidator<String>? validator, {
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
      ),
    );
  }
}
