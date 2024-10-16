import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'postdetails.dart';

class ArchivedPosts extends StatefulWidget {
  ArchivedPosts({super.key});

  @override
  _ArchivedPostsState createState() => _ArchivedPostsState();
}

class _ArchivedPostsState extends State<ArchivedPosts> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 50);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}