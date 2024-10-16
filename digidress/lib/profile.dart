import 'package:digidress/settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart';
import 'bottomnav.dart';
import 'userservice.dart';
import 'postdetails.dart';
import 'archived.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        int friendsCount =
            await _userService.getFriendsCount(user.uid); // Use UserService
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
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Picking from the gallery

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
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}');
        await storageRef.putFile(image); // Upload image to Firebase Storage
        String downloadUrl =
            await storageRef.getDownloadURL(); // Get the image URL

        // Update the user's Firestore profile with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
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

  Future<void> _archivePost(String postId) async {
    try {
      // Get the post data from Firestore
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        var postData = postSnapshot.data() as Map<String, dynamic>;

        // First, remove the post from the 'posts' collection
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();

        // Then, move the post to 'archivedPosts' collection under the user's profile
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('archivedPosts')
            .doc(postId)
            .set(postData);

        // After archiving, update the UI
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post archived successfully')));
      }
    } catch (e) {
      print('Error archiving post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to archive post')));
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
      return const Center(child: Text('Please log in to view your profile.'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo1.png',
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
         
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Profile data not available'));
          } else {
            final userProfile = snapshot.data!;
            String username = userProfile['username'] ?? 'No username';
            String profileImageUrl = userProfile['profileImageUrl'] ?? '';
            String description =
                userProfile['description'] ?? 'Please Insert Description';
            int friendsCount = userProfile['friendsCount'] ?? 0;

            TextEditingController descriptionController =
                TextEditingController(text: description);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display profile picture
                      GestureDetector(
                        onTap:
                            _pickImage, // Allow user to tap and select a new image
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : (_image != null
                                      ? FileImage(_image!)
                                      : const AssetImage(
                                          'assets/defaultProfilePicture.png'))
                                  as ImageProvider, // Default profile picture
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display username
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    username,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.drag_handle),
                                  onSelected: (value) {
                                    if (value == 'archive') {
                                      // Show archive confirmation dialog
                                      _showArchiveConfirmationDialog();
                                    } else if (value == 'viewArchived') {
                                      // Navigate to archived posts page
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ArchivedPosts()),
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'viewArchived',
                                        child: Text('Archived Posts'),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Display and navigate to friends list
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FriendsListPage(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Friends: $friendsCount',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Display and edit description
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: 200, // Adjust width as needed
                                    child: TextField(
                                      controller: descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Bio',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 2, // Allow multi-line input
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    _updateUserProfile(
                                        description: descriptionController
                                            .text); // Update description
                                    setState(
                                        () {}); // Rebuild the UI with the updated data
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
                        .where('userId', isEqualTo: user.uid)
                        .where('isArchived',
                            isEqualTo:
                                false) // Ensure only non-archived posts are shown
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs;

                      if (posts.isEmpty) {
                        return const Center(child: Text('No posts yet.'));
                      }

                      // Display posts in a GridView
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3, // Show 3 posts per row like Instagram
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final imageUrl = post['imageUrl'];

                          return GestureDetector(
                            onTap: () {
                              // Navigate to detailed post view when clicked
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                      postId: post
                                          .id), // Pass postId to PostDetailPage
                                ),
                              );
                            },
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                    height:
                        20), // Add some spacing between the posts and the button
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

  Future<void> _showArchiveConfirmationDialog() async {
    TextEditingController postIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archive Post'),
          content: TextField(
            controller: postIdController,
            decoration:
                const InputDecoration(hintText: 'Enter Post ID to Archive'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: const Text('Archive'),
              onPressed: () {
                String postId = postIdController.text.trim();
                if (postId.isNotEmpty) {
                  _archivePost(postId); // Archive the post
                  Navigator.of(context).pop(); // Close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update the user's description in Firestore
  Future<void> _updateUserProfile({String? description}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
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
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view friends.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friends')
            .doc(user.uid)
            .collection('userFriends')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data!.docs;

          if (friends.isEmpty) {
            return const Center(child: Text('No friends yet.'));
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
