import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class CreateAccountPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController(); // Controller for username
  
  // Initialize Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username field
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields
              
              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Confirm Password field
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Create Account Button
              ElevatedButton(
                onPressed: () async {
                  print('Create Account button pressed');
                  String username = usernameController.text; // Get username
                  String email = emailController.text;
                  String password = passwordController.text;
                  String confirmPassword = confirmPasswordController.text;
                  String description = '';

                  if (password == confirmPassword) {
                    try {
                      // Create user with email and password
                      final credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      
                      // Save user data to Firestore
                      await _createUserInFirestore(credential.user!.uid, email, username, description); // Pass username

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account successfully created for email: $email'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigate back to login page after successful account creation
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      if (e.code == 'weak-password') {
                        errorMessage = 'The password provided is too weak.';
                      } else if (e.code == 'email-already-in-use') {
                        errorMessage = 'The account already exists for that email.';
                      } else {
                        errorMessage = 'An error occurred: ${e.message}';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating account: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create user in Firestore
Future<void> _createUserInFirestore(String uid, String email, String username, String description) async {
  try {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'username_lowercase': username.toLowerCase(), // Lowercase version for search
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'friendsCount': 0, // Initialize friendsCount to 0
      'description': description,
    });
  } catch (e) {
    print('Error creating user in Firestore: $e');
    rethrow; // Rethrow the error to be handled by the caller
  }
}
}
