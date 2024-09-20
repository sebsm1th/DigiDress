import 'package:flutter/material.dart';
import 'bottomnav.dart';
import 'activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String username = ''; // Variable to store the username
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the username when the page initializes
  }

  // Fetch the current user's username and profile picture
  Future<void> _fetchUsername() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          profilePicture = userDoc['profileImageUrl'] ?? ''; // Use the profileImageUrl
        });
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Error';
      });
    }
  }

  // Function to toggle like on a post
  void _toggleLike(String postId, List<dynamic> likes) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (likes.contains(userId)) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Add a comment to a post's subcollection
  Future<void> _addComment(String postId, String comment) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      var postDocRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      var commentRef = postDocRef.collection('comments').doc();

      // Add a new comment document to the subcollection
      await commentRef.set({
        'userId': userId,
        'username': username,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Digidress'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              var postId = post.id;
              var postData = post.data() as Map<String, dynamic>?;

              var imageUrl = postData?['imageUrl'] as String? ?? '';
              var likes = (postData?['likes'] as List<dynamic>? ?? []).map((e) => e as String).toList();
              var ownerId = postData?['userId'] as String? ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
                builder: (context, ownerSnapshot) {
                  if (!ownerSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (ownerSnapshot.hasError) {
                    return Center(child: Text('Error: ${ownerSnapshot.error}'));
                  }

                  var ownerData = ownerSnapshot.data!.data() as Map<String, dynamic>?; 
                  var ownerUsername = ownerData?['username'] as String? ?? 'Unknown';
                  var ownerProfilePicture = ownerData?['profileImageUrl'] as String? ?? '';

                  return _buildPostItem(postId, imageUrl, likes, ownerUsername, ownerProfilePicture);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildPostItem(String postId, String imageUrl, List<String> likes, String ownerUsername, String ownerProfilePicture) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    bool isLiked = likes.contains(userId);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: ownerProfilePicture.isNotEmpty
                      ? NetworkImage(ownerProfilePicture)
                      : const AssetImage('assets/defaultProfilePicture.png'),
                ),
                const SizedBox(width: 10),
                Text(ownerUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
            Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                  onPressed: () => _toggleLike(postId, likes),
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _showCommentDialog(context, postId),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${likes.length} likes'),
            ),
            // StreamBuilder for the comments subcollection
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('No comments yet.'),
                  );
                }

                var comments = snapshot.data!.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var comment in comments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${comment['username'] ?? 'Unknown'}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  comment['comment'] ?? 'No comment provided',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Type your comment here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () async {
                if (commentController.text.trim().isNotEmpty) {
                  await _addComment(postId, commentController.text.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
