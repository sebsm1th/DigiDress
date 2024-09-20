import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io';
import 'login_page.dart';
import 'bottomnav.dart';
import 'userservice.dart'; // Import UserService

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Index of the "Profile" screen
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService(); // Instantiate UserService
  File? _image; // Store the selected image

  // Function to fetch user profile data from Firestore
  Future<Map<String, dynamic>> _fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        int friendsCount = await _userService.getFriendsCount(user.uid); // Use UserService
        return {
          ...userDoc.data() as Map<String, dynamic>,
          'friendsCount': friendsCount, // Include friends count
        };
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
    return {}; // Return empty map if user is not found
  }

  // Function to handle image picking
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Picking from the gallery

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the image
      });
      _uploadProfilePicture(_image!); // Upload the selected image
    }
  }

  // Function to upload the profile picture to Firebase Storage
  Future<void> _uploadProfilePicture(File image) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}');
        await storageRef.putFile(image); // Upload image to Firebase Storage
        String downloadUrl = await storageRef.getDownloadURL(); // Get the image URL

        // Update the user's Firestore profile with the new image URL
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          // Update the profile picture UI with the new image
        });

        print('Profile picture uploaded successfully!');
      } catch (e) {
        print('Error uploading profile picture: $e');
      }
    }
  }

  // Function to handle navigation tap
  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in to view your profile.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Profile data not available'));
          } else {
            final userProfile = snapshot.data!;
            String username = userProfile['username'] ?? 'No username';
            String profileImageUrl = userProfile['profileImageUrl'] ?? '';
            String description = userProfile['description'] ?? 'Please Insert Description';
            int friendsCount = userProfile['friendsCount'] ?? 0;

            TextEditingController descriptionController = TextEditingController(text: description);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display profile picture
                      GestureDetector(
                        onTap: _pickImage, // Allow user to tap and select a new image
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : (_image != null
                                  ? FileImage(_image!)
                                  : AssetImage('assets/defaultProfilePicture.png')) as ImageProvider, // Default profile picture
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display username
                            Text(
                              username,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            // Display and navigate to friends list
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsListPage(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Friends: $friendsCount',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            // Display and edit description
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 200, // Adjust width as needed
                                    child: TextField(
                                      controller: descriptionController,
                                      decoration: InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 2, // Allow multi-line input
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () {
                                    _updateUserProfile(description: descriptionController.text); // Update description
                                    setState(() {}); // Rebuild the UI with the updated data
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId', isEqualTo: user.uid) // Get posts by the logged-in user
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs;

                      if (posts.isEmpty) {
                        return Center(child: Text('No posts yet.'));
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Show 3 posts per row
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final imageUrl = post['imageUrl'];

                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20), // Add some spacing between the posts and the button
                ElevatedButton(
                  onPressed: () {
                    // Log out the user and navigate back to the login screen
                    _auth.signOut().then((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    });
                  },
                  child: Text('Logout'),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  // Function to update the user's description in Firestore
  Future<void> _updateUserProfile({String? description}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          if (description != null) 'description': description,
        });
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
  }
}

// FriendsListPage to display the user's friends
class FriendsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in to view friends.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friends')
            .doc(user.uid)
            .collection('userFriends')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data!.docs;

          if (friends.isEmpty) {
            return Center(child: Text('No friends yet.'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              String friendName = friend['username'] ?? 'Unknown';

              return ListTile(
                title: Text(friendName),
              );
            },
          );
        },
      ),
    );
  }
}
