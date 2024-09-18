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

  String username = ''; // Placeholder for username
  String profileImageUrl = ''; // Placeholder for profile image
  String description = 'Please Insert Description'; // Placeholder for description
  int friendsCount = 0; // Placeholder for friends count

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile data
  }

  // Function to fetch user profile data from Firestore
  Future<void> _fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          username = userDoc['username']; // Fetch username
          profileImageUrl = userDoc['profileImageUrl']; // Fetch profile image URL
          description = userDoc['description']; // Fetch description
          friendsCount = userDoc['friendsCount']; // Fetch friends count
        });
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
  }

  // Function to update the user's description in Firestore
  Future<void> _updateUserProfile({String? description, int? friendsCount}) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
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
    // Get the current logged-in user
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('Please log in to view your profile.'));
    }

    TextEditingController descriptionController = TextEditingController(text: description);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
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
                            setState(() {
                              description = descriptionController.text;
                            });
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
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
