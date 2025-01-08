import 'dart:io';

import 'package:expenses_tracker/databases/database_helper.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  String? _imagePath; // Declare _imagePath here
  File? _selectedImage;
  late String _username;
  late String _email;
  late String _mobile;
  late int profileRows = 0;

  Map<String, dynamic> _profile = {};

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  Future<String> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<void> _openImagePicker() async {
    // await Permission.photos.request();
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();
    await Permission.camera.request();

    if (Platform.isAndroid) {
      // final androidInfo = await DeviceInfoPlugin().androidInfo;
      // if (androidInfo.version.sdkInt <= 32) {
      //   if (storageStatus.isGranted || status.isGranted) {
      //     // Proceed with profile picture update logic
      //     final picker = ImagePicker();

      //     final pickedFile =
      //         await ImagePicker().pickImage(source: ImageSource.gallery);
      //     if (pickedFile != null) {
      //       File imageFile = File(pickedFile.path);
      //       // Process the imageFile
      //       setState(() {
      //         _selectedImage = File(pickedFile.path);
      //         print(_selectedImage);
      //       });
      //     }

      //     /// use [Permissions.storage.status]
      //   } else {
      //     /// use [Permissions.photos.status]
      //     print('Error ------------------------------------>');
      //   }
      // }
    }
  }

  void initState() {
    super.initState();
    _getRowsCount();
    var profilelcl = _fetchProfile();

    _username = _profile['userName'].toString().isNotEmpty
        ? _profile['userName'].toString()
        : '';
    _email = _profile['userEmail'].toString().isNotEmpty
        ? _profile['userEmail'].toString()
        : '';
    _mobile = _profile['mobile'].toString().isNotEmpty
        ? _profile['mobile'].toString()
        : '';

    _userNameController.text = _username;
    _emailController.text = _email;
    _mobileController.text = _mobile;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _getRowsCount() async {
    var count = await _dbHelper.getRowsCount('profile');
    setState(() {
      profileRows = count;
    });
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final List<Map<String, dynamic>> profiles = await _dbHelper.loadProfile();
    Map<String, dynamic> profile = profiles.isEmpty ? {} : profiles.first;
    setState(() {
      _profile = profile;

      _userNameController.text = _profile['userName'].toString();
      _emailController.text = _profile['userEmail'].toString();
      _mobileController.text = _profile['mobile'].toString();
    });
    return profile;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (profileRows == 0) {
        // Insert new profile
        await _dbHelper.saveProfile(_username, _email, _mobile);
      } else {
        // Insert new profile
        await _dbHelper.updateProfile(_username, _email, _mobile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.grey,
        ),
      );

      // Reset form fields and state variables
      // _formKey.currentState!.reset();
      setState(() {
        _username = '';
        _email = '';
        _mobile = '';
      });

      // Redirect to TransactionsPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            body: SettingsPage(),
            currentIndex: 4,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage('assets/images/profile_placeholder.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Handle profile picture update
                          // You can use a file picker to select an image
                          _openImagePicker();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the email.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  prefixIcon: Icon(Icons.smartphone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your mobile.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _mobile = value!;
                },
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: isNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    isNotificationsEnabled = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*
upload an user image and save into the assets folder
*/
  uploadImage() async {
    final directory = await getStorageDirectory();
    final imagePath = '$directory/profile_picture.jpg';
    // save the image to the assets folder
    setState(() {
      _imagePath = imagePath;
    });
  }
}
