import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the HomePage

final TextEditingController usernameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back button
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 20), // Add spacing between text fields
              TextField(
                controller: passwordController,
                obscureText: true, // Hide the password text
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20), // Add spacing between the text field and the buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to HomePage when login is pressed
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Print to console when "Create Account" is pressed
                      print("Create Account button pressed");
                    },
                    child: Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
