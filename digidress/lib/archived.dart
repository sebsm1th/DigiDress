import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'postdetails.dart';

class ArchivedPosts extends StatelessWidget {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Function to unarchive a post
  Future<void> _unarchivePost(String postId, Map<String, dynamic> postData) async {
    try {
      // Move the post back to the 'posts' collection
      await FirebaseFirestore.instance.collection('posts').doc(postId).set(postData);

      // Remove the post from 'archivedPosts' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('archivedPosts')
          .doc(postId)
          .delete();

      print('Post unarchived successfully');
    } catch (e) {
      print('Error unarchiving post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('archivedPosts')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var archivedPosts = snapshot.data!.docs;

          if (archivedPosts.isEmpty) {
            return const Center(child: Text('No archived posts found.'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: archivedPosts.length,
            itemBuilder: (context, index) {
              var postData = archivedPosts[index].data() as Map<String, dynamic>;
              var imageUrl = postData['imageUrl'] ?? '';
              var postId = archivedPosts[index].id;

              return GestureDetector(
                onTap: () {
                  // Navigate to detailed post view when clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetails(postId: postId, isArchived: true), // Pass postId to PostDetails
                    ),
                  );
                },
                onLongPress: () {
                  // Show dialog to unarchive post
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Unarchive Post'),
                        content: const Text('Do you want to unarchive this post?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _unarchivePost(postId, postData); // Unarchive the post
                              Navigator.of(context).pop(); // Close dialog
                            },
                            child: const Text('Unarchive'),
                          ),
                        ],
                      );
                    },
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
    );
  }
}