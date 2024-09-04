import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure you have this import to navigate back to the login screen
import 'bottomnav.dart'; // Import BottomNavBar

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Index of the "Profile" screen

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile Page Placeholder',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20), // Add some spacing between the text and the button
                  ElevatedButton(
                    onPressed: () {
                      // Implement logout logic here
                      // For now, just navigate back to the login screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavBarTap,
          ),
        ],
      ),
    );
  }
}