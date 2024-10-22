import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digidress/postdetails.dart';
import 'package:flutter/material.dart';

class FriendProfilePage extends StatelessWidget {
  final String userID; // The ID of the friend whose profile we're viewing

  const FriendProfilePage({required this.userID, super.key});

  // Function to fetch friend profile data from Firestore
  Future<Map<String, dynamic>> _fetchFriendProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching friend profile: $e');
    }
    return {}; // Return an empty map if no data is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend\'s Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFriendProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Profile data not available'));
          } else {
            final friendProfile = snapshot.data!;
            String username = friendProfile['username'] ?? 'No username';
            String profileImageUrl = friendProfile['profileImageUrl'] ?? '';
            String description = friendProfile['description'] ?? 'No description available';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display friend's profile picture
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage('assets/defaultProfilePicture.png')
                                as ImageProvider, // Default profile picture
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display friend's username
                            Text(
                              username,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Display friend's description (bio)
                            Text(
                              description,
                              style: const TextStyle(fontSize: 16),
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
                        .where('userId', isEqualTo: userID)
                        .where('isArchived', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs;

                      if (posts.isEmpty) {
                        return const Center(child: Text('No posts yet.'));
                      }

                      // Display friend's posts in a GridView
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Show 3 posts per row like Instagram
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
                                      postId: post.id), // Pass postId to PostDetailPage
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
              ],
            );
          }
        },
      ),
    );
  }
}
