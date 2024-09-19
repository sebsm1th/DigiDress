import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'bottomnav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Index of the "Profile" screen
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to fetch user profile data from Firestore
  Future<Map<String, dynamic>> _fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        return userDoc.data() as Map<String, dynamic>;
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
    return {}; // Return empty map if user is not found
  }

  // Function to update the user's description in Firestore
  Future<void> _updateUserProfile({String? description, int? friendsCount}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          if (description != null) 'description': description,
          if (friendsCount != null) 'friendsCount': friendsCount,
        });
      } catch (e) {
        print('Error updating user profile: $e');
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : AssetImage('assets/avatar.jpg'), // Placeholder image
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display username
                          Text(
                            username,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          // Display friend count
                          Text(
                            'Friends: $friendsCount',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          // Display and edit description
                          Row(
                            children: [
                              Container(
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
}
