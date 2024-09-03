import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'homepage.dart';

class AvatarPage extends StatefulWidget {
  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  // Add variables here to hold any state information if needed
  // For example: int _selectedOutfit = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digidress - Avatar'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              // Add action for post button
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
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checkroom),
                label: 'Wardrobe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: 2, // Index of the "Wardrobe" screen
            onTap: (index) {
              if (index == 0) {
                // Navigate to HomePage when Home button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                // Handle other tabs
              }
            },
            backgroundColor: Colors.black, // Set the background color to black
            selectedItemColor: Colors.white, // Set the selected item color to white
            unselectedItemColor: Colors.white70, // Set the unselected item color to white70
            showUnselectedLabels: true, // Show labels for unselected items
          ),
        ],
      ),
    );
  }
}
