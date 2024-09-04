import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the HomePage

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to HomePage when login is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
