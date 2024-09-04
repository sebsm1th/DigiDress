import 'package:flutter/material.dart';
import 'login_page.dart';  // Ensure you have this import to navigate back to the login screen

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile Page Placeholder',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),

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
    );
  }
}
