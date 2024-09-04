import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'homepage.dart';
import 'posting.dart';
import 'search.dart';
import 'chat.dart';
import 'profile.dart';
import 'bottomnav.dart'; // Import BottomNavBar

class AvatarPage extends StatefulWidget {
  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 2; // Current index for "Wardrobe" screen

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNavBarTap(int index) {
    // You might not need this function since navigation is handled inside BottomNavBar
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Digidress - Avatar'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Posting()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weather Info Row
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
                    Text('Today', style: TextStyle(color: Colors.red)),
                    Text('16° Partly Cloudy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
                    Text('8° Rainy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
                    Text('18° Sunny'),
                  ],
                ),
              ],
            ),
          ),
          
          // Avatar and Outfit Controls
          Expanded(
            child: Center(
              child: Column(
                children: [
                  // Your Avatar
                  Expanded(
                    child: Image.asset('assets/avatar.jpg'), // Replace with actual avatar widget
                  ),

                  // Outfit Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          // Previous Outfit
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Generate Outfit
                        },
                        child: Text('Generate Outfit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Next Outfit
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Bar
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}